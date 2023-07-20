function[rowSpan,tabItems]=getSchema(sourceModel,sourceBlock,...
    enable,rowSpan,tabItems)





    [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(sourceModel);
    modelH=get_param(sourceModel,'Handle');
    if strcmp(mappingType,'AutosarTarget')
        mapObj=autosar.api.getSimulinkMapping(sourceModel);
        slPortName=get_param(sourceBlock,'Name');

        [arPortName,arElementName,arDataAccessMode]=mapObj.getInport(slPortName);
        isMode=false;
        if strcmp(arDataAccessMode,'ModeReceive')
            category='ModeReceiverPort';
            isMode=true;
        else
            category='DataReceiverPort';
        end
        ports={DAStudio.message('RTW:autosar:selectERstr')};
        dataElements={DAStudio.message('RTW:autosar:selectERstr')};
        if enable
            ports=[ports,autosar.mm.Model.findObjectNamesByCategory(sourceModel,category)];
            if~isMode
                additionalPorts=autosar.mm.Model.findObjectNamesByCategory(sourceModel,'DataSenderReceiverPort');
                ports=[ports,additionalPorts];
            end
            dataElements=[dataElements,autosar.mm.Model.findContaineeElementsByPortName(sourceModel,arPortName)];
            accessModes=autosar.ui.configuration.PackageString.ReceiverDataAccess;
            if slfeature('E2ECodeGenSupport')==0
                ind=ismember(accessModes,'EndToEndQueuedReceive');
                accessModes(ind)=[];
            end
        else
            accessModes={arDataAccessMode};
            ports=[ports,arPortName];
            dataElements=[dataElements,arElementName];
        end

        lblDataAccessMode.Tag='lblDataAccessMode';
        lblDataAccessMode.Type='text';
        lblDataAccessMode.Name='DataAccessMode';
        lblDataAccessMode.RowSpan=[rowSpan,rowSpan];
        lblDataAccessMode.ColSpan=[1,1];

        cmbDataAccessMode.Tag='cmbDataAccessMode';
        cmbDataAccessMode.Type='combobox';
        cmbDataAccessMode.Mode=true;
        cmbDataAccessMode.Name=lblDataAccessMode.Name;
        cmbDataAccessMode.HideName=true;

        cmbDataAccessMode.Value=Simulink.CodeMapping.comboboxEntryToIndex(accessModes,arDataAccessMode);
        cmbDataAccessMode.Entries=accessModes;
        cmbDataAccessMode.RowSpan=[rowSpan,rowSpan];
        cmbDataAccessMode.ColSpan=[2,2];

        cmbDataAccessMode.MatlabMethod='Simulink.CodeMapping.autosarMappingChanged';
        cmbDataAccessMode.MatlabArgs={'%dialog',sourceModel,slPortName,'DataAccessMode'};
        tabItems=cat(2,tabItems,{lblDataAccessMode,cmbDataAccessMode});

        rowSpan=rowSpan+1;

        lblPort.Tag='lblPort';
        lblPort.Type='text';
        lblPort.Name='Port';
        lblPort.RowSpan=[rowSpan,rowSpan];
        lblPort.ColSpan=[1,1];

        cmbPort.Tag='cmbPort';
        cmbPort.Mode=true;
        cmbPort.Type='combobox';
        cmbPort.Name=lblPort.Name;
        cmbPort.HideName=true;

        cmbPort.Value=Simulink.CodeMapping.comboboxEntryToIndex(ports,arPortName);
        cmbPort.Entries=ports;
        cmbPort.RowSpan=[rowSpan,rowSpan];
        cmbPort.ColSpan=[2,2];

        cmbPort.MatlabMethod='Simulink.CodeMapping.autosarMappingChanged';
        cmbPort.MatlabArgs={'%dialog',sourceModel,slPortName,'Port'};
        tabItems=cat(2,tabItems,{lblPort,cmbPort});

        rowSpan=rowSpan+1;

        lblElement.Tag='lblElement';
        lblElement.Type='text';
        lblElement.Name='Element';
        lblElement.RowSpan=[rowSpan,rowSpan];
        lblElement.ColSpan=[1,1];

        cmbElement.Tag='cmbElement';
        cmbElement.Mode=true;
        cmbElement.Type='combobox';
        cmbElement.Name=lblElement.Name;
        cmbElement.HideName=true;

        cmbElement.Value=Simulink.CodeMapping.comboboxEntryToIndex(dataElements,arElementName);
        cmbElement.Entries=dataElements;
        cmbElement.RowSpan=[rowSpan,rowSpan];
        cmbElement.ColSpan=[2,2];

        cmbElement.MatlabMethod='Simulink.CodeMapping.autosarMappingChanged';
        cmbElement.MatlabArgs={'%dialog',sourceModel,slPortName,'Element'};
        tabItems=cat(2,tabItems,{lblElement,cmbElement});

        rowSpan=rowSpan+1;
    elseif strcmp(mappingType,'CoderDictionary')
        sourceBlock=strrep(sourceBlock,newline,' ');
        mapObj=mapping.Inports.findobj('Block',sourceBlock);

        if isempty(mapObj.MappedTo)
            [hasNonAutoStorageClass,propValue]=Simulink.CodeMapping.isSignalObjectSpecified(sourceModel,sourceBlock,true);
            if~hasNonAutoStorageClass
                coderData=DAStudio.message('coderdictionary:mapping:NoMapping');
                propValue='';
            else
                coderData='';
            end
        else
            coderData=mapObj.getDecoratedStorageClass();
            propValue='';
        end
        items={};

        lblCoderData.Tag='lblCoderData';
        lblCoderData.Type='text';
        lblCoderData.Name='StorageClass';
        lblCoderData.RowSpan=[rowSpan,rowSpan];
        lblCoderData.ColSpan=[1,1];

        items=[items,lblCoderData];
        cmbCoderData.Tag='cmbCoderData';
        cmbCoderData.Mode=true;
        cmbCoderData.Name=lblCoderData.Name;
        cmbCoderData.HideName=true;

        if~isempty(propValue)
            cmbCoderData.Type='edit';
            cmbCoderData.Enabled=false;
            cmbCoderData.Value=propValue;
        else
            cmbCoderData.Type='combobox';
            coderDataElems=mapping.DefaultsMapping.getAllowedGroupNames('Inports','IndividualLevel')';
            cmbCoderData.Value=Simulink.CodeMapping.comboboxEntryToIndex(coderDataElems,coderData);
            cmbCoderData.Entries=coderDataElems;
        end
        cmbCoderData.RowSpan=[rowSpan,rowSpan];
        cmbCoderData.ColSpan=[2,2];

        cmbCoderData.MatlabMethod='Simulink.CodeMapping.ertMappingChanged';
        cmbCoderData.MatlabArgs={'%dialog',mapObj,mapping};
        items=[items,cmbCoderData];
        if~isempty(mapObj.MappedTo)
            properties=mapObj.MappedTo.getCSCAttributeNames(modelH);
            for ii=1:numel(properties)
                rowSpan=rowSpan+1;
                lblISPropDataText.Tag=['lblISPropDataText',num2str(ii)];
                lblISPropDataText.Type='text';
                lblISPropDataText.Name=properties{ii};
                lblISPropDataText.RowSpan=[rowSpan,rowSpan];
                lblISPropDataText.ColSpan=[1,1];
                items=[items,lblISPropDataText];%#ok<AGROW>
                lblISPropDataCtrl.Tag=['lblISPropDataCtrl',num2str(ii)];
                lblISPropDataCtrl.Mode=true;
                lblISPropDataCtrl.HideName=true;
                propValue=Simulink.CodeMapping.getPerInstancePropertyValue(modelH,mapObj,'MappedTo',properties{ii});
                dataType=Simulink.CodeMapping.getPerInstancePropertyDataType(modelH,mapObj,'MappedTo',properties{ii});
                if strcmp(dataType,'enum')
                    lblISPropDataCtrl.Type='combobox';

                    allowedValues=Simulink.CodeMapping.getPerInstancePropertyAllowedValues(mapObj,properties{ii});

                    lblISPropDataCtrl.Value=Simulink.CodeMapping.comboboxEntryToIndex(allowedValues,propValue);
                    lblISPropDataCtrl.Entries=allowedValues;

                elseif strcmp(dataType,'bool')
                    lblISPropDataCtrl.Type='checkbox';
                    if strcmp(propValue,'1')
                        lblISPropDataCtrl.Value=true;
                    else
                        lblISPropDataCtrl.Value=false;
                    end
                else
                    lblISPropDataCtrl.Type='edit';
                    lblISPropDataCtrl.Enabled=true;
                    lblISPropDataCtrl.Value=propValue;
                end
                lblISPropDataCtrl.MatlabMethod='Simulink.CodeMapping.PerInstancePropertyChanged';
                lblISPropDataCtrl.MatlabArgs={'%dialog',lblISPropDataCtrl.Tag,modelH,mapObj,properties{ii}};
                lblISPropDataCtrl.RowSpan=[rowSpan,rowSpan];
                lblISPropDataCtrl.ColSpan=[2,2];
                items=[items,lblISPropDataCtrl];%#ok<AGROW>
            end
        end

        tabItems=cat(2,tabItems,items);

        rowSpan=rowSpan+1;
    end
end
