classdef CustomAttributeRegistryPanel





    methods(Static)
        function panel=getDialogSchema(reqSet)

            panel=struct('Type','togglepanel','LayoutGrid',[5,4],'ColStretch',[0,1,1,0],'RowStretch',[0,0,0,1,1],'Name',...
            getString(message('Slvnv:slreq:CustomAttributeRegistries')),'Tag','CustomAttrRegs');
            panel.Expand=slreq.gui.togglePanelHandler('get',panel.Tag,false);
            panel.ExpandCallback=@slreq.gui.togglePanelHandler;
            panel.Items={};

            attrRegistries=slreq.data.ReqData.getInstance.getCustomAttributeRegistries(reqSet.dataModelObj);
            attrListtext=struct('Type','text','Name',getString(message('Slvnv:slreq:AttributeEntries')),'RowSpan',[1,1],'ColSpan',[1,1],'Alignment',2);
            panel.Items{end+1}=attrListtext;


            attrListTable=struct('Type','table','Tag','AttributeListTable','RowSpan',[1,5],'ColSpan',[2,3],...
            'ColumnCharacterWidth',[100,10],...
            'ColumnStretchable',[1,1],'Editable',false,'SelectionBehavior','Row');

            attrListTable.Data={};




            selectedRow=-1;
            attrRegistryList=attrRegistries.toArray();
            if~isempty(attrRegistryList)
                for n=1:length(attrRegistryList)
                    atrrReg=attrRegistryList(n);
                    attrListTable.Data{n,1}=atrrReg.name;

                    attrListTable.Data{n,2}=atrrReg.typeName.char;
                    if strcmp(reqSet.selectedCustomAttribute,atrrReg.name)
                        selectedRow=n-1;
                    end
                end

                if selectedRow<0
                    selectedRow=0;
                    reqSet.selectedCustomAttribute=attrRegistryList(selectedRow+1).name;
                end
            end

            attrListTable.ColHeader={getString(message('Slvnv:slreq:Name')),getString(message('Slvnv:slreq:Type'))};
            attrListTable.SelectionChangedCallback=@(dlg,tag)SelectionChangedCallback(dlg,tag);
            attrListTable.CurrentItemChangedCallback=@(dlg,row,col)CurrentItemChangedCallback(dlg,row,col);
            attrListTable.Size=size(attrListTable.Data);
            attrListTable.HeaderVisibility=[0,1];


            attrListTable.SelectedRow=selectedRow;

            panel.Items{end+1}=attrListTable;


            addAttributeButton=struct('Type','pushbutton',...
            'Tag','addAttribute',...
            'Name',getString(message('Slvnv:slreq:Add')),...
            'RowSpan',[1,1],'ColSpan',[4,4],...
            'ToolTip',getString(message('Slvnv:slreq:AddAttribute')),'Alignment',2);
            addAttributeButton.MatlabMethod='slreq.gui.CustomAttributeRegistryPanel.addAttributeButtonCallback';
            addAttributeButton.MatlabArgs={'%dialog','%source'};
            panel.Items{end+1}=addAttributeButton;


            removeAttributeButton=struct('Type','pushbutton',...
            'Tag','removeAttribute',...
            'Name',getString(message('Slvnv:slreq:Remove')),...
            'RowSpan',[2,2],'ColSpan',[4,4],...
            'ToolTip',getString(message('Slvnv:slreq:RemoveAttribute')),'Alignment',2);
            removeAttributeButton.MatlabMethod='slreq.gui.CustomAttributeRegistryPanel.removeAttributeButton';
            removeAttributeButton.MatlabArgs={'%dialog','%source'};
            removeAttributeButton.Enabled=~isempty(reqSet.selectedCustomAttribute)&&~isempty(strtrim(reqSet.selectedCustomAttribute));
            panel.Items{end+1}=removeAttributeButton;




            editAttributeButton=struct('Type','pushbutton',...
            'Tag','editAttribute',...
            'Name',getString(message('Slvnv:slreq:Edit')),...
            'RowSpan',[3,3],'ColSpan',[4,4],...
            'ToolTip',getString(message('Slvnv:slreq:RemoveAttribute')),'Alignment',2);
            editAttributeButton.MatlabMethod='slreq.gui.CustomAttributeRegistryPanel.editAttributeButton';
            editAttributeButton.MatlabArgs={'%dialog','%source'};
            editAttributeButton.Enabled=selectedRow>=0;
            panel.Items{end+1}=editAttributeButton;


            if isempty(reqSet.selectedCustomAttribute)

                reqSet.selectedCustomAttribute=' ';
            end
            thisAttr=attrRegistries.getByKey(reqSet.selectedCustomAttribute);
            if~isempty(thisAttr)
                if length(thisAttr.name)>53




                    displayName=[thisAttr.name(1:50),'...'];
                else
                    displayName=thisAttr.name;
                end
                thisAttrPanel=struct('Type','group','LayoutGrid',[4,2],'ColStretch',[0,1],'RowStretch',[0,0,0,1],'Name',...
                getString(message('Slvnv:slreq:PropertiesOf',displayName)),'Tag','CustomAttrRegs');


                attrNameText=struct('Type','text','Name',getString(message('Slvnv:slreq:NameColon')),'RowSpan',[1,1],'ColSpan',[1,1]);
                attrName=struct('Type','text','Name',thisAttr.name,'RowSpan',[1,1],'ColSpan',[2,2]);
                attrName.Elide=true;

                attrTypeText=struct('Type','text','Name',getString(message('Slvnv:slreq:TypeColon')),'RowSpan',[2,2],'ColSpan',[1,1]);

                attrType=struct('Type','text','Name',char(thisAttr.typeName),'RowSpan',[2,2],'ColSpan',[2,2]);

                thisAttrPanel.Items={attrNameText,attrName,attrTypeText,attrType};


                switch thisAttr.typeName
                case slreq.datamodel.AttributeRegType.Combobox
                    attrListSelectionText=struct('Type','text','Name',getString(message('Slvnv:slreq:ListColon')),'RowSpan',[4,4],'ColSpan',[1,1]);
                    entries=thisAttr.entries.toArray;
                    entriesStr='';
                    for n=1:length(entries)
                        if n==1
                            entriesStr=entries{n};
                        else
                            entriesStr=sprintf('%s, %s',entriesStr,entries{n});
                        end
                    end
                    attrListSelection=struct('Type','text','Name',entriesStr,'RowSpan',[4,4],'ColSpan',[2,2]);
                    attrListSelection.Elide=true;
                    thisAttrPanel.Items{end+1}=attrListSelectionText;
                    thisAttrPanel.Items{end+1}=attrListSelection;
                    nRow=5;
                case slreq.datamodel.AttributeRegType.Checkbox
                    attrCheckboxText=struct('Type','text','Name',getString(message('Slvnv:slreq:DefaultValueColon')),'RowSpan',[4,4],'ColSpan',[1,1]);
                    attrCheckbox=struct('Type','checkbox','Value',thisAttr.default,'RowSpan',[4,4],'ColSpan',[2,2],'Enabled',false);
                    thisAttrPanel.Items{end+1}=attrCheckboxText;
                    thisAttrPanel.Items{end+1}=attrCheckbox;
                    nRow=5;










                case slreq.datamodel.AttributeRegType.Edit

                    nRow=4;
                case slreq.datamodel.AttributeRegType.DateTime
                    nRow=4;
                end


                attrDescriptionText=struct('Type','text','Name',getString(message('Slvnv:slreq:DescriptionColon')),'RowSpan',[nRow,nRow],'ColSpan',[1,1],'Alignment',2);
                attrDescription=struct('Type','text','Name',thisAttr.description,'RowSpan',[nRow,nRow],'ColSpan',[2,3],'BackgroundColor',[255,255,255]);
                attrDescription.Elide=true;
                thisAttrPanel.Items{end+1}=attrDescriptionText;
                thisAttrPanel.Items{end+1}=attrDescription;

                thisAttrPanel.RowSpan=[6,6];
                thisAttrPanel.ColSpan=[1,4];
                panel.Items{end+1}=thisAttrPanel;
            end

        end

        function addAttributeButtonCallback(dlg,src)%#ok<INUSL>
            slreq.gui.CustomAttributeRegistryEditDialog.show(src);
        end

        function removeAttributeButton(dlg,src)
            reqData=slreq.data.ReqData.getInstance;
            customAttributes=reqData.getCustomAttributeRegistries(src.dataModelObj);
            attrRegistry=customAttributes.getByKey(src.selectedCustomAttribute);

            if~isempty(attrRegistry)
                if reqData.isCustomAttributeRegistryInUse(attrRegistry)
                    ButtonName=questdlg(getString(message('Slvnv:slreq:CustomAttributeImportedMessage',attrRegistry.name)),...
                    getString(message('Slvnv:slreq:CustomAttributeRemovalTitle')),...
                    getString(message('Slvnv:slreq:Yes')),getString(message('Slvnv:slreq:No')),getString(message('Slvnv:slreq:Yes')));

                elseif attrRegistry.items.Size>0
                    ButtonName=questdlg(getString(message('Slvnv:slreq:CustomAttributeRemovalMessage',attrRegistry.name)),...
                    getString(message('Slvnv:slreq:CustomAttributeRemovalTitle')),...
                    getString(message('Slvnv:slreq:Yes')),getString(message('Slvnv:slreq:No')),getString(message('Slvnv:slreq:Yes')));
                else
                    ButtonName=getString(message('Slvnv:slreq:Yes'));
                end
                if strcmp(ButtonName,getString(message('Slvnv:slreq:Yes')))
                    reqData.removeCustomAttributeRegistry(attrRegistry);
                    dlg.refresh;


                    row=dlg.getSelectedTableRow('AttributeListTable');
                    if row~=-1
                        src.selectedCustomAttribute=dlg.getTableItemValue('AttributeListTable',row,0);
                    else
                        src.selectedCustomAttribute=[];
                    end
                    dlg.refresh;
                end
            end
        end

        function editAttributeButton(dlg,src)%#ok<INUSL>
            reqData=slreq.data.ReqData.getInstance;
            customAttributes=reqData.getCustomAttributeRegistries(src.dataModelObj);

            if isempty(src.selectedCustomAttribute)

                return;
            end

            attrToEdit=customAttributes.getByKey(src.selectedCustomAttribute);
            if isempty(attrToEdit)

                return;
            end
            slreq.gui.CustomAttributeRegistryEditDialog.showForEdit(src,attrToEdit);
        end
    end
end

function SelectionChangedCallback(dlg,tag)
    row=dlg.getSelectedTableRow(tag);

    selection=' ';
    if row~=-1

        selection=dlg.getTableItemValue('AttributeListTable',row,0);
    end

    dlg.getSource.selectedCustomAttribute=selection;
    dlg.refresh;
    dlg.setFocus('AttributeListTable');
end

function CurrentItemChangedCallback(dlg,row,~)

    selection=dlg.getTableItemValue('AttributeListTable',row,0);
    if isempty(selection)

        selection=' ';
    end

    dlg.getSource.selectedCustomAttribute=selection;
    dlg.setFocus('AttributeListTable');
end
