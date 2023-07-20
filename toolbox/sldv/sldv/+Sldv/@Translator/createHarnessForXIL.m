function[status,errorMsg]=createHarnessForXIL(obj)




    errorMsg=[];
    topModelName=get_param(obj.mTestComp.analysisInfo.designModelH,'Name');
    dirtyStatus=get_param(topModelName,'Dirty');
    try
        subSystemFullName=getfullname(obj.mBlockH);
        load_system(subSystemFullName);
        harnessModelName=regexprep([get_param(obj.mBlockH,'Name'),'_harness_SubsystemSIL'],'\s+','');
        harnesslist=Simulink.harness.internal.find(subSystemFullName);
        if~isempty(harnesslist)
            for idx=1:numel(harnesslist)
                if harnesslist(idx).isOpen
                    Simulink.harness.internal.close(subSystemFullName,harnesslist(idx).name);
                end
            end
        end
        harnesslist=Simulink.harness.internal.find(subSystemFullName,'Name',harnessModelName);
        if isempty(harnesslist)


            set_param(topModelName,'Dirty','off');
            Simulink.harness.internal.create(subSystemFullName,...
            false,...
            false,...
            'Name',harnessModelName,'Source','Inport',...
            'DriveFcnCallWithTestSequence',false,...
            'SLDVCompatible',true);
        end
        Simulink.harness.internal.load(subSystemFullName,harnessModelName,false);
        status=true;

        obj.mExtractedModelH=get_param(harnessModelName,'Handle');
        obj.mTestComp.analysisInfo.analyzedSubsystemH=obj.mBlockH;
        obj.mTestComp.analysisInfo.analyzedModelH=get_param(harnessModelName,'Handle');
        obj.mTestComp.analysisInfo.extractedModelH=obj.mTestComp.analysisInfo.analyzedModelH;

        obj.mModelToCheckCompatH=obj.mTestComp.analysisInfo.extractedModelH;
        obj.mModelToReportCompatibilityName=get_param(obj.mModelToCheckCompatH,'Name');
        obj.mModelToCheckCompatName=get_param(obj.mModelToCheckCompatH,'Name');
    catch Mex
        errorMsg=Mex.message;
        status=false;
    end
    set_param(topModelName,'Dirty',dirtyStatus);
end
