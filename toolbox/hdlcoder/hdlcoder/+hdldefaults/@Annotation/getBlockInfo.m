function[isDoc,isMdlInfo]=getBlockInfo(this,hC)%#ok<INUSL>



    slbh=hC.SimulinkHandle;

    isDoc=isDocBlock(slbh);
    isMdlInfo=isModelInfo(slbh);

end

function db=isDocBlock(slbh)
    db=false;

    if strcmp(get_param(slbh,'Type'),'block')&&...
        strcmp(get_param(slbh,'BlockType'),'SubSystem')
        rb=get_param(slbh,'ReferenceBlock');
        rb=strrep(rb,char(10),' ');
        if strcmp(rb,'simulink/Model-Wide Utilities/DocBlock')
            db=true;
        end
    end
end

function mi=isModelInfo(slbh)
    mi=false;

    if~(strcmp(get_param(slbh,'Type'),'annotation'))
        rb=get_param(slbh,'ReferenceBlock');
        rb=strrep(rb,char(10),' ');
        if strcmp(rb,'simulink/Model-Wide Utilities/Model Info')
            mi=true;
        end
    end
end

