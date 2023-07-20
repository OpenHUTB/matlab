function ret=completions(node,arg)




    ret=[];
    try
        ret=simscape.logging.internal.node_completions(node,arg);
    catch ME
        ME.throwAsCaller();
    end
end
