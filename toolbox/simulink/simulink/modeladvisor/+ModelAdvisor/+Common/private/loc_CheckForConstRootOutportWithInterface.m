function[bResultStatus,ResultDescription]=...
    loc_CheckForConstRootOutportWithInterface(system,model,encodedModelName)











    bResultStatus=false;
    ResultDescription={};


    rtwFcnClass=get_param(model,'RTWFcnClass');
    interfaceSpecified=~isempty(rtwFcnClass)&&...
    isa(rtwFcnClass,'RTW.ModelSpecificCPrototype');


    xlateTagPrefix='ModelAdvisor:engine:';

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'TitleCheckIdentConstRootOutportWithInterfaceUpgrade']));
    ft.setInformation(DAStudio.message([xlateTagPrefix,'TitletipCheckIdentConstRootOutportWithInterfaceUpgrade']));
    ft.setSubBar(0);

    if~interfaceSpecified

        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'ConstRootOutportWithoutInterfacePass']));

    else
        outBlks=find_system(get_param(model,'Handle'),'SearchDepth',1,'BlockType','Outport');
        constOutBlks=[];
        for i=1:numel(outBlks)
            outBlk=outBlks(i);
            compiledSampleTime=get_param(outBlk,'CompiledSampleTime');
            if isinf(compiledSampleTime(1))
                bResultStatus=false;
                constOutBlks(end+1)=outBlk;
            end
        end

        if isempty(constOutBlks)
            bResultStatus=true;
            ft.setSubResultStatus('Pass');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'ConstRootOutportNoSuchBlocks']));

        else
            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
            currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
            currentCheckObj.ResultData=constOutBlks;
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'ConstRootOutportWithInterfaceMsg']));
            ft.setListObj(constOutBlks);



            recActStr=DAStudio.message([xlateTagPrefix,'ConstRootOutportWithInterfaceAction']);
            ft.setRecAction(recActStr);
        end
    end

    ResultDescription{end+1}=ft;
end


