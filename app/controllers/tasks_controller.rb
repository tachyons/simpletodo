class TasksController < ApplicationController
  before_filter :check_loggedin
  def new
  end
  def create
  	@task=Task.new(params[:user])
    @task.user_id=@user.id;
    if @task.save
      render :partial => 'task'
    else
    end
  end
  def index
  	#@tasks=@user.tasks
    if @user
      @tasks=@user.tasks.reverse.paginate(:page => params[:page], :per_page => 8)
    end
  end
  def task_list
    @tasks=@user.tasks.reverse.paginate(:page => params[:page], :per_page => 8)
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
    @id=params[:task][:id]
    @task = @user.tasks.find(@id)
    @up_task=@task.previous
    p "Current task #{@task.id}, uptask: #{@up_task.id}"
    if @task && @up_task
      @task_id=@task.id;
      @uptask_id=@up_task.id;
      #Model.update_all({:id => new_id}, {:id => old_id})
      Task.update_all({:id => -1}, {:id => @uptask_id})
      Task.update_all({:id => -2}, {:id => @task_id})
      Task.update_all({:id => @uptask_id}, {:id => -2})
      Task.update_all({:id => @task_id}, {:id => -1})

      # p @task
      if @task.save! && @up_task.save!
        @tasks=@user.tasks.reverse
        render :partial => @tasks
      else
        render :text => @task.errors
      end
    end
  end
  def move_up
    @id=params[:task][:id]
    @task = @user.tasks.find(@id)
    @next_task=@task.next
    #p "Current task #{@task.id}, uptask: #{@up_task.id}"
    if @task && @next_task
      @task_id=@task.id;
      @nexttask_id=@next_task.id;
      #Model.update_all({:id => new_id}, {:id => old_id})
      Task.update_all({:id => -1}, {:id => @nexttask_id})
      Task.update_all({:id => -2}, {:id => @task_id})
      Task.update_all({:id => @nexttask_id}, {:id => -2})
      Task.update_all({:id => @task_id}, {:id => -1})

      # p @task
      if @task.save! && @next_task.save!
        @tasks=@user.tasks.reverse
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
