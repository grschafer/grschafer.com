(function($) {

	$("#featured-projects a img, .project-img, .project-img").hover(function() {
		$(this).animate({ opacity: 0.7 }, 300);
	}, function() {
		$(this).animate({ opacity: 1 }, 300);
	});
		
})(jQuery);