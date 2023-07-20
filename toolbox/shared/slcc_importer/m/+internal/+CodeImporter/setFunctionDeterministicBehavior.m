function setFunctionDeterministicBehavior(obj,hMdl)

    fcn=obj.ParseInfo.Functions;
    isFcnDeterministic=[fcn.IsDeterministic];
    if all(isFcnDeterministic)
        set_param(hMdl,'DefaultCustomCodeDeterministicFunctions','All');
    elseif all(~isFcnDeterministic)
        set_param(hMdl,'DefaultCustomCodeDeterministicFunctions','None');
    else
        set_param(hMdl,'DefaultCustomCodeDeterministicFunctions','ByFunction');
        fcn(~isFcnDeterministic)=[];
        set_param(hMdl,'CustomCodeDeterministicFunctions',strjoin([fcn.Name],','));
    end
end
