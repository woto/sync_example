class ProjectsController < ApplicationController
  include Sync::RefetchConcern

  before_filter :authenticate_user!

  def index
    @projects = current_user.projects
    case params[:status] 
    when 'complete'
      @projects = @projects.includes(:todos).where(todos: { complete: true})
    when 'incomplete'
      @projects = @projects.includes(:todos).where(todos: { complete: false})
    when 'empty'
      @projects = @projects.includes(:todos).references(:todos).group('projects.id').having('count(todos.id) = 0')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  def show
    @project = current_user.projects.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  def new
    @project = current_user.projects.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  def edit
    @project = current_user.projects.find(params[:id])
  end

  def create
    @project = current_user.projects.new(project_params)

    respond_to do |format|
      if @project.save
        binding.pry
        sync_new @project
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @project = current_user.projects.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(project_params)
        sync @project, :update
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project = current_user.projects.find(params[:id])
    @project.destroy
    sync_destroy @project

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end


  private

  def project_params
    params.require(:project).permit :name
  end
end
