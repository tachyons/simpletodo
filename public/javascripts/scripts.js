$(document).ready(function(){
	$('#input_task').keypress(function (e) {
	var key = e.which;
	if(key == 13) {
		var task = $('#input_task').val();
		if (task.length <=0) {
			// alert("Nothing to do ?? , Why you here ?? ;-)")
		} else {
			$.post( "/tasks/create", {user:{ name: task, user_id: user_id,status:0 }} ).done(function( data ) {
				$('#task_list').prepend(data);
				update_first_and_last();
			});
		$('#input_task').val('');
	}
	}
});
	$('#task_list').infinitescroll({

		navSelector  : '#page-nav',	// selector for the paged navigation
		nextSelector : '#page-nav a',	
		// selector for the NEXT link (to page 2)
		itemSelector : ".task",
		donetext	: " we've hit the end" ,
		loading: {
			speed: 'slow',
			finishedMsg: 'No more tasks to load.',
		   img: '/images/ajax-loader.gif'
		   }
	  });
  
});
function delete_task (id){
	$.ajax({
		url: '/tasks/'+id,
		type: 'DELETE',
		success: function(result) {
		   //alert("success")
		   $('#task'+id).remove();
		   update_first_and_last();
		}
	});
}
function confirm_delete_task (id){
	$.ajax({
		url: '/tasks/get_task_delete_confirm/'+id,
		type: 'GET',
		success: function(result) {
			//alert("success")
			$('#task'+id).html(result);
		}
	});
	$('#task'+id).css('border-color', '#c1392b');
	$('#task'+id).css('border-style', 'solid');
}
function change_status(id) {
	$.ajax({
		url: '/tasks/change_status',
		type: 'PUT',
		data: { task:{id: id} },
		success: function(result) {
		   $('#task'+id).replaceWith(result);
		}
	});
}
function move_up(position) {
	$.ajax({
		url: '/tasks/move_up',
		type: 'PUT',
		data: { task:{position: position} },
		success: function(result) {
	  //	  var prev_div= $('#task'+id).prev().attr('id');
	  //	  try {
	  //	  	$("#task"+id).after($("#"+prev_div));
	  //	  }
	  //	  catch(e) {
	  //	  	alert(e.message);
			// }
			$('#task_list').html(result);
		   
		}
	});
}
function move_down(position) {
	$.ajax({
		url: '/tasks/move_down',
		type: 'PUT',
		data: { task:{position: position} },
		success: function(result) {
		   $('#task_list').html(result);
		}
	});
}
function cancel_delete (id) {
	$.ajax({
		url: '/tasks/show/'+id,
		type: 'GET',
		success: function(result) {
		   $('#task'+id).replaceWith(result);
		}
	});
}
function load_next(page) {
	$('#load_next').remove();
	$.ajax({
		url: '/tasks/task_list?page='+page,
		type: 'GET',
		success: function(result) {
		   $('#task_list').append(result);
		}
	});
}
function update_first_and_last() {
	update_task($(".task:last"));
	update_task($(".task:first"));
	update_task($(".task:first").next());
}
function update_task(task) {
	var id_string=task.attr('id');
	var id=parseInt(id_string.replace("task", ""));
	$.ajax({
		url: '/tasks/show/'+id,
		type: 'GET',
		success: function(result) {
		   $("#"+id_string).replaceWith(result);
		}
	});
}
