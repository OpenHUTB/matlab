// JavaScript Document

// Variable to be used by various macros so functions can only be defined when used on the page
// Not using MW to avoid conflict with the MWA variable
var MWS = new Array();

$(document).ready( function() {
	// Sticks the banner to the top:
	setTimeout(function() {
		$(".sticky_header_container").affix({offset: { top: function() {
			return (this.bottom = $('.header').length > 0 ? Math.max($("#header_desktop").outerHeight(true), $("#header_mobile").outerHeight(true), $("#doc_header_spacer").outerHeight(true)) : 0)
		}}})
	}, 100);

	/* Go to top button */
	$("<a class=\"btn btn_color_mediumgray\" id=\"go-top\"><span class=\"icon-arrow-open-up icon_24\"></span></a>").on("click", function(event) {
		event.preventDefault();
		$('html, body').animate({scrollTop: 0}, 300);
	}).appendTo("body");

	$(window).on("scroll", function() {
		if ($(this).scrollTop() > 200) {
			$('#go-top').fadeIn(200);
		} else {
			$('#go-top').fadeOut(200);
		}
	});


	/* Search Focus for XS Break Point */
	$("#mobile_search").on('shown.bs.collapse', function() {$(this).find("input[type='text']").focus();});
	
	/* Above not working on iOS */
	(function mobileSearchFocus() {
		$('#mobile_search_row button.icon-search.btn_search').on('click', function() {
			$('input.conjoined_search').focus();
		});
		$('button.icon-remove.btn_search').on('click', function() {
			$('input.conjoined_search').blur();
		});
	})();

	/* Tabs Support */
	if ($(".tab-container .responsive").length) {
		fakewaffle.responsiveTabs(['xs', 'sm']);
		$(".tab-container .responsive").each(function() {
			$(this).find(".accordion-toggle:first").click();
			$(this).find(".accordion-toggle:gt(0)").addClass("collapsed");
		});
	}
	
	/* Open section in tabs with parameter sec */
	if ($('.tabs').length && window.location.search) {
		if (typeof (URLSearchParams) !== 'undefined') {
			var urlParameters = new URLSearchParams(window.location.search);
			if ((typeof (urlParameters) !== 'undefined') && (urlParameters.has('sec'))) {
				var tabParameter = urlParameters.get('sec')
				$('#' + tabParameter).tab('show');
			}
		}
	}


	/* Shadow(box) onload */
	if($("#shadowonload").length) {
		$('#shadowonload').modal('toggle').on("click", function(event) {
			if (event.target == this) {
				window.location.href = $(this).find(".modal-header a.close").attr("href");
			}
		});
	}

	/* Collapsing Table */
	if($(".table_collapse").length) {
		$('.table_collapse table td').each(function(){
			var th = $(this).closest('table').find('th').eq( this.cellIndex ).text();
			$(this).attr('data-label', th).html();
		});
	}

	/* Resizing thumbnail overlay */
	if($(".thumbnail .overlay_container").length > 0) {
		function resizeThumbnailOverlay() {
			$(".thumbnail .overlay_container").each(function() {
				var fontsize = $(this).parent().width()/24;
				if (fontsize < 12) { fontsize=12; }
				var padding = fontsize/6;
				$(this).css("font-size", fontsize+"px").css("padding", padding+"px");
				$(this).find(".video_length").css("font-size", fontsize+"px");
			});
		}

		resizeThumbnailOverlay();
		$(window).resize(function() {
			resizeThumbnailOverlay();
		});
	}

	/* Slider */
	if($(".slide").length > 0) {
		$('.slide[data-type="multi"] .item').each(function() {
			var slide_count = $(this).parent().parent().data("slide-count");
			slide_count = typeof slide_count !== 'undefined' ? slide_count - 2 : 3;
			var next = $(this).next();
            if (!next.length) {
                next = $(this).siblings(':first');
            }
            next.children(':first-child').clone().appendTo($(this));
            for (var i = 0; i < slide_count; i++) {
                next = next.next();
                if (!next.length) {
                    next = $(this).siblings(':first');
                }
                next.children(':first-child').clone().appendTo($(this));
            }
	    });

		// go through the slider to determine the tallest item to adjust the slider height
		function resizeSliderHeight() {
          // target each slider on the page
          $('.slider-inner').each(function () {
            // initialize the height and go through each div to determine the max height
            var maxheight = 0;

            // go through each item (set of slides)
            $(this).find('.item').each(function() {

            // clone the item because we need to mess with the active state which changes based on the arrow click
            // and could result in blank slides on resize if we mess with the actual content
            var item_instance = $(this).clone().css({"visibility": "hidden"}).addClass('active').appendTo($(this).parent());

            // go through each slide in the item set to find the max height
            item_instance.find(':first-child').each(function() {
            //console.log($(this).parent().parent().parent().attr('id') + ": " + $(this).height());

			  maxheight = $(this).height() > maxheight ? $(this).height() : maxheight;

            });

            // remove the clone
            item_instance.remove();
          });

          // assign height to the target slider
		  $(this).height(maxheight);
        });
      }

      // call function on page load
      resizeSliderHeight();

      // call function on window resize
      $(window).resize(function() {
        resizeSliderHeight();
      });

	}

	/* Blog Feed */
    if ($(".blog-feed").length) {
      //How to use the Feed Control to grab, parse and display feeds.
      $.getScript('//www.google.com/jsapi', function() {
        //Load Google Feed, Version 1; Must have empty callback so google.load does not override document.write and cause blank screen
        google.load("feeds", "1", {"callback": ""});

        function feedOnLoad() {
          // Create a feed control
          $(".blog-feed").each(function() {
            var feedControl = new google.feeds.FeedControl();
            // Add one feed
            feedControl.addFeed("http://feeds.feedburner.com/" + $(this).data("feedburnerid") + "?format=xml");
            feedControl.setNumEntries($(this).data("numpost"));

            // Draw the feed
            feedControl.draw($(this)[0]);
          });
        }
        google.setOnLoadCallback(feedOnLoad);
      });
    }

	// Expand Collapse
	if($(".expand_collapse").length) {
		MWS["expand"] = {
			"querystr": "",
			"curpage": "",
			"open_obj": "",
			"getExpandData": function() {
				return sessionStorage.getItem('expand')
			},
			"storeExpandData": function() {
				//session storage, will expire when broswer is closed
				sessionStorage.expand = JSON.stringify(MWS["expand"].open_obj);
			},
			"getUrlVars": function() {
				var vars = [], hash;
				var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
				for (var i = 0; i < hashes.length; i++) {
						hash = hashes[i].split('=');
						vars.push(hash[0]);
						vars[hash[0]] = hash[1];
				}
				return vars;
			}
		}
		MWS["expand"].querystr = window.location.href.slice(window.location.href.indexOf('?') + 1);
		if (window.location.href.indexOf('?') < 0) {
			MWS["expand"].querystr = "";
		}

		MWS["expand"].curpage = { "url": window.location.pathname, "query": MWS["expand"].querystr, "open": [] };
		MWS["expand"].open_obj = { "page": [ MWS["expand"].curpage ] };

		if (MWS["expand"].getExpandData()) {
			var found = 0;
			MWS["expand"].open_obj = JSON.parse(MWS["expand"].getExpandData());
			//find the page and assign to curpage var
			$.each(MWS["expand"].open_obj.page, function(index, value) {
				if(value.url == window.location.pathname && value.query == MWS["expand"].querystr) {
					MWS["expand"].curpage = value;
					found = 1;
				}
			});
			//if the page wasn't found then add it
			if (!found) {
				MWS["expand"].open_obj.page.push(MWS["expand"].curpage);
				MWS["expand"].storeExpandData();
			}
		} else {
			MWS["expand"].storeExpandData();
		}

		// Get the query string value and store in an array
		var expandparam = MWS["expand"].getUrlVars()["expand"];
		if (typeof(expandparam) != "undefined") {
			expandparam = expandparam.split(",");
		} else {
			expandparam = [];
		}


		// Determine which way to use as the on page load open. Clear the open values if necessary.
		var toggletype = "default"; // Everything is closed unless the html wants a default open

		if (MWS["expand"].querystr == "" && MWS["expand"].curpage.query != "") {
			toggletype = "default";
			MWS["expand"].curpage.open = [];
		} else if (MWS["expand"].querystr != "" && MWS["expand"].curpage.query != MWS["expand"].querystr && expandparam.length > 0) { // Query string if different than the last used query string
			toggletype = "query";
			MWS["expand"].curpage.open = [];
		} else if ( MWS["expand"].curpage.open.length > 0 ) { // Cookie values if there is a cookie already set
			toggletype = "cookie";
		} else if (MWS["expand"].querystr != "" && expandparam.length > 0) { // Query string if there isn't a cookie
			toggletype = "query";
			MWS["expand"].curpage.open = [];
		} else {
			MWS["expand"].curpage.open = [];
		}
		// store the query string in the cookie for comparing on next page load
		MWS["expand"].curpage.query = MWS["expand"].querystr;


		$("body").on("click", ".expand_trigger", function() {
			var clickedexpander = $(this);
			index = clickedexpander.data("index");
			if(clickedexpander.hasClass("collapsed")) { // collapsing
				if($.inArray(index, MWS["expand"].curpage.open) < 0) {
					MWS["expand"].curpage.open.push(index);
					MWS["expand"].storeExpandData();
				}
			} else { //expanding
				MWS["expand"].curpage.open.splice($.inArray(index, MWS["expand"].curpage.open), 1);
				MWS["expand"].storeExpandData();
			}

			//find the collapse / expand that relates to this and toggle if necessary
			setTimeout(function() {
				var toggle = $("."+clickedexpander.closest(".expand_collapse").data("toggle"));
				var target = toggle.data("target");
				var totalcount = 1;
				var totalactive = 1;
				if (target == "all") {
					totalcount = $(".expand_trigger").length;
					totalactive = $(".expand_trigger:not(.collapsed)").length;
				} else {
					totalcount = $("."+target).find(">.expand_trigger + .collapse").length;
					totalactive = $("."+target).find(">.expand_trigger + .collapse.in").length;
				}
				if (totalcount == totalactive) {
					toggle.find(".expand_all").hide();
					toggle.find(".collapse_all").show();
				} else if (totalactive == 0) {
					toggle.find(".expand_all").show();
					toggle.find(".collapse_all").hide();
				}
			}, 500);
		});



		$("body").on("click", ".expand_all", function(event) {
			event.preventDefault();
			var target = $(this).hide().next().show().parent().data("target");
			var targetIds = new Array();
			if (target == "all") {
				$(".expand_trigger.collapsed").each(function() {
					$(this).click();
					targetIds.push($(this).parent().data("index"));
				});
			} else {
				$("."+target+" > .expand_trigger.collapsed").each(function() {
					$(this).click();
					targetIds.push($(this).parent().data("index"));
				});
			}

			$.each(targetIds, function(index, value) {
				if($.inArray(value, MWS["expand"].curpage.open) < 0) {
					MWS["expand"].curpage.open.push(value);
				}
			});
			MWS["expand"].storeExpandData();
		});

		$("body").on("click", ".collapse_all", function(event) {
			event.preventDefault();
			var target = $(this).hide().prev().show().parent().data("target");
			var targetIds = new Array();
			if (target == "all") {
				$(".expand_trigger:not(.collapsed)").each(function() {
					$(this).click();
					targetIds.push($(this).parent().data("index"));
				});
			} else {
				$("."+target+" > .expand_trigger:not(.collapsed)").each(function() {
					$(this).click();
					targetIds.push($(this).parent().data("index"));
				});
			}

			$.each(targetIds, function(index, value) {
				MWS["expand"].curpage.open.splice($.inArray(value, MWS["expand"].curpage.open), 1);
			});
			MWS["expand"].storeExpandData();

		});

		$(".expand_trigger").each(function(index) {
			var expander = $(this);
			expander.data("index", index);
			var expanderIds = new Array();
			// If it should be opened on page load then open it
			if ( (toggletype == "query" && $.inArray(expander.data("target").substr(1), expandparam) > -1) ||
					 (toggletype == "cookie" && $.inArray(index, MWS["expand"].curpage.open) > -1) ||
					 (toggletype == "default" && expander.hasClass("default_open")) ) {
				expander.click();
				expanderIds.push(index);
			}
			$.each(expanderIds, function(index, value) {
				if($.inArray(value, MWS["expand"].curpage.open) < 0) {
					MWS["expand"].curpage.open.push(value);
				}
			});
			MWS["expand"].storeExpandData();
		});

		switches = $(".switch");
		switchcount = switches.length;
		switches.each(function(index) {
			var switcher = $(this);
			var totalcount = 0;
			var totalactive = 0;
			if (switchcount == 1) {
				switcher.data("target", "all").addClass("mwToggle0");
				$(".expand_collapse").data("toggle", "mwToggle0");
				totalcount = $(".expand_trigger").length;
				totalactive = $(".expand_trigger:not(.collapsed)").length;
			} else {
				if (switcher.data("target") == "" || switcher.data("target") == null) {
					switcher.data("target", "mwExpandToggle"+index).addClass("mwToggle"+index);
					//Change from parent to closest
					switcher.parent().addClass("mwExpandToggle"+index).data("toggle", "mwToggle"+index);
				} else {
					var target = switcher.addClass("mwToggle"+index).data("target");
					$("."+target).data("toggle", "mwToggle"+index);
				}
				totalcount = $("."+switcher.data("target")).find(">.expand_trigger + .collapse").length;
				totalactive = $("."+switcher.data("target")).find(">.expand_trigger + .collapse.in").length;
			}
			if (totalcount == totalactive) {
				switcher.find(".expand_all").hide();
				switcher.find(".collapse_all").show();
			} else {
				switcher.find(".expand_all").show();
				switcher.find(".collapse_all").hide();
			}
		});
	}
	// End Expand All

	/*
     * Office Selection
     */
    if($("#js_offices").length) {
      $(window).on("load", function() {
        if($("#js_offices")) {
          if(location.hash.length == 3) {
            changeCountry(location.hash);
          } else {
            changeCountry("#default")
          }
        }
      });

      $(window).on("hashchange", function() {
        changeCountry(location.hash);
      });

      function changeCountry(hash) {
        country = hash.split("#");
        if(country.length == 2 && (country[1].length == 2 || country[1] == "default")) {
          country = country[1].toLowerCase();
          $(".js_office").hide();
          if($(".country-"+country).length) {
            $(".country-direct").hide();
            $(".country-"+country).show();
          } else {
            $(".country-direct").show();
          }
        }
      }
    }
    // End Office Selection
});

/*
 * See More Toggle
 * Moved function out to global namespace so it can be called directly by AEM
 */

function moreToggle() {
	$('.show_more_toggle').each(function() {
		var height = $(this).height(),
				shortenHeight = $(this).data('height'),
				collapseText = $(this).data('collapse-text'),
				expandText = $(this).data('expand-text'),
				forceShorten = $(this).data('force-shorten'),
				that = this;
		if (forceShorten == true || height > shortenHeight) {
			$(this).css({'max-height': shortenHeight});
			$(this).append('<p class="read_more add_margin_0 small"><a href="#" class="showMore icon-arrow-open-down">'+ expandText +'</a></p>');
			$(this).find('.read_more a').on('click', function(e) {
				e.preventDefault();
				if ($(this).hasClass('showMore')) {
					$(that).animate({'max-height': height + 5}, 400).toggleClass('show_more_toggle_expanded');
					$(this).text(collapseText).removeClass('icon-arrow-open-down showMore').addClass('icon-arrow-open-up showLess');
				} else {
					$(that).animate({'max-height': shortenHeight}, 400).toggleClass('show_more_toggle_expanded');
					$(this).text(expandText).removeClass('icon-arrow-open-up showLess').addClass('icon-arrow-open-down showMore');
				}
			});
		}
	});
}

/* 
 * Styled Tags 
 * Moved function out to global namespace so that it could be called after new tags are inserted
 */
function processTags() {
	$('a.tag_component').each(function() {
		// Truncate tags over 18 characters, add elipses, add title attribute of full tag
		if($(this).text().length > 21 ) {
			$(this).attr("title", $(this).html()).text($(this).text().substr(0,18)).append('...');;
		}
		// Append remove icon if remove class is present
		if ($(this).hasClass('tag_remove') ) {
			$(this).append('<span class="icon_16 icon-remove"></span>');
		}
	});
}

$(document).ready(function() {
	moreToggle();
	processTags();
}) 
$(window).resize(function() {
	moreToggle();
});

/* End See More Toggle */



/*
 * See More Toggle v2
 */

function moreToggle_evaluate() {
  $('.show_more_toggle_element').each(function() {
    $('.show_more_toggle_mask', this).css('height', '');
    var height = $('.show_more_toggle_content', this).height(),
        shortenHeight = $(this).data('height'),
        expandText = $(this).data('expand-text'),
        collapseText = $(this).data('collapse-text');
    if (height > shortenHeight) {
      if (!($('.show_more_toggle_mask', this).hasClass('show_more_toggle_expanded'))) {
        $('.show_more_toggle_mask', this).removeClass('more_toggle_remove_mask');
        $('.show_more_toggle_mask', this).css('height', shortenHeight);
      }
      if (!($('.read_more_actuator a', this).length)) {
        $(this).append('<p class="read_more_actuator small"><a href="#" class="showMore icon-arrow-open-down" aria-label="'+ expandText +'/'+ collapseText +' Toggle">'+ expandText +'</a></p>');
      } else {
        $('.read_more_actuator a', this).css('display', '');
      }
    } else {
      if (!($('.show_more_toggle_mask', this).hasClass('show_more_toggle_expanded'))) {
        $('.show_more_toggle_mask', this).addClass('more_toggle_remove_mask');
      }      
      if ($('.read_more_actuator a', this).length) { 
        $('.read_more_actuator a', this).css('display', 'none');
      }
    }
  });
}


$(document).on("click", '.read_more_actuator a', function(e) {
  var toggle_content_height = $(this).closest('.show_more_toggle_element').find('.show_more_toggle_content').height(),
      shortenHeight = $(this).closest('.show_more_toggle_element').data('height'),
      collapseText = $(this).closest('.show_more_toggle_element').data('collapse-text'),
      expandText = $(this).closest('.show_more_toggle_element').data('expand-text'),
      that =  $(this).closest('.show_more_toggle_element');
  e.preventDefault();
  if ($(this).hasClass('showMore')) {
    $('.show_more_toggle_mask', that).css('height', toggle_content_height).toggleClass('show_more_toggle_expanded');
    $(this).text(collapseText).removeClass('icon-arrow-open-down showMore').addClass('icon-arrow-open-up showLess');
  } else {
    $('.show_more_toggle_mask', that).css('height', shortenHeight).toggleClass('show_more_toggle_expanded');
    $(this).text(expandText).removeClass('icon-arrow-open-up showLess').addClass('icon-arrow-open-down showMore');
  }
});


$(document).ready( function() {
  moreToggle_evaluate();
});

$(window).on('resize orientationchange', function () {
 moreToggle_evaluate();
}); 

/* End See More Toggle v2 */



/*
 * Matrix / Hamburger Expander Functionality for Mobile
 */
$(document).ready( function() { 
  $('#matrix_collapse').on('show.bs.collapse', function () {
    if ($('#topnav_collapse').hasClass('in')) { 
      $('#topnav_collapse').collapse('toggle');
    }
  })
  $('#topnav_collapse').on('show.bs.collapse', function () {
    if ($('#matrix_collapse').hasClass('in')) { 
      $('#matrix_collapse').collapse('toggle');
    }
  }) 
});



/*
 * Matrix / Hamburger Dropdown Functionality for Tablet
 */
$(document).click(function(e){
  if ($(".navbar-collapse").has(e.target).length === 0) {
    if ($('#matrix_collapse').hasClass('in')) { 
      $('#matrix_collapse').collapse('toggle');
    }
    if ($('#topnav_collapse').hasClass('in')) { 
      $('#topnav_collapse').collapse('toggle');
    }
  }
});



/*
 * Mobile Search: Move :focus on Expand
 */
$(document).ready( function() { 
  $('#mobile_search').on('shown.bs.collapse', function () {
    $(".search_nested_content_container .input-group .form-control").focus();
  })
  $('#mobile_search').on('hidden.bs.collapse', function () {
    $("#search_actuator .icon-search.btn_search").focus();
  })
});