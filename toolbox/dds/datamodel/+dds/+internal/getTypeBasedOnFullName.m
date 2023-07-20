function typeObj=getTypeBasedOnFullName(fullName,model,useShortName,varargin)

























    typeObj=[];
    systemInModel=dds.internal.getSystemInModel(model);
    if nargin<3
        useShortName=false;
        if~isempty(systemInModel)
            useShortName=dds.internal.isSystemUsingShortName(model,systemInModel);
        end
    end
    if useShortName

        ent=systemInModel.TypeMap.Map{fullName};
        if~isempty(ent)
            typeObj=ent.Element;
        end
    else
        try
            fullNameVisitor=dds.internal.GetFullNamesVisitor(varargin{:});
            fullNameVisitor.visitModel(model);
            if fullNameVisitor.TypesMap.isKey(fullName)
                typeObj=model.findElement(fullNameVisitor.TypesMap(fullName));
            end
        catch
        end
    end
