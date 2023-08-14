function openImpl(model,isUIMode,updateModel)




    try
        lImpl(model,updateModel)
    catch e
        if isUIMode
            stage=Simulink.output.Stage('Statistics Viewer','ModelName',model,...
            'UIMode',true);%#ok<NASGU>
            Simulink.output.error(e,'Component','Simscape');
        else
            rethrow(e);
        end
    end



end

function lImpl(model,updateModel)


    simscape_model_statistics(model,true);


    c=onCleanup(@()(simscape_model_statistics(model,false)));


    if~bdIsLoaded(model)
        open_system(model);
    end








    if~lModelContainsPmBlocks(model)

        prefix='physmod:simscape:simscape:modelstatistics:modelstatistics';
        messageId=[prefix,':NoSimscapeBlocks'];
        dialogMessage=message(messageId,getfullname(model));
        error(dialogMessage);
    else

        if updateModel

            pm.sli.updateDiagram(model);
        else
            simscape_open_model_statistics(model,true);
            c=onCleanup(@()(simscape_open_model_statistics(model,false)));
        end


        simscape.modelstatistics.internal.addRenameCallback(model);


        simscape.modelstatistics.internal.addClearCallback(model);


        com.mathworks.physmod.common.statistics.gui.kernel.AppManager.toFront(model);
    end
end


function hasPmBlocks=lModelContainsPmBlocks(model)





    blockTypesRegex=char(join(string(pmsl_getblocktypes()),"|"));




    pmBlocks=find_system(model,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'regexp','on','Type','Block','BlockType',blockTypesRegex);



    if isempty(pmBlocks)


        neDomainBlocks=find_system(model,'FollowLinks','on','LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','SubSystem','PhysicalDomain','network_engine_domain');
        hasPmBlocks=~isempty(neDomainBlocks);
    else
        hasPmBlocks=true;
    end



end
