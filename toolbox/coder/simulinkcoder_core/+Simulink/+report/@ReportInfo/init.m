function init(obj)



    hMdl=get_param(obj.ModelName,'handle');
    obj.Config=Simulink.report.Config(hMdl);



    systemMap=slInternal('getCoderSystemMap',hMdl);


    obj.IsTestHarness=strcmp(get_param(hMdl,'IsHarness'),'on');
    if obj.IsTestHarness
        sysBD=Simulink.harness.internal.getHarnessOwnerBD(obj.ModelName);
        hStruct=Simulink.harness.find(sysBD,'OpenOnly','on');
        obj.HarnessName=hStruct.name;


        obj.HarnessOwner=hStruct.ownerFullPath;




        obj.OwnerFileName=get_param(hMdl,'OwnerFileName');
    end
    ssHdl=rtwprivate('getSourceSubsystemHandle',hMdl);
    if~isempty(ssHdl)

        assert(~obj.IsTestHarness);
        obj.SourceSubsystem=Simulink.ID.getSID(ssHdl);
        tmpModelSSHdl=get_param(hMdl,'NewSubsystemHdlForRightClickBuild');
        obj.TemporaryModelFullSSName=getfullname(tmpModelSSHdl);
        obj.SourceSubsystemFullName=getfullname(ssHdl);

        systemMap=cellfun(@(x)Simulink.ID.getSubsystemBuildSID(x,ssHdl),systemMap,'UniformOutput',false,'ErrorHandler',@(~,~)'');
        origModelName=strtok(obj.SourceSubsystemFullName,'/');
        obj.ModelFile=get_param(origModelName,'FileName');
    else
        obj.ModelFile=get_param(hMdl,'FileName');
    end
    obj.SystemMap=systemMap;
    obj.IsERTTarget=strcmp(get_param(hMdl,'IsERTTarget'),'on');
    obj.Target=strtok(get_param(hMdl,'SystemTargetFile'),'.');
end
