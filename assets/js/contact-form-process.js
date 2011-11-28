$(function(){
	$('#form_submit').click(function(){
		
		var input_name = $('#form_name').val(),
			input_email = $('#form_email').val(),
			input_subject = $('#form_subject').val(),
			input_message = $('#form_message').val(),
			response_text = $('#response');
		
		response_text.hide();
		response_text.html('Loading...').show();
		
		$.post('scripts/contact-process.php', {name: input_name, email: input_email, subject: input_subject, message: input_message}, function(data){
			response_text.html(data);
		});
		return false;
	});

});