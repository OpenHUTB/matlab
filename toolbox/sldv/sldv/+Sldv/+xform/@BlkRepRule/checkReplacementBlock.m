function checkReplacementBlock(obj,ReplacementPath,ReplacementLib,ReplacementBlk)




    if isempty(find_system('type','block_diagram','name',ReplacementLib))
        try
            obj.addToOpenedModelsList(ReplacementLib);
            Sldv.load_system(ReplacementLib);
        catch Mex
            newExc=MException('Sldv:xform:BlkRepRule:setReplacementPath:CannotLoadReplacementLib',...
            'The replacement library ''%s'' of the rule ''%s'' cannot be loaded.',ReplacementLib,obj.FileName);
            newExc=newExc.addCause(Mex);
            throw(newExc);
        end
    end

    if~strcmp(get_param(ReplacementLib,'BlockDiagramType'),'library')
        error(message('Sldv:xform:BlkRepRule:setReplacementPath:NotLibrary',ReplacementBlk,obj.FileName));
    end



    systems=find_system(ReplacementLib,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','Name',ReplacementBlk);
    if isempty(systems)||~any(strcmp(ReplacementPath,systems))
        error(message('Sldv:xform:BlkRepRule:setReplacementPath:BlockDoesNotExist',ReplacementBlk,obj.FileName,ReplacementLib));
    end



    if~isempty(find_system(ReplacementPath,'FirstResultOnly','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on','LookUnderMasks','all','BlockType','ModelReference'))
        error(message('Sldv:xform:BlkRepRule:setReplacementPath:ModelReference',ReplacementBlk,obj.FileName));
    end

    if strcmp(obj.BlockType,'ModelReference')
        blockObj=get_param(ReplacementPath,'Object');
        if isa(blockObj,'Simulink.SubSystem')
            ports=blockObj.Ports;
            if~strcmpi(blockObj.TreatAsAtomicUnit,'on')&&ports(3)==0&&ports(4)==0
                error(message('Sldv:xform:BlkRepRule:setReplacementPath:ModelReferenceReplacement',ReplacementPath,obj.FileName));
            end
        end
    end

    if slprivate('is_stateflow_based_block',ReplacementPath)
        error(message('Sldv:xform:BlkRepRule:setReplacementPath:StateFlowChart',ReplacementPath,obj.FileName));
    end

    machineId=sf('find','all','machine.name',ReplacementLib);
    if~isempty(machineId)&&machineId>0
        chartIds=sf('get',machineId,'.charts');
        if~isempty(chartIds)&&~all(sf('Private','is_eml_chart',chartIds))
            for chart=chartIds
                blockH=sf('Private','chart2block',chart);
                blockPath=getfullname(blockH);
                blockSlashes=find(blockPath=='/');
                if length(blockSlashes)>=2
                    blockParent=blockPath(1:blockSlashes(2)-1);
                else

                    blockParent=blockPath;
                end
                if strcmp(blockParent,ReplacementPath)
                    if~license('test','Stateflow')
                        error(message('Sldv:xform:BlkRepRule:setReplacementPath:NoStateFlowLicense',ReplacementPath,obj.FileName));
                    end
                end
            end
        end
    end
end
