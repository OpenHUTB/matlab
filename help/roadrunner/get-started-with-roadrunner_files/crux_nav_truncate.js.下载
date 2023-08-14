  $(document).ready( function() {
    fixCRUXnav();
  });

  $(window).on('resize orientationchange', function () {
    fixCRUXnav();
  }); 

  
  //Truncation on Off-Canvas Open/Close in: \includes_content\responsive\scripts\offcanvas_v2.js


  //Hide overflow of the Nav so that the items don't drop below before they are truncated
  $('#subnav').on('show.bs.dropdown', function () {
    $('#subnav').css('overflow', 'visible');
  })

  $('#subnav').on('hidden.bs.dropdown', function () {
    $('#subnav').css('overflow', '');
  })  

  function fixCRUXnav() {
  
    var breakPoint = window.outerWidth;

    var subnavContainerLenght = $("#subnav").width();
    var cruxListLenght = $(".crux_browse").width();

    //Count the number of Supplimental CRUX Resources
    var numSupplimentalResources = $('#subnav .supplemental_crux_resource').length;
    numSupplimentalResources = numSupplimentalResources + 1;

    if ($('#truncate_list').length == 0) {
      var reqCRUXLenght = cruxListLenght + 1;
    } else {
      var TruncateListLength = $("#truncate_list").outerWidth(true);
      var reqCRUXLenght = cruxListLenght + TruncateListLength + 1;
    }

    //Error Checking
    //console.log("subnavContainerLenght", subnavContainerLenght);
    //console.log("cruxListLenght", cruxListLenght);
    //console.log("reqCRUXLenght", reqCRUXLenght);
    //console.log("breakPoint", breakPoint);

    var collector = '<li class="dropdown" id="truncate_list"><a href="#" class="dropdown-toggle" data-toggle="dropdown" id="truncate_dropdown_toggle" role="button" aria-haspopup="true" aria-expanded="false">' +  translateMore.locale + ' <span class="caret"></span></a><ul class="dropdown-menu" role="menu"></ul></li>'

    if (subnavContainerLenght < reqCRUXLenght) {

      if ($('#truncate_list').length == 0) {
        $('#subnav .supplemental_crux_resource').first().before(collector);
      }

      if (breakPoint > 768) {

        while ($("#subnav").width() < ($(".crux_browse").width() + $("#truncate_list").outerWidth(true))) { 
          
          //console.log("crux_browse", $(".crux_browse").width());
          //console.log("truncate_list", $("#truncate_list").outerWidth(true));

          if ($(".crux_browse").outerWidth() > 0) {
          
            $('#truncate_list').css('display', '');
            var lastCruxResource = numSupplimentalResources + 1;
            var truncate_string = 'ul.crux_browse > li:nth-last-child(' + lastCruxResource + ')';
            var truncate = $(truncate_string);
            var truncateWidth = $(truncate).outerWidth(true);

            if ($(truncate).hasClass("active")) { 
              $('#truncate_list > a').addClass("active");
            }

            $(truncate).attr("data-width", truncateWidth);
            $(truncate).prependTo("#truncate_list .dropdown-menu");
            
          } else { 
            break;
          }
        }
      }            
    }

    if (subnavContainerLenght > reqCRUXLenght) {

      //console.log("truncate_list", $("#truncate_list").outerWidth(true));

      if (breakPoint > 768) {

        while ($("#subnav").width() > ($(".crux_browse").width() + $("#truncate_list").outerWidth(true))) { 

          if ($('#subnav #truncate_list .dropdown-menu li').length != 0) { 

            var detruncate = $("#subnav #truncate_list .dropdown-menu > li:first-child");
            var detruncateWidth = $(detruncate).data('width');
            if (subnavContainerLenght > (reqCRUXLenght + detruncateWidth)) {
              if ($(detruncate).hasClass("active")) { 
                $('#truncate_list > a').removeClass("active");
              }  
              var expand_string = 'ul.crux_browse > li:nth-last-child(' + numSupplimentalResources + ')';
              $(expand_string).before(detruncate);
              
            } else {
              break;
            }

          } else {
            $('#truncate_list').hide();
            break;
          }
        }
      }
    } 
  }        