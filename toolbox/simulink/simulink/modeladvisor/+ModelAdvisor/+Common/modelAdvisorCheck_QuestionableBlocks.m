









function[bResultStatus,ResultDescription,ResultHandles]=modelAdvisorCheck_QuestionableBlocks(system,xlateTagPrefix)





    ResultDescription={};
    ResultHandles={};
    bResultStatus=true;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'QuestionableBlocksSubTitle2']));
    ft.setInformation({DAStudio.message([xlateTagPrefix,'QuestionableBlocksSubCheck2Info'])});



    allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    if(strcmp(system,bdroot(system))==1)


        allBlocks=allBlocks(2:end);
    end
    try
        caps=get_param(allBlocks,'Capabilities');
    catch


        for inx=1:length(allBlocks)
            try
                caps{inx}=get_param(allBlocks{inx},'Capabilities');
            catch

                caps{inx}=[];
            end
        end
    end
    uBlocks=[];
    passBlocks=[];

    for inx=1:length(caps)
        if(isempty(caps{inx}))
            uBlocks{end+1}=allBlocks{inx};
        elseif(strcmpi(caps{inx}.supports('production'),'no'))
            foot=[caps{inx}.CapabilitySets.CapabilityArray(:).Footnotes];
            if(isempty(strfind(foot,'FnIgnoredCodeGen')))
                maskT=get_param(allBlocks{inx},'MaskType');
                if((~strcmp(maskT,'DocBlock'))&&(~strcmp(maskT,'CMBlock')))
                    uBlocks{end+1}=allBlocks{inx};
                end
            end
        else

            passBlocks{end+1}=allBlocks{inx};
        end
    end



    sin=find_system(passBlocks,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Sin');
    pulse=find_system(passBlocks,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DiscretePulseGenerator');
    pid2dof=find_system(passBlocks,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','PID 2dof');

    if(~isempty(sin))

        timeSin=strcmp(get_param(sin,'SineType'),'Time based');
        uBlocks=[uBlocks,sin(timeSin)'];
    end

    if(~isempty(pulse))

        timePulse=strcmp(get_param(pulse,'PulseType'),'Time based');
        uBlocks=[uBlocks,pulse(timePulse)'];

    end

    if(~isempty(pid2dof))

        timepid=strcmp(get_param(pid2dof,'TimeDomain'),'Continuous-time');
        uBlocks=[uBlocks,pid2dof(timepid)'];
    end



    currentResult=uBlocks;

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    currentResult=mdladvObj.filterResultWithExclusion(currentResult);

    if~isempty(currentResult)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'NoSupportRTWEC']));
        supportTableLink=['<a href="matlab: showblockdatatypetable">','  ',DAStudio.message([xlateTagPrefix,'BlockSupportTable']),'</a>'];
        RecActionStr=[DAStudio.message([xlateTagPrefix,'QuestionableBlocksSubCheck2RecAction1']),supportTableLink,'. ',DAStudio.message([xlateTagPrefix,'QuestionableBlocksSubCheck2RecAction2'])];
        ft.setRecAction(RecActionStr);
        ft.setListObj(currentResult);
        bResultStatus=false;
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'QuestionableBlocksSubCheck2Passed']));
    end

    ResultDescription{end+1}=ft;
    ResultHandles{end+1}=[];

