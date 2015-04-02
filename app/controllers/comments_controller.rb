class CommentsController < ApplicationController
  include EmojiHelper
  def index
    @task = Task.find(params[:task_id])
    @comments = @task.comments
  end

  def show
    @task = Task.find(params[:task_id])
    @comment = @task.comments.find(params[:id])
  end

  def new
    @task = Task.find(params[:task_id])
    @comment = @task.comments.build
  end

  def create
    @task = Task.find(params[:task_id])
    @comment = @task.comments.build(params[:comment])
    @comment.user_id=current_user.id;
    if @comment.save
      render :partial => @comment
    else
      render :action => "new"
    end
  end

  def edit
    @task = Task.find(params[:task_id])
    @comment = @task.comments.find(params[:id])
  end

  def update
    @task = Task.find(params[:task_id])
    @comment = Comment.find(params[:id])
    if @comment.update_attributes(params[:comment])
      redirect_to Task_comment_url(@task, @comment)
    else
      render :action => "edit"
    end
  end

  def destroy
    @task = Task.find(params[:task_id])
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to Task_comments_path(@task) }
      format.xml  { head :ok }
    end
  end
end
