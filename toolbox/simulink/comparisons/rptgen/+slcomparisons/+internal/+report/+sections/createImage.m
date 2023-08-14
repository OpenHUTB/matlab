function image=createImage(mcosView,entry,sideIndex,tempDir)




    if~isSystem(mcosView,entry,sideIndex)
        image='';
        return
    end

    [leftHandle,rightHandle]=sldiff.internal.app.getHandles(mcosView,entry.match);
    handles=[leftHandle;rightHandle];
    systemPath=getfullname(handles(sideIndex));

    imageFileName=char(matlab.lang.internal.uuid);
    imageFormat=settings().comparisons.slx.ReportImageFormat.ActiveValue;
    imageFullPath=fullfile(tempDir,[imageFileName,'.',imageFormat]);


    print(['-s',systemPath],['-d',imageFormat],imageFullPath);

    import mlreportgen.dom.Image
    image=Image(imageFullPath);
end

function bool=isSystem(mcosView,entry,sideIndex)
    isBDRoot=slcomparisons.internal.report.sections.SimulinkSectionFactory.getNodeApplicability(mcosView,entry);
    isSubsystem=slcomparisons.internal.report.sections.SimulinkSubsectionFactory.getNodeApplicability(mcosView,entry);

    bool=isBDRoot(sideIndex)||isSubsystem(sideIndex);
end

