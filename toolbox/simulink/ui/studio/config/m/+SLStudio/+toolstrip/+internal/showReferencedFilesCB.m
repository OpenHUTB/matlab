function showReferencedFilesCB(cbinfo)


    studio=cbinfo.studio;
    refFilesComp=studio.getComponent('Simulink:Editor:ReferencedFiles','Referenced Files');

    calledFromToolstrip=isa(cbinfo.EventData,'logical');
    if calledFromToolstrip

        if~refFilesComp.isVisible
            studio.showComponent(refFilesComp);
            studio.focusComponent(refFilesComp);
        else
            studio.hideComponent(refFilesComp);
        end
    else

        studio.hideComponent(refFilesComp);
        studio.showComponent(refFilesComp);
        studio.focusComponent(refFilesComp);
    end
end
