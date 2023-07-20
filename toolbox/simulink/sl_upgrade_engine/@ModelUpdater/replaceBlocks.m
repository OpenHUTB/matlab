function replaceBlocks(h,ReplaceInfo)










    for i=1:size(ReplaceInfo,1)



        args=ReplaceInfo(i).BlockDesc;


        blocks=find_system(h.UpdateContext,...
        'LookUnderMasks','all',...
        'LookInsideSubsystemReference','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        args{:});


        passData=false;
        if isfield(ReplaceInfo,'data')
            data=ReplaceInfo(i).data;
            if~isempty(data)
                passData=true;
            end
        end


        for j=1:numel(blocks)
            try
                if passData
                    feval(ReplaceInfo(i).ReplaceFcn,blocks{j},h,data);
                else
                    feval(ReplaceInfo(i).ReplaceFcn,blocks{j},h);
                end

            catch e %#ok<NASGU>
                msgID='SimulinkUpgradeEngine:engine:problemUpdatingBlock';
                msg=DAStudio.message(msgID,blocks{j});
                appendTransaction(h,blocks{j},msg,{});
            end
        end

    end

end
