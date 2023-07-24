$(window).on('popover_added', function() {
	 $.each($('[data-toggle="popover"]'), function(key, popoverEl) {
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
						title: 'Interactive Control', 
						content: function() {
							var cmd = $(this).attr('data-examplename');
							var content = '<span>In live scripts, controls like this one let you set the value of a variable interactively. To use the controls in this example, <a href="matlab:' + cmd + '">try it in your browser</a>.</span>';
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