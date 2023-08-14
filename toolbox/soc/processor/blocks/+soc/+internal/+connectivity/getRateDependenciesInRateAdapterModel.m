function ratesDependencies=getRateDependenciesInRateAdapterModel(sys)




    import soc.internal.connectivity.*

    ratesDependencies=containers.Map('KeyType','double',...
    'ValueType','any');



    rtb=find_system(sys,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','on',...
    'BlockType','RateTransition');
    for i=1:numel(rtb)
        pc=get_param(rtb{i},'PortConnectivity');
        for j=1:numel(pc)
            if~isempty(pc(j).SrcBlock)
                res=get_param(pc(j).SrcBlock,'CompiledSampleTime');
                inpST=res(1);
            elseif~isempty(pc(j).DstBlock)
                res=get_param(pc(j).DstBlock,'CompiledSampleTime');
                outST=res(1);
            else
                assert(false,'Unconnected Rate Transition block');
            end
        end

        if iscell(outST),outST=outST{1};end
        if iscell(inpST),inpST=inpST{1};end
        outST=outST(1);
        inpST=inpST(1);
        if(outST>0)&&(inpST>0)
            if~ratesDependencies.isKey(outST)
                ratesDependencies(outST)=inpST;
            else
                ratesDependencies(outST)=[ratesDependencies(outST),inpST];
            end
        end
    end
end
