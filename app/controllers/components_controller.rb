class ComponentsController < ApplicationController

  belongs_to :generator

  def index

  end

  # Pass in component args in form of
  def create
    results = handle_components

    respond_to do |format|
      format.json{ render as_json(results) }
    end
  end

  def show

  end

  def update

  end

  def edit

  end

  def destroy

  end

  private

  # [{id, in_ids, out_ids, lock}, {id, in_ids, out_ids, lock}, {}, {}, {}]
  def handle_components
    params_id_to_db_id={}

    component_args = params[:components]
    raw_components=[]
    component_args.each do |component_arg|
      component = Component.new component_arg
      params_id_to_db_id[component_arg[:id]] = component.id
      raw_components << component
    end

    clean_components=[]
    raw_components.each_with_index do |c|
      c.in_ids.each_with_index{ |v, i| c.inputs[i] = params_id_to_db_id[v] }
      c.out_id.each_with_index{ |v, i| c.outputs[i] = params_id_to_db_id[v] }
      clean_components << c
    end

    results={ created: 0, errored: 0 }
    clean_components.each do |a|
      if a.save
        results[:created] += 1
      else
        results[:errored] += 1
      end
    end
    results
  end
end
