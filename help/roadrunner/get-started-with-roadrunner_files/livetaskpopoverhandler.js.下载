$(window).on('popover_added', function() {
	 $.each($('[data-toggle="lt_popover"]'), function(key, popoverEl) {
		var matlabCommand = $(popoverEl).attr('data-examplename');
		var openWithCommand = null;
		var match = matlabCommand.match(/openExample\('(.*)'\)/);
		if (match) {
			openWithCommand = match[1];
		}
		if (window.ow !== undefined &&  openWithCommand) {
			var that = this;
            ow.doesExampleExist(openWithCommand, function (status) {
                if (status === 'true') {
					$(that).popover('destroy')
					$(that).popover({
						title: 'Interactive Task', 
						content: function() {
							var cmd = $(this).attr('data-examplename');
							var content = '<span>In live scripts, tasks like this one let you interactively explore parameters and generate MATLAB code. To use the tasks in this example, <a href="matlab:' + cmd + '">try it in your browser</a>.</span>';
							return content;
						}
					}).on('shown.bs.popover', function (eventShown) {
						var $popup = $('#' + $(eventShown.target).attr('aria-describedby'));
						$popup.find('a').click(function (e) {
							e.preventDefault();
							ow.startOpenWith(openWithCommand);
							ow.loadExample(openWithCommand);
						});
						
					});
                } 
            });
        }
	 });
  });