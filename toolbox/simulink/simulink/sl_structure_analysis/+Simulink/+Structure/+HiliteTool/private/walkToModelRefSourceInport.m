function[refSegments,refBlocks]=walkToModelRefSourceInport(inportBlock)

    refSegments=[];
    refBlocks=[];

    blockType=get_param(inportBlock,'BlockType');
    parentGraph=get_param(inportBlock,'Parent');
    grandParentGraph=get_param(parentGraph,'Parent');



    if(~strcmpi(blockType,'Inport')||~isempty(grandParentGraph))
        return;
    end

    parentHandle=get_param(parentGraph,'handle');

    [~,refBlocks]=getBdContainingModelRef(parentHandle);

    for i=1:length(refBlocks)
        refBlock=refBlocks(i);
        ports=get_param(refBlock,'PortHandles');

        if(~isempty(ports.Inport))
            ind=str2double(get_param(inportBlock,'Port'));
            refSegments=[refSegments;get_param(ports.Inport(ind),'line')];
        else
            refSegments=[refSegments;-1];
        end
    end

end