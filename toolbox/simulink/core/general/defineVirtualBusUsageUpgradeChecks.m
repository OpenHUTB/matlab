function defineVirtualBusUsageUpgradeChecks






    check=ModelAdvisor.Check('mathworks.design.VirtualBusUsage');
    check.setCallbackFcn(@locExecCheckVirtualBusUsageUpgrade,'PostCompile','StyleOne');
    check.Title=DAStudio.message('Simulink:tools:MATitleCheckVirtualBusUsageUpgrade');



    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='MATitleCheckVirtualBusUsageUpgrade';
    check.SupportLibrary=false;

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@locActionAddBus2Vec);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');


    modifyAction.Description=DAStudio.message('ModelAdvisor:styleguide:CommonMAMuxUsedFixMsg');
    modifyAction.Enable=false;
    check.setAction(modifyAction);


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end







function[ResultDescription]=locExecCheckVirtualBusUsageUpgrade(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);


    model=bdroot(system);

    [bResultStatus,ResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_VirtualBusUsage(system,model);

    if bResultStatus
        mdladvObj.setCheckResultStatus(true);
    end
end







function result=locActionAddBus2Vec(taskobj)
    mdladvObj=taskobj.MAObj;
    model=mdladvObj.System;


    try
        if sl('busUtils','strictVirtualBusUsage')==1
            result={};

            xlateTagPrefix='ModelAdvisor:engine:';



            [DstPorts,~,IgnoredPorts]=Simulink.BlockDiagram.addBusToVector(model,true,false,true);
            numSuccessInsertions=length(DstPorts);
            numFailedInsertions=length(IgnoredPorts);


            if numSuccessInsertions>0
                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                successFixStr=DAStudio.message([xlateTagPrefix,'CommonMASuccessfullyAddedBusToVectorCasesUpgrade'],numSuccessInsertions);
                ft.setInformation(successFixStr);
                ft.setSubBar(false);
                result{end+1}=ft;

                for idx=1:numSuccessInsertions
                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                    htmlBlockPath=modeladvisorprivate('HTMLjsencode',DstPorts(idx).BlockPath,'encode');
                    htmlBlockPath=[htmlBlockPath{:}];
                    ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusUsageUpgradeInportList'],DstPorts(idx).InputPort,...
                    htmlBlockPath,DstPorts(idx).BlockPath,idx));
                    ft.setSubBar(false);

                    if idx==numSuccessInsertions

                        if numFailedInsertions==0
                            result{end+1}=ft;%#ok
                            ft=ModelAdvisor.FormatTemplate('ListTemplate');
                            resultStr=DAStudio.message([xlateTagPrefix,'CommonMAVirtualBusUsageUpgradeResultAllFixed']);
                            ft.setInformation(resultStr);
                            ft.setSubBar(false);
                            result{end+1}=ft;%#ok
                        else

                            ft.setSubBar(true);
                            result{end+1}=ft;%#ok
                        end
                    else
                        result{end+1}=ft;%#ok
                    end
                end
            end



            if numFailedInsertions>0
                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                failedFixStr=DAStudio.message([xlateTagPrefix,'CommonMAFailedAddedBusToVectorCasesUpgrade'],numFailedInsertions);
                ft.setInformation(failedFixStr);
                ft.setSubBar(false);
                result{end+1}=ft;

                for idx=1:numFailedInsertions
                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                    htmlBlockPath=modeladvisorprivate('HTMLjsencode',IgnoredPorts(idx).BlockPath,'encode');
                    htmlBlockPath=[htmlBlockPath{:}];
                    ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusUsageUpgradeInportList'],IgnoredPorts(idx).InputPort,...
                    htmlBlockPath,IgnoredPorts(idx).BlockPath,idx));
                    ft.setSubBar(false);
                    result{end+1}=ft;%#ok
                end
            end


            tempResult='';
            for idx=1:length(result)
                tempResult=[tempResult,result{idx}.emitContent];%#ok
            end
            result=tempResult;
        end




    catch Ex
        result=DAStudio.message('ModelAdvisor:engine:CommonMABusModifyFail',Ex.message);
    end
end




