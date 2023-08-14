function result=iscomponentspecified(hBlock)
    result=simscape.engine.sli.internal.issimscapeblock(hBlock)&&...
    ~isempty(simscape.getBlockComponent(hBlock));
end
