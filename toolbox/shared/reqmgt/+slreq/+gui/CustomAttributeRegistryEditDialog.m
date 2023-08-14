classdef CustomAttributeRegistryEditDialog<handle





    properties
        reqSetDas;
        reqData;
        Name='';
        TypeName;
        InitialValue='';
        Description='';

        SelectionList={'Unset'};
        isRemoveEnabled=false;
        selectedIndex=[];
        editMode=false;
        CheckboxDefault=false;
        isReqUsedForExternalReq=false;
    end

    methods
        function this=CustomAttributeRegistryEditDialog(reqSetDas)
            this.reqSetDas=reqSetDas;
            this.TypeName=slreq.datamodel.AttributeRegType.Edit;
            this.reqData=slreq.data.ReqData.getInstance;
        end




        function enumList=getEnumList(this)











            enumList=[slreq.datamodel.AttributeRegType.Edit,...
            slreq.datamodel.AttributeRegType.Checkbox,...
            slreq.datamodel.AttributeRegType.Combobox,...
            slreq.datamodel.AttributeRegType.DateTime];
        end

        function dlgstruct=getDialogSchema(this,~)

            customAttrPanel=struct('Type','panel','Name',getString(message('Slvnv:slreq:CustomAttributeRegistries')),'Tag','CustomAttrRegs');
            customAttrPanel.Expand=slreq.gui.togglePanelHandler('get',customAttrPanel.Tag,false);
            customAttrPanel.ExpandCallback=@slreq.gui.togglePanelHandler;

            nametext=struct('Type','text','Name',getString(message('Slvnv:slreq:NameColon')),'RowSpan',[1,1],'ColSpan',[1,1]);
            nameEdit=struct('Type','edit','Tag','Name','RowSpan',[1,1],'ColSpan',[2,3]);
            nameEdit.Value=this.Name;
            if this.isReqUsedForExternalReq
                nameEdit.Enabled=false;
                nameEdit.ToolTip=getString(message('Slvnv:slreq:ReadOnlyCustomAttributeTooltip'));
            end

            typeText=struct('Type','text','Name',getString(message('Slvnv:slreq:TypeColon')),'RowSpan',[2,2],'ColSpan',[1,1]);
            typeList=struct('Type','combobox','Tag','TypeName','RowSpan',[2,2],'ColSpan',[2,2]);

            enumList=this.getEnumList();
            dispList=cell(1,length(enumList));
            selectedIdx=1;
            for m=1:length(enumList)
                if enumList(m)==this.TypeName
                    selectedIdx=m;
                end
                dispList{m}=enumList(m).char;
            end
            typeList.Entries=dispList;
            typeList.Value=selectedIdx-1;
            typeList.ObjectMethod='typeChangedCallback';
            typeList.MethodArgs={'%dialog','%value'};
            typeList.ArgDataTypes={'handle','mxArray'};
            typeList.Enabled=~this.editMode;
            customAttrPanel.Items={nametext,nameEdit,typeText,typeList};
            customAttrPanel.RowStretch=[0,0];

            defaultValuetext=struct('Type','text','Name',getString(message('Slvnv:slreq:DefaultValueColon')),'RowSpan',[3,3],'ColSpan',[1,1]);
            customAttrPanel.RowStretch(3)=0;
            nRow=4;
            switch this.TypeName
            case slreq.datamodel.AttributeRegType.Checkbox
                defaultValueEdit=struct('Type','checkbox','Tag','defaultValue','RowSpan',[3,3],'ColSpan',[2,3]);
                defaultValueEdit.Enabled=~this.editMode;
                defaultValueEdit.Value=this.CheckboxDefault;
                customAttrPanel.Items{end+1}=defaultValueEdit;
            case slreq.datamodel.AttributeRegType.Combobox
                nRow=nRow+1;
                defaultValuetext.Name=getString(message('Slvnv:slreq:SelectionList'));
                defaultValueTable=struct('Type','table','Tag','Combobox','RowSpan',[3,nRow],'ColSpan',[2,2],'ColumnStretchable',1,'Graphical',true);
                defaultValueTable.ToolTip=getString(message('Slvnv:slreq:DoubleClickToEdit'));
                defaultValueTable.Editable=this.isRemoveEnabled;
                defaultValueTable.Data=this.SelectionList;
                defaultValueTable.ColHeader={getString(message('Slvnv:slreq:List'))};
                defaultValueTable.ValueChangedCallback=@(dlg,row,col,val)this.ValueChangedCallback(dlg,row,col,val);
                defaultValueTable.CurrentItemChangedCallback=@(dlg,row,col)this.CurrentItemChangedCallback(dlg,row,col);
                defaultValueTable.Size=size(this.SelectionList);
                defaultValueTable.PreferredSize=[-1,150];
                defaultValueTable.HeaderVisibility=[1,1];
                defaultValueAdd=struct('Type','pushbutton','Name',getString(message('Slvnv:slreq:Add')),'Tag','defaultValueAdd','RowSpan',[3,3],'ColSpan',[3,3]);
                defaultValueAdd.ObjectMethod='addRowToList';
                defaultValueAdd.MethodArgs={'%dialog'};
                defaultValueAdd.ArgDataTypes={'handle'};

                defaultValueRemove=struct('Type','pushbutton','Name',getString(message('Slvnv:slreq:Remove')),'Tag','defaultValueEdit','RowSpan',[4,4],'ColSpan',[3,3]);
                defaultValueRemove.Enabled=this.isRemoveEnabled;
                defaultValueRemove.ObjectMethod='removeRowFromList';
                defaultValueRemove.MethodArgs={'%dialog'};
                defaultValueRemove.ArgDataTypes={'handle'};
                customAttrPanel.Items=[customAttrPanel.Items,{defaultValueTable,defaultValueAdd,defaultValueRemove}];
                customAttrPanel.RowStretch(3)=0;
                customAttrPanel.RowStretch(4)=0;
                customAttrPanel.RowStretch(5)=1;

                nRow=nRow+1;
            case slreq.datamodel.AttributeRegType.Edit

                defaultValuetext.Visible=false;
            case slreq.datamodel.AttributeRegType.DateTime
                defaultValuetext.Visible=false;

            end

            descriptionValuetext=struct('Type','text','Name',getString(message('Slvnv:slreq:DescriptionColon')),'RowSpan',[nRow,nRow],'ColSpan',[1,1],'Alignment',2);
            descriptionEdit=struct('Type','editarea','Tag','description','RowSpan',[nRow,nRow],'ColSpan',[2,3]);
            descriptionEdit.Value=this.Description;
            customAttrPanel.RowStretch(nRow)=0;

            customAttrPanel.Items=[customAttrPanel.Items,{defaultValuetext,descriptionValuetext,descriptionEdit}];
            customAttrPanel.LayoutGrid=[nRow,3];
            customAttrPanel.ColStretch=[0,1,0];
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq:CustomAttributeRegistration'));
            dlgstruct.StandaloneButtonSet={'OK','Cancel'};
            dlgstruct.Items={customAttrPanel};

            dlgstruct.CloseMethod='dlgCloseMethod';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};
            dlgstruct.PreApplyMethod='dlgPreApplyMethod';
            dlgstruct.PreApplyArgs={'%dialog'};
            dlgstruct.PreApplyArgsDT={'handle'};

            dlgstruct.Sticky=true;
        end

        function[tf,msg]=dlgPreApplyMethod(this,dlg)
            tf=true;
            msg='';
            name=dlg.getWidgetValue('Name');
            selectedDataType=getSelectedDataType(this,dlg);
            [isValidName,invalidChars]=slreq.internal.isValidCustomAttributeName(name);

            if isempty(name)
                tf=false;
                msg=getString(message('Slvnv:slreq:InvalidName'));
            elseif~isValidName
                tf=false;
                msg=getString(message('Slvnv:slreq:AttributeNameIsInvalid',cell2mat(invalidChars)));
            elseif selectedDataType==slreq.datamodel.AttributeRegType.Combobox...
                &&numel(this.SelectionList)~=numel(unique(this.SelectionList))
                tf=false;
                msg=getString(message('Slvnv:slreq:AttributeComboboxNameShouldBeUnique'));
            else
                attrRegistries=this.reqData.getCustomAttributeRegistries(this.reqSetDas.dataModelObj);
                if this.editMode
                    if~strcmp(name,this.Name)
                        attrReg=attrRegistries.getByKey(name);
                    else
                        attrReg=[];
                    end
                else
                    attrReg=attrRegistries.getByKey(name);
                end
                if~isempty(attrReg)
                    tf=false;
                    msg=getString(message('Slvnv:slreq:AttributeExists'));
                end
            end
        end

        function dlgCloseMethod(this,dlg,actionStr)
            if strcmp(actionStr,'ok')
                name=dlg.getWidgetValue('Name');
                defaultValOrEnumList=dlg.getWidgetValue('defaultValue');
                description=dlg.getWidgetValue('description');
                selectedDataType=getSelectedDataType(this,dlg);
                if selectedDataType==slreq.datamodel.AttributeRegType.Combobox
                    defaultValOrEnumList=this.SelectionList;
                end

                try
                    if~this.editMode
                        this.reqData.addCustomAttributeRegistry(this.reqSetDas.dataModelObj,...
                        name,selectedDataType,description,defaultValOrEnumList,false);
                    else
                        if this.editMode&&this.TypeName==slreq.datamodel.AttributeRegType.Combobox

                            attrRegistries=this.reqData.getCustomAttributeRegistries(this.reqSetDas.dataModelObj);
                            attrReg=attrRegistries.getByKey(this.Name);
                            existingList=attrReg.entries.toArray';
                            diffList=setdiff(existingList,this.SelectionList);
                            if~isempty(diffList)&&attrReg.items.Size>0&&...
                                ~slreq.custom.AttributeHandler.hasOnlyNameChange(existingList,this.SelectionList)
                                ButtonName=questdlg(...
                                getString(message('Slvnv:slreq:AttributeComboboxEntryChangeQuestionBody')),...
                                getString(message('Slvnv:slreq:AttributeComboboxEntryChangeQuestionTitle')),...
                                getString(message('Slvnv:slreq:Yes')),getString(message('Slvnv:slreq:No')),getString(message('Slvnv:slreq:No')));
                                if strcmp(ButtonName,getString(message('Slvnv:slreq:No')))
                                    return;
                                end
                            end
                        end

                        this.reqData.modifyCustomAttributeRegistry(this.reqSetDas.dataModelObj,...
                        this.Name,name,selectedDataType,description,defaultValOrEnumList)


                    end
                catch ex
                    errordlg(ex.message,getString(message('Slvnv:slreq:Error')),'modal')
                    return;
                end

                this.reqSetDas.selectedCustomAttribute=name;
                this.reqSetDas.view.update;
                this.reqSetDas.view.getCurrentView.setSelectedObject(this.reqSetDas);
            end
        end

        function selectedDataType=getSelectedDataType(this,dlg)
            enumList=this.getEnumList();
            selectedList=dlg.getWidgetValue('TypeName')+1;
            selectedDataType=enumList(selectedList).char;
        end

        function typeChangedCallback(this,dlg,value)
            selectedIdx=value+1;
            enumList=this.getEnumList();
            this.TypeName=enumList(selectedIdx);
            dlg.refresh
        end

        function addRowToList(this,dlg)
            this.SelectionList=[this.SelectionList;'?'];
            dlg.refresh;
        end

        function removeRowFromList(this,dlg)
            if~isempty(this.selectedIndex)&&numel(this.SelectionList)>=this.selectedIndex
                this.SelectionList(this.selectedIndex)=[];
            end

            this.isRemoveEnabled=length(this.SelectionList)>1;
            dlg.refresh;
        end

        function ValueChangedCallback(this,dlg,row,col,val)
            if row~=0
                this.SelectionList{row+1,col+1}=val;
            else

                dlg.refresh();
            end
        end

        function CurrentItemChangedCallback(this,dlg,row,col)%#ok<INUSD>
            this.selectedIndex=row+1;
            if row==0
                this.isRemoveEnabled=false;
            else
                this.isRemoveEnabled=true;
            end
            dlg.refresh;
        end

        function setForEdit(this,attr)

            this.editMode=true;
            this.TypeName=attr.typeName;
            this.Name=attr.name;
            this.Description=attr.description;
            switch attr.typeName
            case slreq.datamodel.AttributeRegType.Combobox
                this.SelectionList=attr.entries.toArray';
            case slreq.datamodel.AttributeRegType.Checkbox
                this.CheckboxDefault=attr.default;
            end


            this.isReqUsedForExternalReq=attr.isReadOnly;
        end
    end

    methods(Static)
        function show(reqSetDas)
            DAStudio.Dialog(slreq.gui.CustomAttributeRegistryEditDialog(reqSetDas));
        end

        function showForEdit(reqSetDas,attr)
            obj=slreq.gui.CustomAttributeRegistryEditDialog(reqSetDas);
            obj.setForEdit(attr);
            DAStudio.Dialog(obj);
        end
    end
end


