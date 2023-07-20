function out=getParameterInfo(ref,parameter)





    localConfigSet=ref.LocalConfigSet;
    if isempty(localConfigSet)

        localConfigSet=ref.getRefConfigSet;
    end


    out=configset.getParameterInfo(localConfigSet,parameter);
