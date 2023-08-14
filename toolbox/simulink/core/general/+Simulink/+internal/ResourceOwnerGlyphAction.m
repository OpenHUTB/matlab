function ResourceOwnerGlyphAction(blkHandle,glyphType)


    screenSize=get(0,'ScreenSize');


    pointerLocation=get(0,'PointerLocation');


    pointerLocation(2)=screenSize(4)-pointerLocation(2);


    resourceAccessorLinks=Simulink.ResourceAccessorLinks(blkHandle,glyphType);
    if(~isempty(resourceAccessorLinks.StateInfo)||...
        ~isempty(resourceAccessorLinks.ParamInfo))
        dlg=DAStudio.Dialog(resourceAccessorLinks);
        dlg.position(1:2)=pointerLocation;
        dlg.show;
    end
