
function unAssignSimulinkDataType(m3iObject,parentDlg)





    modelM3I=m3iObject.modelM3I;
    assert(modelM3I.RootPackage.size==1);
    toolId=autosar.ui.metamodel.PackageString.SlDataTypesToolID;
    slTypeNamesStr=m3iObject.getExternalToolInfo(toolId).externalId;
    entries=regexp(slTypeNamesStr,'#','split');
    index=parentDlg.getWidgetValue('slDataTypeList')+1;
    if~isempty(index)
        selectedEntries=cell(numel(index),0);
        for ii=1:numel(index)
            selectedEntries{ii}=entries{index(ii)};
        end
        entries=setdiff(entries,selectedEntries);
        autosar.mm.util.setCompuMethodSlDataType(modelM3I,m3iObject,entries,false);
        parentDlg.apply;
        parentDlg.refresh();
    end

end


