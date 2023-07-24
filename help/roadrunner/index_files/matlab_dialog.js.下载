$(document).ready(function () {
    registerMatlabCommandDialogAction();
    registerOpenExampleAction();
});

function registerOpenExampleAction() {
  $.getScript('/help/basecodes.js', function(data, textStatus, jqxhr) {
      if (jqxhr.status === 200) {
          _updateOpenExampleButtons();
      }
  });
}

function _updateOpenExampleButtons() {
    if (typeof BaseCodeMap === 'function') {
        var baseCodeMap = new BaseCodeMap();
        var helpPath = document.location.pathname.split('/');  // get shortname based on current doc page Url
        if (helpPath.length >= 3) {
            var currentShortName = helpPath[2];
            if (document.location.pathname.indexOf('/help/releases/') != -1) { // archive documenation
                currentShortName = helpPath[4];
            }
            
            var mappedBasedCode = "";

            for (const basecode in baseCodeMap.simple) {
                if (baseCodeMap.simple[basecode].includes(currentShortName)) { // convert to basecode based on shortname
                    mappedBasedCode = basecode;
                }
            }

            if (mappedBasedCode && window.ow !== undefined && ow.isProductSupported !== undefined) {
                ow.isProductSupported([mappedBasedCode]).then(function (data) {
                    var openExampleButtons = $('.examples_short_list a[href^="matlab:"]').not('.example_product_list a[href^="matlab:"]'); // Added ".not()" because of g2443731

                    if (!data.exists) {
                        // reset all the button...
                        $.each(openExampleButtons, function () {
                            new OpenExampleLink($(this)).createCopyButton();
                        });
                        return; // do nothing is product not support
                    }

                    // update earch example button based on the return status.
                    $.each(openExampleButtons, function () {
                        var newLink = new OpenExampleLink($(this));
                        newLink.createCopyButton();
                        newLink.createOpenExampleButton();
                    });
                });
            } else {
                // reset all the button...
                var openExampleButtons = $('.examples_short_list a[href^="matlab:"]').not('.example_product_list a[href^="matlab:"]'); // Added ".not()" because of g2443731
                // update each example button based on the return status.
                $.each(openExampleButtons, function () {
                    new OpenExampleLink($(this)).createCopyButton();
                });
            }
        }
    }
}

const copyButtonTemplate = '<button type="button" class="btn companion_btn btn_color_blue btn-block copy_cmd_btn" data-toggle="popover" data-placement="bottom" data-trigger="hover focus" title="" data-html="true" data-content="" data-original-title="MATLAB Command">Copy Command &nbsp;<span class="icon-mw-copy"><span class="sr-only">Copy Code</span></span></button>';

class OpenExampleLink {
    
    constructor(openLink) {
        var href = openLink.attr('href');
        this.matlabCommand = getMatlabCommand(href);
        var dataAttr = openLink.attr('data-ex-genre');
        this.isLiveScript = dataAttr && dataAttr == 'Live Script';
        this.isModel = dataAttr && dataAttr == 'Model';
        
        this.parentDiv = openLink.parent();
        this.parentDiv.addClass('open_example_div');
        openLink.remove();
    }
    
    createCopyButton() {
        var cmdBtn = $(copyButtonTemplate);
        var decodedCmd = decodeURIComponent(this.matlabCommand);
        cmdBtn.attr('data-content', '<code>' + decodedCmd + '</code>');
        this.parentDiv.append(cmdBtn);
        cmdBtn.popover();
        cmdBtn.click(handleExampleCommandClick);
    }
    
    createOpenExampleButton() {
        var openWithCommand = getOpenWithCommand(this.matlabCommand);
        var openWithLabel = new getOpenWithLabel(this.isModel);
        var openWithLabelStr = openWithLabel.getString();
        var openWithLabelStatus = openWithLabel.getStatus();
        
        // In the following scenarios, don't show the "Open ..." button:
        // - This example doesn't use openExample.
        // - User isn't logged in & licensed to use MO, and this example isn't in a supported product in the Prod04 stack (g2633786);
        // - User isn't logged in & licensed to use MO, and this isn't a Live Script example.
        
        // Below, using openWithLabelStatus as a proxy to tell whether user is logged in & licensed, and if yes, whether it's a model.
        // The getOpenWithLabel function is defined in openInMO.js and openInBrowser.js, which are both included in ../html/open_with.html.
        // In this HTML there is the FreeMarker code that figures out whether user is logged in & licensed to use MO.
        if (!openWithCommand || (openWithLabelStatus == 'user_not_licensed' && !this.isLiveScript)) {
            return;
        }
        
        const notSupportedByProd04 = new Set(['5g', 'audio', 'lte', 'parallel', 'sdl', 'simscape', 'sps', 'rfpcb', 'satcom', 'slcontrol', 'sldo', 'stateflow', 'systemcomposer', 'uav', 'wlan']);
        
        const notSupportedSharedExStrings = ["5g_", "_5g", "audio_", "_audio", "lte_", "_lte", "parallel_", "_parallel", "sdl_", "_sdl", "simscape_", "_simscape", "sps_", "_sps", "rfpcb_", "_rfpcb", "satcom_", "_satcom", "slcontrol_", "_slcontrol", "sldo_", "_sldo", "stateflow_", "_stateflow", "systemcomposer_", "_systemcomposer", "uav_", "_uav", "wlan_", "_wlan"];
        
        var splitCmd = openWithCommand.split("/");
        var component = splitCmd[0];
        
        if (openWithLabelStatus == 'user_not_licensed') {
            if (notSupportedByProd04.has(component)) {
                return;
            }
            if (notSupportedSharedExStrings.some(function(v) {return component.indexOf(v) >= 0; })) {
                return;
            }
        }
        
        // If user isn't logged in & licensed to use MO, and this is a Live Script example in a supported product in MO: display the "Try This Example" button.
        
        // If user is logged in & licensed to use MO, and this is an example in a supported product in MO: 
        // - If it is a model that uses openExample, then display the "Open in Simulink Online" button;
        // - If it isn't a model, then display the "Open in MATLAB Online" button.
        
        
        var exampleName = splitCmd[1];
        var config = getOpenWithConfig(component, exampleName);
        var containerOptions = getOpenWithContainerOptions();
        var matlabLink = $('a[href="matlab:openExample(\'' + openWithCommand + '\')"]');
        var dropDown = $('<button class="btn btn_color_blue btn-block add_margin_10 analyticsOpenWith">' + openWithLabelStr + '</button>');
        this.parentDiv.prepend(dropDown);
        $(dropDown).on('click', function (e) {
            e.preventDefault();
            ow.load(config, containerOptions);
        });
        matlabLink.css('display', 'inline-block');
    }
}

function addOpenExampleLinkClickHandler(link) {
    $(link).on('click', function(e) {
        e.preventDefault();
        var href = $(this).attr('href');
        var matlabCommand = getMatlabCommand(href);
        showMatlabDialog(matlabCommand);
    });

}


$(window).on('popover_added', function() {
    $(document).on("click", ".no-matlab", function(e) {
        e.preventDefault();
        var href = $(this).attr('href');
        var matlabCommand = getMatlabCommand(href);
    showMatlabDialog(matlabCommand);
    });   
}); 


$(window).bind('examples_cards_added', function(e) {
    $('.card_container a[href^="matlab:"]').hide();
});

function registerMatlabCommandDialogAction() {
    $('a[href^="matlab:"]').not('.card_container a[href^="matlab:"], .examples_short_list a.btn[href^="matlab:"]').on('click', function (e) {
        e.preventDefault();
        var href = $(this).attr('href');
        var matlabCommand = getMatlabCommand(href);
        showMatlabDialog(matlabCommand);
    });
}

function getMatlabCommand(href) {
    var matlabCommand = null;
    var match = href.match(/matlab:(.*)/);
    if (match) {
        matlabCommand = match[1];
    }
    return matlabCommand;
}

function getOpenWithCommand(matlabCommand) {
    var openWithCommand = null;
    var match = matlabCommand.match(/openExample\('(.*)'\)/);
    if (match) {
        openWithCommand = match[1];
    }
    return openWithCommand;
}

function showMatlabDialog(matlabCommand) {
    if (matlabCommand) {
        matlabCommand = decodeURIComponent(matlabCommand);
        $("#matlab-command-dialog #dialog-body #dialog-matlab-command").text(matlabCommand);
    } else {
        $("#matlab-command-dialog #dialog-body #dialog-matlab-command").hide();
    }
    $("#matlab-command-dialog").modal();
}

function handleExampleCommandClick(evt) {
    const elt = evt.target.closest('button.btn_color_blue');
    
    const popoverId = elt.getAttribute('aria-describedby');
    const popover = document.getElementById(popoverId);
    if (popover) {
        const contentElt = popover.querySelector('.popover-content');
        const textToCopy = contentElt.textContent;
        const n = contentElt.getBoundingClientRect().top + window.scrollY
        
        // By default the copy_to_clipboard function will close the popover when it
        // selects the text to copy, so temporarily reject the hide popover event.
        $(elt).on('hide.bs.popover', keepPopoverOpen);
        if (copy_to_clipboard(textToCopy, n)) {
            contentElt.classList.add('open_example_highlight');
            const copiedElt = createCopiedTextElt(popover);
            if (copiedElt) {
                // Clean up when the popover closes.
                $(elt).one('hide.bs.popover', function() {
                    contentElt.classList.remove('open_example_highlight');
                    copiedElt.remove();
                });
            }
        }
        $(elt).off('hide.bs.popover', keepPopoverOpen);
    }
}

function keepPopoverOpen(evt) {
    evt.preventDefault();
    return false;
}

function createCopiedTextElt(popoverElt) {
    var copiedTextElt = popoverElt.querySelector('.copied_message');
    if (copiedTextElt) {
        // The Copied! indicator already exists.
        return null;
    }
    const copiedElt = document.createElement('div');
    copiedElt.classList.add('copied_message');
    copiedElt.style.float = 'right';
    copiedElt.innerHTML = 'Copied!';
    popoverElt.querySelector('.popover-title').appendChild(copiedElt);
    return copiedElt;
}

function copy_to_clipboard(text, n) {
  if (window.clipboardData) { 
    // For IE
    text = text.replace(/(\r\n)+/g, "\r\n");
    var res = window.clipboardData.setData('Text', text);
    return res;
  } else {
    var textArea = document.createElement("textarea");
    textArea.value = text; // For Edge to not shift focus away

    textArea.setAttribute("readonly", "");
    textArea.style.top = n + "px";
    textArea.style.margin = "0";
    textArea.style.padding = "0";
    textArea.style.position = "absolute";
    document.body.appendChild(textArea);
    textArea.select();
    try {
      var res = document.execCommand('copy');
      document.body.removeChild(textArea);
      return res;
    } catch (err) {
      document.body.removeChild(textArea);
      return false;
    }
  }
}