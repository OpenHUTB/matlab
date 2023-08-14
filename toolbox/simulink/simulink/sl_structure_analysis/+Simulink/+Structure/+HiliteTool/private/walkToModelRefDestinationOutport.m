function[refSegments,refBlocks]=walkToModelRefDestinationOutport(outportBlock)

    refSegments=[];
    refBlocks=[];

    blockType=get_param(outportBlock,'BlockType');
    parentGraph=get_param(outportBlock,'Parent');
    grandParentGraph=get_param(parentGraph,'Parent');



    if(~strcmpi(blockType,'outport')||~isempty(grandParentGraph))
        return;
    end

    parentHandle=get_param(parentGraph,'handle');


    [~,refBlocks]=getBdContainingModelRef(parentHandle);

    for i=1:length(refBlocks)
        refBlock=refBlocks(i);
        ports=get_param(refBlock,'PortHandles');
        if(~isempty(ports.Outport))
            ind=str2double(get_param(outportBlock,'Port'));
            refSegments=[refSegments;get_param(ports.Outport(ind),'line')];
        else
            refSegments=[refSegments;-1];
        end
    end

end