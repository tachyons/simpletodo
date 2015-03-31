class FriendshipController < ApplicationController
	include FriendshipHelper
	def create
		friend=User.find(params[:id])
		Friendship.request(current_user,friend)
		flash[:notice]="friend request sent"
		redirect_to users_path
	end
	def accept
		friend=User.find(params[:id])
		if current_user.requested_friends.include? friend
			Friendship.accept(current_user,friend)
			flash[:notice]="you are now friends with #{friend.name}"
		else
			flash[:notice]="request from #{friend.name} not found"
		end
		redirect_to users_path
	end
	def delete
		friend=User.find(params[:id])
		if current_user.friends.include? friend
			Friendship.breakup(current_user,friend)
			flash[:notice]="you are no longer friends with #{friend.name}"
		else
			flash[:notice]="#{friend.name} is not your friend"
		end
		redirect_to users_path
	end
	def decline
		friend=User.find(params[:id])
		if current_user.requested_friends.include? friend
			Friendship.breakup(current_user,friend)
			flash[:notice]="you rejected friend request from #{friend.name}"
		else
			flash[:notice]="Request from #{friend.name} does not exist"
		end
		redirect_to users_path
	end
	def cancel
		friend=User.find(params[:id])
		if current_user.pending_friends.include? friend
			Friendship.breakup(current_user,friend)
			flash[:notice]="you cancelled request to #{friend.name}"
		else
			flash[:notice]="Request to #{friend.name} does not exist"
		end
		redirect_to users_path
	end
end

