class GeneratorsController < ApplicationController
  before_action :set_generator, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!


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

    # Generator is created from the head
    @generator = Generator.new(components.first)

    respond_to do |format|
      if @generator.save && !errors_creating_components?
        format.html { redirect_to @generator, notice: 'Generator was successfully created.' }
        format.json { render action: 'show', status: :created, location: @generator }
      else
        format.html { render action: 'new' }
        format.json { render json: @generator.errors, status: :unprocessable_entity }
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

  def handle_components
    params_id_to_db_id={}

    component_args = params[:components]
    raw_components=[]
    component_args.each do |component_arg|
      component = Component.new component_arg
      component.generator = self
      params_id_to_db_id[component_arg[:id]] = component.id
      raw_components << component
    end

    clean_components=[]
    raw_components.each_with_index do |c|
      c.in_ids.each_with_index{ |v, i| c.inputs[i] = params_id_to_db_id[v] }
      c.out_id.each_with_index{ |v, i| c.outputs[i] = params_id_to_db_id[v] }
      clean_components << c
    end

    clean_components.each do |a|
      if a.save
        components << a
      else
        error_creating_component
      end
    end

    clean_components
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

end
