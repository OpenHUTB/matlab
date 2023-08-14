function[startTag,endTag]=createHotlinks(destination,linkAnchor,font,isLinkInHelpTargets)















    if matlab.internal.display.isHot&&~isdeployed
        if nargin<4
            isLinkInHelpTargets=false;
            if nargin<3
                font='normal';
            end
        end
        if isLinkInHelpTargets
            isCSH=strcmpi(destination,'helpppopup');
            [~,startTag]=addLink('','optim',linkAnchor,isCSH);
        else
            startTag=sprintf('<a href="matlab: %s %s" style="font-weight:%s">',destination,linkAnchor,font);
        end
        endTag='</a>';
    else
        startTag='';
        endTag='';
    end
