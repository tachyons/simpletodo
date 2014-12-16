class TasksController < ApplicationController
  before_filter :check_loggedin
  def new
  end
  def create
  	@task=Task.new(params[:user])
    @task.user_id=@user.id;
    if @task.save!
      @task=@user.shared_tasks.all(:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:conditions => "tasks.id = #{@task.id} and task_shares.user_id=#{@user.id}")
      # @accessible_tasks=@user.shared_tasks.all(:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position")
      render :partial => @task
    else
      render :text =>'failed'
    end
  end
  def index
  	#@tasks=@user.tasks
    if @user
      search_text=params[:search]
      @search_text=params[:search]
      if search_text.nil?
        search_text=''
      end
      if params[:completed]=="true"
        # @tasks=@user.tasks.find_all_by_status(1).sort_by(&:"id").reverse
        @tasks=@user.shared_tasks.all(:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 1 and tasks.name LIKE '#{search_text}%'")
        @tab="completed"
      else
        @tasks=@user.shared_tasks.all(:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 0 and tasks.name LIKE '#{search_text}%'")
        # @tab="completed"
        # @tasks=@user.shared_tasks.find_all_by_status(0).sort_by(&:"id").reverse
        @tab="home"
      end
       @tasks= @tasks.paginate(:page => params[:page], :per_page => 8,:order=> "id DESC")
       # render :text => @tasks.class
       # render :text => @tasks[1].position
       # render :layout =>:index
    end

  end
  def task_list
    search_text=params[:search]
    if search_text.nil?
      search_text=''
    end
    if @tab=="completed"
        @tasks=@user.shared_tasks.all(:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 1 and tasks.name LIKE '#{search_text}%'")
    else
        @tasks=@user.shared_tasks.all(:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position DESC",:conditions => "status = 0 and tasks.name LIKE '#{search_text}%'")
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
      #create a new comment
      comment=Comment.new
      comment.task_id=params[:task][:id];
      comment.user_id=current_user.id;
      if @task.status==false
        comment.body="Status Changed to  <span class='green'>UnDone</span>"
      else
        comment.body="Status Changed to  <span class='green'>Done</span>"
      end
      comment.save
      # render :partial => @task
      render :partial =>comment
    else
      render :text => nil
    end
  end
  def move_down
    @position=params[:task][:position]
    @task = Task.find_task_by_position_and_user_id(@position,@user.id)
    @down_task=@task.find_previous_task_by_position_and_user_id(@position,@user.id)
    if @task && @down_task
      @task_position=@task.position
      @downtask_position=@down_task.position
      if TaskShare.swap_elements(@task_position,@downtask_position)
        array={:task => @task.id,:other_task=>@down_task.id}
        render :json => array.to_json
      else
         render :text => @task.errors
      end
    else
      render :text => "error"
    end
  end
  def move_up
    @position=params[:task][:position]
    @task = Task.find_task_by_position_and_user_id(@position,@user.id)
    @next_task=@task.find_next_task_by_position_and_user_id(@position,@user.id)
    if @task && @next_task
      @task_position=@task.position
      @nexttask_position=@next_task.position
      if TaskShare.swap_elements(@task_position,@nexttask_position)
        array={:task => @task.id,:other_task=>@next_task.id}
        render :json => array.to_json
      else
         render :text => @task.errors
      end
    else
      render :text => "error"
    end
  end
  def show
    @users=User.all
    @accessible_tasks=@user.shared_tasks.all(:select => "DISTINCT(task_shares.task_id),task_shares.position,tasks.*",:joins => 'INNER  JOIN task_shares ts  ON task_shares.task_id = tasks.id',:order => "task_shares.position")
    # @task = @accessible_tasks[params[:id].to_i]
    @task=@accessible_tasks.detect{|x| x.task_id==params[:id]}
    # @task = @user.sharedtasks.find(params[:id])
    @shared_users=Task.find_by_id(params[:id]).shared_users
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
    @task = @user.shared_tasks.find(params[:task][:id])
    previous_progress=@task.progress;
    @task.progress=params[:task][:progress]
    if @task.save && previous_progress < @task.progress
      #create a new comment
      comment=Comment.new
      comment.task_id=params[:task][:id];
      comment.user_id=current_user.id;
      comment.body="Task has been  updated to <span class='green'>#{params[:task][:progress]}</span> from <span class='green'>#{previous_progress}</span>"
      comment.save
      render comment
    else
      render :text => nil
    end
  end
  def share_task
     @task = @user.tasks.find(params[:id])
     @task_id=params[:id];
     #validate TODO
      @user_list=params[:check]
      p "ss="
      p @user.id
      p @task_id
      # render :text =>@user_list.keys
      # TaskShare.destroy_all(:task_id => @task_id)
      TaskShare.destroy_all(["task_id = '#{@task_id}' and user_id<>'#{@user.id}'"])
      for user in @user_list.keys
        unless user == @user.id.to_s
          ts=TaskShare.new
          ts.user_id=user
          ts.task_id=@task_id
          ts.position=TaskShare.last.id+1
          unless ts.save!
          flash[:error]="error"
          redirect to task_path
          end
        end
      end
      redirect_to task_path
  end
  # def share_task
  #    @task = @user.tasks.find(params[:task][:id])
  #    @task_id=params[:task][:id];
  #    #validate TODO
  #     @user_list=params[:task][:user_list]
  #     for user in @user_list
  #        ts=TaskShare.new
  #        ts.user_id=User.find_by_name(user).id
  #        ts.task_id=@task_id
  #        ts.save!
  #     end
  # end
  private
    def check_loggedin
      @user=current_user
      if @user.nil?
        redirect_to login_path
      end
    end
end
