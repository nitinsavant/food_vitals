class SubmissionsController < ApplicationController
  before_action :find_submission, only: [:show, :edit, :update, :destroy]

  def index
    @submissions = Submission.all.order("created_at DESC")
  end

  def show
    @submission = Submission.find(params[:id])
    @ingredients = @submission.ingredients.all.inspect
    @nutrition_facts, @nutrition_overview, @xml_response,
      @oauth_params_foodget, @ingredients_summary =
        Submission.calculate_nutrition(@submission.id)
  end

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.new(submission_params)
    if @submission.save

      @ingredients_amounts, @oauth_check, @food_id_array =
        Submission.get_fatsecret_food_ids(@submission.id)

      if @food_id_array.empty?
        flash[:alert] =
          'Shoot! I couldn\'t extract ingredients from that recipe site.'
      end

      @nutrition_facts, @nutrition_overview, @xml_response,
        @oauth_params_foodget, @ingredients_summary =
          Submission.calculate_nutrition(@submission.id)

    elsif @submission.errors.messages[:url] == "has already been taken"
      @original_submission = Submission.find_by(url: submission_params[:url])
      redirect_to @original_submission
      @nutrition_facts, @nutrition_overview, @xml_response,
        @oauth_params_foodget, @ingredients_summary =
          Submission.calculate_nutrition(@submission.id)
    end
    
    render 'static_pages/home'
  end

  def edit
  end

  def update
    if @submission.update(submission_params)
      redirect_to @submission
    else
      render 'edit'
    end
  end

  def destroy
    @submission.destroy
    redirect_to submissions_path
  end

  private

  def submission_params
    params.require(:submission).permit(:url, :spoon_recipe_response)
  end

  def find_submission
    @submission = Submission.find(params[:id])
  end

end
