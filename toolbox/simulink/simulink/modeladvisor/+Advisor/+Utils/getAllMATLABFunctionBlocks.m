function functionBlocks=getAllMATLABFunctionBlocks(system,FollowLinks,LookUnderMasks)













    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,{'-isa','Stateflow.EMFunction'});



    slObjsCell=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'SFBlockType','MATLAB Function');


    slObjsCell=slObjsCell(cellfun(@(x)~Advisor.Utils.isChildOfShippingBlock(x)&&~(~strcmpi(get_param(x,'LinkStatus'),'none')&&strcmp(FollowLinks,'off')),slObjsCell));
    slObjs=cellfun(@(x)idToHandle(sfroot,sf('Private','block2chart',get_param(x,'handle'))),slObjsCell,'UniformOutput',false);




    slObjs=slObjs(cellfun(@(x)~isempty(x),slObjs));
    if~isempty(slObjs)
        for i=1:length(slObjs)
            obj_id=slObjs{i}.Id;
            hBlk=sf('Private','chart2block',obj_id);
            if strcmpi(get_param(bdroot(hBlk),'BlockDiagramType'),'library')
                activeInstanceH=sf('get',obj_id,'chart.activeInstance');
                if activeInstanceH==0||~ishandle(activeInstanceH)
                    sf('set',obj_id,'chart.activeInstance',get_param(slObjsCell{i},'handle'));
                end
            end
        end
    end


    functionBlocks=[slObjs;sfObjs];







    [~,idxOriginal,~]=unique(cellfun(@(x)x.Id,functionBlocks),'stable');
    functionBlocks=functionBlocks(idxOriginal);

end

