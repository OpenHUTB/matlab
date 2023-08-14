




function unsetRunAllContextOnClose(studioComponent,~)
    studio=studioComponent.getStudio();
    toolStrip=studio.getToolStrip();
    toolStripActiveContext=toolStrip.ActiveContext;
    toolStripActiveContext.setIsOneClickRunAll(false);
end

