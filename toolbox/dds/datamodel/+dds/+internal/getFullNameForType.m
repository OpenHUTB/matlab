function fullName=getFullNameForType(typeObj,sep,useShortName)










    if~isempty(typeObj)
        model=mf.zero.getModel(typeObj);
        systemInModel=dds.internal.getSystemInModel(model);
    else
        systemInModel=[];
    end

    if nargin<3


        if~isempty(systemInModel)
            useShortName=dds.internal.isSystemUsingShortName(model);
        else
            useShortName=false;
        end
    end

    if nargin<2
        sep='_';
    end

    fullName=typeObj.getFullNameForType(sep,useShortName);
