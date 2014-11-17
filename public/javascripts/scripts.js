$(document).ready(function(){
	$('#task_list').jscroll({
    // autoTrigger: false
    loadingHtml: '<img src="/ajax-loader.gif" alt="Loading" /> Loading...'
});
  $('#input_task').keypress(function (e) {
    var key = e.which;
    if(key == 13) {
      	var task = $('#input_task').val();
      	if (task.length <=0) {
      		alert("Nothing to do ?? , Why you here ?? ;-)")
      	} else {
      		$.post( "tasks/create", {user:{ name: task, user_id: user_id,status:0 }} ).done(function( data ) {
	   		$('#task_list').append(data);
	  	});
      	$('#input_task').val('');
     }
      //alert(task);
      
      //load_task(id)
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
	    }
	});
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
function move_up(id) {
	$.ajax({
	    url: '/tasks/move_up',
	    type: 'PUT',
	    data: { task:{id: id} },
	    success: function(result) {
	        var prev_div= $('#task'+id).prev().attr('id');
	        try {
	        	$("#task"+id).after($("#"+prev_div));
	        }
	        catch(e) {
	        	alert(e.message);
			}
	        
	    }
	});
}
function move_down(id) {
	$.ajax({
	    url: '/tasks/move_down',
	    type: 'PUT',
	    data: { task:{id: id} },
	    success: function(result) {
	        $('#task_list').html(result);
	    }
	});
}