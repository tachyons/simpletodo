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
      if params[:completed]=="true"
        @tasks=@user.tasks.find_all_by_status(1).sort_by(&:"position").reverse
        @tab="completed"
      else
        @tasks=@user.tasks.find_all_by_status(0).sort_by(&:"position").reverse
        @tab="home"
      end
       @tasks= @tasks.paginate(:page => params[:page], :per_page => 8,:order=> "position DESC")
    end
  end
  def task_list
    if @tab=="completed"
      @tasks=@user.tasks.find_all_by_status(1).sort_by(&:"position").reverse
    else
      @tasks=@user.tasks.find_all_by_status(0).sort_by(&:"position").reverse
    end
    @tasks= @tasks.paginate(:page => params[:page], :per_page => 8,:order=> "position DESC")
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
        array={:task => @task.id,:other_task=>@up_task.id}
        render :json => array.to_json
        #render :partial => @tasks
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
        # @tasks=@user.tasks.sort_by(&:"position").reverse
        # @tasks=@tasks.paginate(:page => params[:page], :per_page => 8)
        # render :partial => @tasks
        array={:task => @task.id,:other_task=>@next_task.id}
        render :json => array.to_json
      else
        render :text => @task.errors
      end
    end
  end
  def show
    @users=User.all
    @task = @user.tasks.find(params[:id])
    if request.xhr? #TODO remove this workaround 
      render :partial => @task
    end
  end
  def get_task_delete_confirm
    @id=params[:id]
    render :partial => "delete_confirm"
  end
  def change_progress
    #TODO to be secured
    @task = @user.tasks.find(params[:task][:id])
    previous_progress=@task.progress;
    @task.progress=params[:task][:progress]
    if @task.save
      #create a new comment
      comment=Comment.new
      comment.task_id=params[:task][:id];
      comment.user_id=current_user.id;
      comment.body="progress changed to #{params[:task][:progress]} from #{previous_progress}"
      comment.save
    end
  end
  def share_task
     @task = @user.tasks.find(params[:task][:id])
     @task_id=params[:task][:id];
     #validate TODO
      @user_list=params[:task][:user_list]
      for user in @user_list
         ts=TaskShare.new
         ts.user_id=User.find_by_name(user).id
         ts.task_id=@task_id
         ts.save!
      end
  end
  private
    def check_loggedin
      @user=current_user
      if @user.nil?
        redirect_to login_path
      end
    end
end
