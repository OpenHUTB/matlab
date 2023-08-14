classdef TypeMappingDialog<handle



    properties
        importNode;
        externalTypesNames;
        typeNameToValueMap;
        externalToInternalMap;
    end

    methods
        function this=TypeMappingDialog(callerImportNode)
            this.importNode=callerImportNode;
            this.externalToInternalMap=containers.Map('KeyType','char','ValueType','char');
        end
    end

    methods
        function dlgstruct=getDialogSchema(this,dlg)%#ok<INUSD>

            panel=struct('Type','panel','Name',getString(message('Slvnv:slreq_objtypes:TypeMappingCaption')));

            typesTable=struct(...
            'Type','table',...
            'Tag','typeMappingTable',...
            'ColumnCharacterWidth',[20,20],...
            'ColumnStretchable',[0,0,0],...
            'Editable',true,...
            'SelectionBehavior','Row');

            this.externalTypesNames=this.getUniqueExternalTypes();

            for i=1:numel(this.externalTypesNames)
                externalTypeName=this.externalTypesNames{i};
                extType.Type='text';
                extType.Name=externalTypeName;

                mapsToCombo.Type='combobox';
                mapsToCombo.Tag=sprintf('TypeMapsToCombo%d',i);
                registeredTypeNames=slreq.app.RequirementTypeManager.getAllDisplayNames();
                customTypePlaceholderLabel=getString(message('Slvnv:slreq_objtypes:TypeMappingAddType'));
                mapsToCombo.Entries=[registeredTypeNames,{customTypePlaceholderLabel}];
                this.updateTypeNameToValueMap(mapsToCombo.Entries);
                mapsToCombo.Values=(1:numel(mapsToCombo.Entries));
                matchIdx=[];
                if isKey(this.externalToInternalMap,externalTypeName)
                    internalTypeName=this.externalToInternalMap(externalTypeName);
                    matchIdx=find(strcmp(registeredTypeNames,internalTypeName));
                end
                if~isempty(matchIdx)
                    mapsToCombo.Value=matchIdx;
                else


                    functionalName=getString(message('Slvnv:slreq:RequirementTypeFunctional'));
                    mapsToCombo.Value=find(strcmp(registeredTypeNames,functionalName));
                    this.externalToInternalMap(externalTypeName)=functionalName;
                end
                mapsToCombo.Editable=true;

                typesTable.Data(i,1:2)={extType,mapsToCombo};
            end

            typesTable.ReadOnlyColumns=0;

            typesTable.ColHeader={...
            getString(message('Slvnv:slreq_objtypes:TypeMappingImportedType')),...
            getString(message('Slvnv:slreq_objtypes:TypeMappingInternalType'))};
            typesTable.Size=size(typesTable.Data);
            typesTable.HeaderVisibility=[0,1];

            typesTable.ValueChangedCallback=@this.mappingChanged;

            typesTable.RowSpan=[1,2];
            typesTable.ColSpan=[1,2];

            panel.Items={typesTable};

            dlgstruct.DialogTitle=getString(message('Slvnv:slreq_objtypes:TypeMappingTitle'));
            dlgstruct.DialogTag='SlreqTypeMappingDialog';
            dlgstruct.StandaloneButtonSet={'OK','Cancel'};
            dlgstruct.Items={panel};

            dlgstruct.CloseMethod='dlgCloseMethod';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};

            dlgstruct.Geometry=[500,300,550,300];
            dlgstruct.Sticky=true;
        end

        function mappingChanged(this,dlg,row,col,~)
            externalTypeName=this.externalTypesNames{row+1};
            mappedValue=dlg.getTableItemValue('typeMappingTable',row,col);
            if strcmp(mappedValue,getString(message('Slvnv:slreq_objtypes:TypeMappingAddType')))
                this.addCustomType(dlg,row);
                dlg.refresh();
            else
                this.externalToInternalMap(externalTypeName)=mappedValue;
            end
        end

        function updateMapping(this,row,internalTypeName)
            this.externalToInternalMap(this.externalTypesNames{row})=internalTypeName;
        end

        function addCustomType(this,dlg,row)
            dlgObj=slreq.gui.AddSubTypeDialog(this,dlg,row+1);
            DAStudio.Dialog(dlgObj);
        end

        function dlgCloseMethod(this,~,actionStr)
            if strcmpi(actionStr,'ok')
                count=this.importNode.updateMappedTypes(this.externalToInternalMap);
                msgbox([num2str(count),' items updated']);


            end
        end

        function sortedTypeNames=getUniqueExternalTypes(this)
            externalTypes={};
            getTypesFromChildren(this.importNode.children);
            sortedTypeNames=sort(externalTypes);

            function getTypesFromChildren(dataReqs)
                for i=1:numel(dataReqs)
                    dataReq=dataReqs(i);
                    extType=dataReq.externalTypeName;
                    if~any(ismember(extType,externalTypes))
                        externalTypes{end+1}=extType;%#ok<AGROW>
                    end
                    getTypesFromChildren(dataReq.children);
                end
            end
        end

        function updateTypeNameToValueMap(this,orderedTypeNames)
            this.typeNameToValueMap=containers.Map(orderedTypeNames,1:numel(orderedTypeNames));
        end

    end
end
