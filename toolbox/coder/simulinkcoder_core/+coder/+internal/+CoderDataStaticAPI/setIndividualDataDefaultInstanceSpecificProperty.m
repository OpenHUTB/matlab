

function setIndividualDataDefaultInstanceSpecificProperty(sourceDD,modelElementType,prop,value)
    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    modelElementType=coder.internal.CoderDataStaticAPI.convertToInternalCategoryName(modelElementType);
    dd=hlp.openDD(sourceDD);
    swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
    dataConfig=hlp.getProp(swc,modelElementType);
    instSpecificSchema=hlp.getProp(dataConfig,'InitialCSCAttributesSchema');
    hasProp=false;
    instSp=[];

    if~isempty(instSpecificSchema)
        instSp=jsondecode(instSpecificSchema);
        for i=1:length(instSp)
            if strcmp(instSp(i).Name,prop)
                instSp(i).Value=value;
                hasProp=true;
                break;
            end
        end
    end

    if~hasProp
        newInstSp=struct('Name',prop,'Value','');
        sc=hlp.getProp(dataConfig,'InitialStorageClass');
        if~isempty(sc)
            scSchema=hlp.getProp(sc,'CSCAttributesSchema');
            scInstSp=jsondecode(scSchema);
            for i=1:length(scInstSp)
                if strcmp(scInstSp(i).Name,prop)
                    newInstSp.Value=value;
                    if~isempty(value)
                        newInstSp.DisplayValue=newInstSp.Value;
                    else
                        newInstSp.DisplayValue='<Instance specific>';
                    end

                    if isempty(instSp)
                        instSp=newInstSp;
                    else
                        instSp(end+1)=newInstSp;%#ok
                    end
                    hasProp=true;
                    break;
                end
            end
        end
    end
    if hasProp
        hlp.setProp(dataConfig,'InitialCSCAttributesSchema',jsonencode(instSp));
    else
        DAStudio.error('coderdictionary:api:invalidAttributeName',prop);
    end
end
