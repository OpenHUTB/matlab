function ResultDescription=identifyMdlrefVarInMdl(system)






    ResultDescription={};

    try
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setInformation(DAStudio.message('Simulink:tools:MADescriptionConvertMdlrefVarToVSS'));
        ft.setSubBar(0);


        systemH=get_param(system,'Handle');
        mdlBlocks=num2cell(find_system(systemH,'LookUnderMasks','on',...
        'LookInsideSubsystemReference','off','MatchFilter',@Simulink.match.allVariants,...
        'BlockType','ModelReference','Variant','on'));


        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(systemH);
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(false);
        mdlBlocks=mdladvObj.filterResultWithExclusion(mdlBlocks);

        if~isempty(mdlBlocks)


            ft.setSubResultStatus('Warn');
            mdladvObj.setCheckResultStatus(false);
            ft.setListObj(mdlBlocks);
            ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultCheckForConvertMdlrefVarToVSS'));
            mdladvObj.setActionEnable(true);
        else


            ft.setSubResultStatus('Pass');
            mdladvObj.setCheckResultStatus(true);
            ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultCheckForConvertMdlrefVarToVSSPass'));
        end

        ResultDescription{end+1}=ft;

    catch exception


        ft.setSubResultStatus('Fail');
        ft.setSubResultStatusText(exception.message);
        mdladvObj.setCheckResultStatus(false);
    end

end


