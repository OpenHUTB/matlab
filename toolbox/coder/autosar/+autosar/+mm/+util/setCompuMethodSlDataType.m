
function setCompuMethodSlDataType(m3iModel,m3iObj,slTypeNames,append)






    toolId=autosar.ui.metamodel.PackageString.SlDataTypesToolID;
    isa(m3iObj,autosar.ui.metamodel.PackageString.CompuMethodClass);
    if isempty(m3iObj)||~m3iObj.isvalid()||...
        ~isempty(slTypeNames)&&isa(m3iObj,autosar.ui.metamodel.PackageString.CompuMethodClass)...
        &&m3iObj.Category==Simulink.metamodel.types.CompuMethodCategory.RatFunc
        return;
    end
    if append
        slTypeNamesStr=m3iObj.getExternalToolInfo(toolId).externalId;
    else
        slTypeNamesStr='';
    end
    if numel(slTypeNames)>0
        newSlTypeNamesStr=slTypeNames{1};
        if numel(slTypeNames)>1
            for ii=2:numel(slTypeNames)
                newSlTypeNamesStr=[newSlTypeNamesStr,'#',slTypeNames{ii}];%#ok<AGROW>
            end
        end
        if isempty(slTypeNamesStr)
            slTypeNamesStr=newSlTypeNamesStr;
        elseif strcmp(slTypeNamesStr,newSlTypeNamesStr)



            return;
        else
            slTypeNamesStr=[slTypeNamesStr,'#',newSlTypeNamesStr];
        end
    end
    tranaction=M3I.Transaction(m3iModel);
    m3iObj.setExternalToolInfo(M3I.ExternalToolInfo(toolId,slTypeNamesStr));
    tranaction.commit();
end


