function nesl_version_forwarding(hSlLibrary,libDataStructure,packageName)










    if~libDataStructure.lib.SourceExists
        return;
    end

    try
        [~,forwards]=simscape.versioning.internal.libversion(packageName);
    catch

        return;
    end


    [transformPths,forwardPths]=lGetForwardBlocks(hSlLibrary,forwards.sl);


    if simscape.versioning.internal.enabled
        [sscTps,sscFps]=lGetForwardBlocks(hSlLibrary,forwards.ssc);
        transformPths=[transformPths,...
        sscTps];
        forwardPths=[forwardPths,...
        sscFps];
    end

    allPths=unique([transformPths,forwardPths]);

    ft=get_param(hSlLibrary,'ForwardingTable');
    for idx=1:numel(allPths)
        blockPth=allPths{idx};
        lFwdExist(ft,blockPth);

        if any(strcmp(forwardPths,blockPth))||...
            simscape.versioning.internal.enabled



            ft{end+1}={blockPth,'',...
            'simscape.versioning.internal.transformationFunction'};%#ok
        else
            ft{end+1}={blockPth,blockPth,'0.0',get_param(hSlLibrary,'ModelVersion'),...
            'simscape.versioning.internal.transformationFunction'};%#ok
        end
    end
    set_param(hSlLibrary,'ForwardingTable',ft);

end




function[transformPths,forwardPths]=lGetForwardBlocks(hSlLibrary,forwards)


    blocks=find_system(hSlLibrary,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SimscapeBlock');
    sourceFiles=get_param(blocks,'SourceFile');

    transformPths={};
    forwardPths={};
    for idx=1:numel(forwards)
        forward=forwards(idx);

        if isempty(forward.OldSimulinkPath)
            sFidx=find(strcmp(sourceFiles,forward.OldSimscapePath),1);
            if~isempty(sFidx)
                transformPths{end+1}=getfullname(blocks(sFidx));%#ok
            else


            end
        else
            forwardPths{end+1}=forward.OldSimulinkPath;%#ok
        end
    end
end

function lFwdExist(ft,blockPth)
    if isempty(ft)
        return;
    end

    ftblocks=cellfun(@(x)x(1),ft);
    if any(strcmp(ftblocks,blockPth))

        pm_error('physmod:ne_sli:versioning:CannotForwardBlock',blockPth);
    end
end
