class GeneratorsController < ApplicationController
  #before_action :set_generator, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :setup_view_variables, only: [:new, :show, :index]
  before_action :expose_js_variables


  # GET /generators
  # GET /generators.json
  def index
    @generators = Generator.all
  end

  # GET /generators/1
  # GET /generators/1.json
  def show
  end

  # GET /generators/new
  def new
    @generator = Generator.new
  end

  # GET /generators/1/edit
  def edit
  end

  # POST /generators
  # POST /generators.json
  def create
    components = handle_components

    respond_to do |format|
      if @generator.save
        format.html { redirect_to @generator, notice: 'Generator was successfully created.' }
        format.json { render action: 'show', status: :created, location: @generator }
      else
        format.html { render action: 'new' }
        format.json { render json: @generator.errors, status: :unprocessable_entity, errors: 'Could Not Create Generator' }
      end
    end
  end

  # PATCH/PUT /generators/1
  # PATCH/PUT /generators/1.json
  def update
    respond_to do |format|
      if @generator.update(generator_params)
        format.html { redirect_to @generator, notice: 'Generator was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generators/1
  # DELETE /generators/1.json
  def destroy
    @generator.destroy
    respond_to do |format|
      format.html { redirect_to generators_url }
      format.json { head :no_content }
    end
  end

  # =Renders the preview partial
  def preview
    if (Rails.env.development? || is_admin?) && params[:id].nil?
      @obj_path = "/test/test.obj"
      flash[:alert] = "Displaying the test object"
    elsif !@obj_path
      flash[:alert] = "Could not locate file to preview"
    end
    #render :layout => false
  end

  private

  # Debating on whether to put this in component or generator controller
  # leaning towards putting it here and removing from component controller

  # [{:id, :inputs = { input_variable: { output_object_id: 1, output_variable: test }, }, :outputs, :type}, {}, {}]

  # { type: 'mult',  }
  def handle_components
    @generator = Generator.new({ :generator_hash => params[:data].to_json, :user_id => current_user.user_id })
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_generator
    @generator = Generator.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def generator_params
    params.require(:generator).permit(:name)
  end

  def object_path
    raise NotImplimentedError
  end

  def errors_creating_components?
    @was_error_creating_component || false
  end

  def error_creating_component
    @was_error_creating_component = true
  end

  def setup_view_variables
    @component_types = TerrainLib::ComponentTypesLookup.types
  end

  def expose_js_variables
    gon.component_types = TerrainLib::ComponentTypesLookup.types
    gon.component_lookup_table = TerrainLib::ComponentTypesLookup.lookup_table
  end

end
