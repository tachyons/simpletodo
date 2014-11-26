class TasksController < ApplicationController
  before_filter :check_loggedin
  def new
  end
  def create
  	@task=Task.new(params[:user])
    @task.user_id=@user.id;
    if @task.save
      @task.position=Task.last.id;
      @task.save
      render :partial => 'task'
    else
    end
  end
  def index
  	#@tasks=@user.tasks
    if @user
      @tasks=@user.tasks.paginate(:page => params[:page], :per_page => 8,:order=> "position DESC")
    end
  end
  def task_list
    @tasks=@user.tasks.reverse.paginate(:page => params[:page], :per_page => 8,:order=> "position DESC")
    render :partial => "task_list"
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    respond_to do |format| 
      format.html { redirect_to(tasks_url) }
      format.xml { head :ok } 
    end
  end
  def change_status
    p params.inspect
    @task = Task.find(params[:task][:id])
    p "Status=#{@task.status}"
    if @task.status==false
      @task.status=true
    else
      @task.status=false
    end
    if @task.save
      render :partial => 'task'
    else
      #format.html { render action: "new" }
    end
  end
  def move_down
    @position=params[:task][:position]
    @task = @user.tasks.find_by_position(@position)
    @up_task=@task.previous
    if @task && @up_task
      @task_position=@task.position;
      @uptask_position=@up_task.position;
      #Model.update_all({:id => new_id}, {:id => old_id})
      @task.position=@uptask_position
      @up_task.position=@task_position
      # p @task
      if @task.save! && @up_task.save!
        @tasks=@user.tasks.sort_by(&:"position").reverse
        render :partial => @tasks
        #redirect_to "task_list"
      else
        render :text => @task.errors
      end
    end
  end
  def move_up
    @position=params[:task][:position]
    @task = @user.tasks.find_by_position(@position)
    @next_task=@task.next
    #p "Current task #{@task.id}, uptask: #{@up_task.id}"
    if @task && @next_task
      @task_position=@task.position;
      @nexttask_position=@next_task.position;
      #swap
      @task.position=@nexttask_position
      @next_task.position=@task_position

      # p @task
      if @task.save! && @next_task.save!
        @tasks=@user.tasks.sort_by(&:"position").reverse
        @tasks=@tasks.paginate(:page => params[:page], :per_page => 8)
        render :partial => @tasks
      else
        render :text => @task.errors
      end
    end
  end
  def show
    @task = Task.find(params[:id])
    render :partial=>@task
  end
  def get_task_delete_confirm
    @id=params[:id]
    render :partial => "delete_confirm"
  end
  private
    def check_loggedin
      @user=current_user
      if @user.nil?
        redirect_to login_path
      end
    end
end
