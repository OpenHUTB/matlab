function bResult=isInExcludedBlockList(Object,opt)
    bResult=false;
    [numRows,~]=size(opt.excludedBlks);
    for i=1:numRows
        if strcmp(get_param(Object,'Type'),'annotation')
            continue
        end
        if~strcmp(get_param(Object,'Type'),'block_diagram')&&isequal({get_param(Object,'BlockType'),get_param(Object,'MaskType')},opt.excludedBlks(i,:))
            bResult=true;
            return;
        end
    end

    if isInsideBuiltInBlock(Object)
        bResult=true;
    end
end

function InsidebuiltIn=isInsideBuiltInBlock(obj)
    InsidebuiltIn=false;

    if isnumeric(obj)||ischar(obj)
        obj=get_param(obj,'Object');
    end

    while~isa(obj,'Simulink.BlockDiagram')
        obj=obj.getParent;
        IsbuiltIn=isBuiltIn(obj);
        if IsbuiltIn
            InsidebuiltIn=true;
            return
        end
    end
end

function builtIn=isBuiltIn(obj)
    builtIn=false;


    if isa(obj,'Simulink.BlockDiagram')
        return;
    end

    refBlock='';
    isLinked=obj.isLinked();
    if isLinked&&isprop(obj,'ReferenceBlock')

        refBlock=obj.ReferenceBlock;
    end

    if~isempty(refBlock)



        libName=bdroot(refBlock);

        builtIn=contains(get_param(libName,'filename'),matlabroot)&&~contains(get_param(libName,'filename'),fullfile(matlabroot,'test'));

    end
end