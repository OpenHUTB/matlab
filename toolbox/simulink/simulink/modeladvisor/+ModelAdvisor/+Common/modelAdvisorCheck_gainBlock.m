function[bResultStatus,ResultDescription]=modelAdvisorCheck_gainBlock(system,xlateTagPrefix,enabled)





    bResultStatus=false;%#ok<NASGU>
    ResultDescription={};

    hScope=get_param(system,'Handle');
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'GainBlocksSubTitle']));

    if enabled==false
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SubcheckDisabled']));
        ResultDescription{end+1}=ft;
        bResultStatus=true;
        return;
    end

    ft.setInformation({DAStudio.message([xlateTagPrefix,'GainBlocksInformation'])});

    uBlocks={};


    gainBlocks=find_system(hScope,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'BlockType','Gain');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    for idx=1:length(gainBlocks)
        try
            gainObj=get_param(gainBlocks(idx),'Object');


            resGain=Advisor.Utils.Simulink.evalSimulinkBlockParameters(gainObj,'Gain');

            if~isempty(resGain)
                gainValueSize=size(resGain{1});


                if isscalar(resGain{1})&&resGain{1}==1
                    uBlocks{end+1}=gainBlocks(idx);%#ok<AGROW>




                elseif~isscalar(resGain{1})&&size(gainValueSize,2)==2&&...
                    gainValueSize(1)==gainValueSize(2)
                    temp=resGain{1}==eye(gainValueSize(1));

                    if all(temp(:))
                        uBlocks{end+1}=gainBlocks(idx);%#ok<AGROW>
                    end
                else

                end
            end
        catch ME %#ok<NASGU>


        end
    end


    currentResult=uBlocks;
    currentResult=mdladvObj.filterResultWithExclusion(currentResult);
    if~isempty(currentResult)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'GainBlocksWarning']));
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'CheckGainBlocks']));
        ft.setListObj(currentResult);
        ResultDescription{end+1}=ft;
        bResultStatus=false;
    else
        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'GainBlocksPassed']));
        ResultDescription{end+1}=ft;
    end
