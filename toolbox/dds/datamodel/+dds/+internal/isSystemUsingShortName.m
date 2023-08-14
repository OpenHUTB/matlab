function useShortName=isSystemUsingShortName(ddsMf0Model,systemInModel)











    useShortName=false;
    if nargin<2
        systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
    end
    if isempty(systemInModel)
        useShortName=true;
        return;
    end

    if~isempty(systemInModel.TypeMap)
        useShortName=systemInModel.TypeMap.UsingShortNames;
    else


        if systemInModel.TypeLibraries.Size==0
            useShortName=true;
        end
    end
end
