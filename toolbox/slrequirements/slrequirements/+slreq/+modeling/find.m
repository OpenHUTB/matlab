function reqTableBlocks=find(input)







    reqTableBlocks=[];

    if nargin~=1
        error('Slvnv:reqmgt:specBlock:InvalidInputToFind',...
        DAStudio.message('Slvnv:reqmgt:specBlock:InvalidInputToFind'));
    end

    if slreq.modeling.isScalarText(input)||...
        (isa(input,'double')&&isscalar(input)&&input>0)


        blocks=find_system(input,'MatchFilter',@stateflowBlocks);
    else
        error('Slvnv:reqmgt:specBlock:InvalidInputToFind',...
        DAStudio.message('Slvnv:reqmgt:specBlock:InvalidInputToFind'));
    end

    if isa(blocks,'double')



        blocks=num2cell(blocks);
    end

    for i=1:numel(blocks)
        block=blocks{i};
        chartId=sfprivate('block2chart',block);
        chartH=sf('IdToHandle',chartId);
        isReqTable=Stateflow.ReqTable.internal.isRequirementsTable(chartH.Id);
        if~isReqTable
            continue;
        end
        sfReqTableBlock=Stateflow.ReqTable.internal.TableManager.getReqTableModel(chartH.Id);
        reqTableBlock=slreq.modeling.RequirementsTable(sfReqTableBlock,chartH);
        reqTableBlocks=[reqTableBlocks,reqTableBlock];%#ok<AGROW>
    end

    function match=stateflowBlocks(input)
        match=false;
        if strcmp(get_param(input,'Type'),'block')
            blockType=get_param(input,'BlockType');
            if strcmp(blockType,'SubSystem')&&~strcmp(get_param(input,'SFBlockType'),'NONE')
                match=true;
            end
        end
    end
end
