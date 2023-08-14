function prompt=parameterpromptfromblock(parameter,block)





    prompt='';
    p=pm.sli.internal.getMaskParameterRecursive(block,parameter);
    if~isempty(p)
        prompt=p.Prompt;
    end

end

