function[bResultStatus,ResultDescription]=modelAdvisorCheck_CaseBlock(system,xlateTagPrefix)






    ResultDescription={};
    bResultStatus=false;
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');


    allCase=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','SwitchCase');

    if isempty(allCase);
        ft.setSubResultStatus('Pass');
        bResultStatus=true;
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0011_NoCaseBlocksFound']));
        ResultDescription{end+1}=ft;
    else
        noDefault=strcmp('off',get_param(allCase,'ShowDefaultCase'));
        noDefaultCase={};
        if(any(noDefault))

            noDefaultCase=allCase(find(noDefault));%#ok<FNDSB>
        end


        noDefaultCase=mdladvObj.filterResultWithExclusion(noDefaultCase);
        if~isempty(noDefaultCase)

            ft.setSubResultStatus('warn');
            ft.setListObj(noDefaultCase);
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0011_Fail_1']));
            ft.setRecAction(DAStudio.message([xlateTagPrefix,'hisl_0011_RecAct_1']));
            ResultDescription{end+1}=ft;
        end








        portCons=get_param(allCase,'PortConnectivity');
        noConSub=zeros(length(allCase),1);
        for inx=1:length(portCons)
            for jnx=2:length(portCons{inx})
                if isempty(portCons{inx}(jnx).DstBlock)
                    noConSub(inx)=1;
                else

                    dstBlock=get_param(portCons{inx}(jnx).DstBlock,'BlockType');
                    if(strcmp(dstBlock,'Terminator'))
                        noConSub(inx)=1;
                    end
                end
            end
        end

        ft2=ModelAdvisor.FormatTemplate('ListTemplate');
        noConSub=allCase(find(noConSub));%#ok<FNDSB>
        noConSub=mdladvObj.filterResultWithExclusion(noConSub);
        if~isempty(noConSub)
            ft.setSubBar(0);
            ft2.setSubResultStatus('warn');
            ft2.setListObj(noConSub);
            ft2.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0011_Fail_2']));
            ft2.setRecAction(DAStudio.message([xlateTagPrefix,'hisl_0011_RecAct_2']));
            ResultDescription{end+1}=ft2;
        end

        if(isempty(noConSub))&&(isempty(noDefaultCase))

            ft.setSubResultStatus('pass');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0011_Pass_1_2']));
            bResultStatus=true;
            ResultDescription{end+1}=ft;
        end
    end
end
