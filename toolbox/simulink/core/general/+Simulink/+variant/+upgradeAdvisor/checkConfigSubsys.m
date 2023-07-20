




function[ResultDescription]=checkConfigSubsys(system)

    ResultDescription={};

    systemH=get_param(system,'Handle');
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(systemH);


    configBlocks=findCSSBlocks(system);


    configBlocks=mdladvObj.filterResultWithExclusion(configBlocks);

    cssTemplateBlks={};
    cssTemplateBlksByModelDisc={};
    cssBlks={};



    for i=1:length(configBlocks)
        blk=configBlocks{i};
        tmpBlk=get_param(blk,'TemplateBlock');

        if isempty(tmpBlk)||strcmpi(tmpBlk,'master')
            continue;
        elseif~strcmpi(tmpBlk,'self')
            tmpBlkMdl=strtok(tmpBlk,'/');
            load_system(tmpBlkMdl);
            try


                mdlDiscLib=get_param(system,'disc_configurable_lib');
                if(strcmp(mdlDiscLib,tmpBlkMdl))
                    cssTemplateBlksByModelDisc{end+1}=blk;
                else
                    if~isempty(get_param(tmpBlk,'TemplateBlock'))
                        cssBlks{end+1}=blk;
                    end
                end
            catch
                if~isempty(get_param(tmpBlk,'TemplateBlock'))
                    cssBlks{end+1}=blk;
                end
            end
        else
            cssTemplateBlks=[cssTemplateBlks;{blk}];
        end
    end

    cssTemplateBlks=unique(cssTemplateBlks);
    cssTemplateBlksByModelDisc=unique(cssTemplateBlksByModelDisc);
    cssTempBlkFound=~isempty(cssTemplateBlks)||~isempty(cssTemplateBlksByModelDisc);
    needEnableAction=false;


    if cssTempBlkFound


        ResultDescription=displayWarningForCSSBlocks(cssTemplateBlks,cssTemplateBlksByModelDisc);
        mdladvObj.setCheckResultStatus(false);
        needEnableAction=~isempty(cssTemplateBlks);
    elseif~isempty(cssBlks)

        ftCSSTempl=ModelAdvisor.FormatTemplate('ListTemplate');
        ftCSSTempl.setInformation(DAStudio.message('Simulink:tools:MADescriptionConfigSubsys'));
        ftCSSTempl.setSubBar(0);
        ftCSSTempl.setListObj(cssBlks);
        ftCSSTempl.setSubResultStatus('Warn');
        ftCSSTempl.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultCheckForCSSBlocks'));
        ftCSSTempl.setRecAction(DAStudio.message('Simulink:tools:MASubResultStatusForCSSBlocks'));
        ResultDescription{end+1}=ftCSSTempl;

        result=ModelAdvisor.Paragraph;
        modText=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAResultInfoOnParameterizedCSSInstances'));
        modText.setColor('warn');
        result.addItem(ModelAdvisor.LineBreak);
        result.addItem(modText);
        ResultDescription{end+1}=result;
    else

        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setInformation(DAStudio.message('Simulink:tools:MADescriptionConfigSubsys'));
        ft.setSubBar(0);
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MACheckForCSSPassed'));
        ResultDescription{end+1}=ft;
        mdladvObj.setCheckResultStatus(true);
    end

    mdladvObj.setActionEnable(needEnableAction);
end



function ft=displayWarningForCSSBlocks(cssTemplateBlks,cssTemplateBlksByModelDisc)
    ft={};
    if~isempty(cssTemplateBlks)


        ftCSSTempl=ModelAdvisor.FormatTemplate('ListTemplate');
        ftCSSTempl.setInformation(DAStudio.message('Simulink:tools:MADescriptionConfigSubsys'));
        ftCSSTempl.setSubBar(0);
        ftCSSTempl.setListObj(cssTemplateBlks);
        ftCSSTempl.setSubResultStatus('Warn');
        ftCSSTempl.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultCheckForCSSTempBlocks'));
        ft{end+1}=ftCSSTempl;

        result=ModelAdvisor.Paragraph;
        modText=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAResultInfoOnParameterizedCSSInstances'));
        modText.setColor('warn');
        result.addItem(ModelAdvisor.LineBreak);
        result.addItem(modText);
        ft{end+1}=result;

    end
    if~isempty(cssTemplateBlksByModelDisc)


        ftCSSByModelDisc=ModelAdvisor.FormatTemplate('ListTemplate');
        ftCSSByModelDisc.setInformation(DAStudio.message('Simulink:tools:MADescriptionConfigSubsysByModelDisc'));
        ftCSSByModelDisc.setSubBar(0);
        ftCSSByModelDisc.setListObj(cssTemplateBlksByModelDisc);
        ftCSSByModelDisc.setSubResultStatus('Warn');
        ftCSSByModelDisc.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultCheckForCSSBlocksByModelDisc'));
        ftCSSByModelDisc.setRecAction(DAStudio.message('Simulink:tools:MASubResultStatusForCSSBlocksByModelDisc'));
        ft{end+1}=ftCSSByModelDisc;
    end
end


function configBlocks=findCSSBlocks(system)

    configBlocks=find_system(system,'Regexp','on','LookUnderMasks','on',...
    'FollowLinks','on','LookInsideSubsystemReference','off','MatchFilter',@Simulink.match.allVariants,...
    'TemplateBlock','.');
end
