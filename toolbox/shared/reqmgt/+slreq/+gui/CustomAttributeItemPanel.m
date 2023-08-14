classdef CustomAttributeItemPanel<handle




    properties(Constant)
        MAX_LENGTH_OF_FIRST_COLUMN=15;


        HIGHLIGHT_COLOR=[0,128,0];



        DEFAULT_DATETIME_FORMAT='dd-mmm-yyyy HH:MM:SS';
    end

    methods(Static)

        function tf=visibleAttributeReg(attrReg,itemType)
            tf=~attrReg.isSystem;
            attrQualifier=attrReg.externalType;
            if~isempty(attrQualifier)&&~strcmp(itemType,attrQualifier)
                tf=false;
            end
        end

        function usePreferredSize=checkUsePreferredSize(attrRegistries,stereotypeAttrs,itemType)
            nameArr=[];
            if~isempty(attrRegistries)
                visibleFunc=@slreq.gui.CustomAttributeItemPanel.visibleAttributeReg;

                visibleAttrRegs=attrRegistries(arrayfun(@(x)visibleFunc(x,itemType),attrRegistries));
                nameArr={visibleAttrRegs.name};
            end

            if~isempty(stereotypeAttrs)
                nameArr=[nameArr,{stereotypeAttrs.Name}];
            end

            maxLengthOfName=0;
            if~isempty(nameArr)
                maxLengthOfName=max(cellfun(@(x)length(x),nameArr));
            end

            if maxLengthOfName>slreq.gui.CustomAttributeItemPanel.MAX_LENGTH_OF_FIRST_COLUMN
                usePreferredSize=true;
            else
                usePreferredSize=false;
            end
        end

        function tf=isEmptyPanel(dasObj,customAttributeRegistries)
            tf=isempty(dasObj)||customAttributeRegistries.Size()==0;
        end

        function editField=makeEditField(obj,objPropName,n,isLocked)
            if~isLocked
                editField=struct('Type','edit','RowSpan',[n,n],'ColSpan',[2,3],...
                'Mode',true,'Graphical',true);
            else
                editField=struct('Type','text','Name',obj.getPropValue(objPropName),...
                'RowSpan',[n,n],'ColSpan',[2,3]);
            end
        end
        function editField=makeDateTimeField(obj,objPropName,n,isLocked)
            if~isLocked
                editField=struct('Type','edit','RowSpan',[n,n],'ColSpan',[2,3],...
                'Mode',true,'Graphical',true);


                editField.PlaceholderText=slreq.gui.CustomAttributeItemPanel.DEFAULT_DATETIME_FORMAT;


            else
                editField=struct('Type','text','Name',obj.getPropValue(objPropName),...
                'RowSpan',[n,n],'ColSpan',[2,3]);
            end
        end

        function editField=makeCheckboxField(n,isLocked)
            editField=struct('Type','checkbox','RowSpan',[n,n],'ColSpan',[2,2],...
            'Graphical',true,'Alignment',5);
            editField.Enabled=~isLocked;
            editField.Mode=1;
        end

        function editField=makeComboboxField(n,entries,isLocked)
            editField=struct('Type','combobox','RowSpan',[n,n],'ColSpan',[2,2],...
            'Graphical',true);

            editField.Entries=entries;
            editField.Enabled=~isLocked;
            editField.Mode=1;
        end

        function customAttrPanel=getDialogSchema(obj,customAttributeRegistries,nRow,panelTag)
            if slreq.gui.CustomAttributeItemPanel.isEmptyPanel(obj,customAttributeRegistries)

                customAttrPanel=[];
                return;
            end

            customAttrPanel=struct('Type','togglepanel','Name',getString(message('Slvnv:slreq:CustomAttributes')),'Tag',panelTag);
            customAttrPanel.Expand=slreq.gui.togglePanelHandler('get',customAttrPanel.Tag,false);
            customAttrPanel.ExpandCallback=@slreq.gui.togglePanelHandler;
            customAttrPanel.Items={};

            if isa(obj,'slreq.das.Requirement')

                itemType=obj.dataModelObj.externalTypeName;

                isLocked=obj.IsLocked;
            else

                itemType='';
                isLocked=false;
            end
            attrRegistries=customAttributeRegistries.toArray();

            usePrferredSize=slreq.gui.CustomAttributeItemPanel.checkUsePreferredSize(attrRegistries,[],itemType);

            for n=1:length(attrRegistries)
                attrReg=attrRegistries(n);
                attrName=attrReg.name;

                if~slreq.gui.CustomAttributeItemPanel.visibleAttributeReg(attrReg,itemType)
                    continue;
                end


                objPropName=slreq.utils.customAttributeNamesHash('hash',attrName);

                switch attrReg.typeName
                case slreq.datamodel.AttributeRegType.Edit
                    editField=slreq.gui.CustomAttributeItemPanel.makeEditField(obj,objPropName,n,isLocked);

                    val=obj.getPropValue(objPropName);
                    if length(val)>80
                        editField.ToolTip=val;
                    end

                case slreq.datamodel.AttributeRegType.DateTime
                    editField=slreq.gui.CustomAttributeItemPanel.makeDateTimeField(obj,objPropName,n,isLocked);


                    editField.ToolTip=slreq.gui.CustomAttributeItemPanel.DEFAULT_DATETIME_FORMAT;

                case slreq.datamodel.AttributeRegType.Checkbox
                    editField=slreq.gui.CustomAttributeItemPanel.makeCheckboxField(n,isLocked);

                    spacer=struct('Type','panel','Name','','RowSpan',[n,n],'ColSpan',[3,3]);
                    customAttrPanel.Items{end+1}=spacer;

                case slreq.datamodel.AttributeRegType.Combobox
                    entries={};
                    if attrReg.entries.Size>0
                        entries=attrReg.entries.toArray;
                    end

                    editField=slreq.gui.CustomAttributeItemPanel.makeComboboxField(n,entries,isLocked);
                    spacer=struct('Type','panel','Name','','RowSpan',[n,n],'ColSpan',[3,3]);
                    customAttrPanel.Items{end+1}=spacer;

                otherwise

                    editField=struct('Type','text','Name','');
                end



                editField.Tag=objPropName;

                if~strcmp(editField.Type,'text')
                    editField.ObjectProperty=objPropName;
                end

                nameField=struct('Type','text','Name',[attrName,':'],'RowSpan',[n,n],'ColSpan',[1,1]);



                nameField.ToolTip=attrName;
                if usePrferredSize
                    nameField.Elide=true;
                    nameField.PreferredSize=150;
                end

                customAttrPanel.Items{end+1}=nameField;
                customAttrPanel.Items{end+1}=editField;
            end

            customAttrPanel.LayoutGrid=[length(customAttributeRegistries),3];
            customAttrPanel.RowSpan=[nRow,nRow];
            customAttrPanel.ColStretch=[0,0,1];
        end























        function customAttrPanel=getPreviewDialogSchema(obj,customAttributeRegistries,nRow,panelTag,highlightProperties)

            customAttrPanel=struct('Type','togglepanel','Name',getString(message('Slvnv:slreq:CustomAttributes')),'Tag',panelTag);
            customAttrPanel.Expand=slreq.gui.togglePanelHandler('get',customAttrPanel.Tag,false);
            customAttrPanel.ExpandCallback=@slreq.gui.togglePanelHandler;
            customAttrPanel.Items={};


            if isempty(obj)
                return;
            end


            itemType=obj.dataModelObj.externalTypeName;

            attrRegistries=customAttributeRegistries.toArray();



            maxLengthOfName=0;
            if~isempty(attrRegistries)
                maxLengthOfName=max(cellfun(@(x)length(x),{attrRegistries.name}));
            end

            if maxLengthOfName>slreq.gui.CustomAttributeItemPanel.MAX_LENGTH_OF_FIRST_COLUMN
                usePrferredSize=true;
            else
                usePrferredSize=false;
            end

            for n=1:length(attrRegistries)
                attrReg=attrRegistries(n);
                attrName=attrReg.name;


                if attrReg.isSystem
                    continue;
                end

                attrQualifier=attrReg.externalType;


                if~isempty(attrQualifier)&&~strcmp(itemType,attrQualifier)
                    continue;
                end


                objPropName=slreq.utils.customAttributeNamesHash('hash',attrName);

                switch attrReg.typeName
                case slreq.datamodel.AttributeRegType.Edit

                    editField=struct('Type','text','Name',obj.getPropValue(objPropName),...
                    'RowSpan',[n,n],'ColSpan',[2,3]);
                    editField.Enabled=false;


                case slreq.datamodel.AttributeRegType.DateTime

                    editField=struct('Type','text','Name',obj.getPropValue(objPropName),...
                    'RowSpan',[n,n],'ColSpan',[2,3]);
                    editField.Enabled=false;


                case slreq.datamodel.AttributeRegType.Checkbox
                    editField=struct('Type','checkbox','RowSpan',[n,n],'ColSpan',[2,2],...
                    'Graphical',true,'Alignment',5);
                    editField.Enabled=false;

                    editField.Value=str2double(obj.getPropValue(objPropName));
                    editField.Mode=1;

                    spacer=struct('Type','panel','Name','','RowSpan',[n,n],'ColSpan',[3,3]);
                    customAttrPanel.Items{end+1}=spacer;

                case slreq.datamodel.AttributeRegType.Combobox
                    editField=struct('Type','combobox','RowSpan',[n,n],'ColSpan',[2,2],...
                    'Graphical',true);
                    if attrReg.entries.Size>0
                        editField.Entries=attrReg.entries.toArray;
                    else
                        editField.Entries={};
                    end

                    editField.Value=find(strcmp(editField.Entries,obj.getPropValue(objPropName)))-1;
                    editField.Enabled=false;
                    editField.Mode=1;

                    spacer=struct('Type','panel','Name','','RowSpan',[n,n],'ColSpan',[3,3]);
                    customAttrPanel.Items{end+1}=spacer;

                otherwise

                    editField=struct('Type','text','Name','');
                end


                editField.Tag=[panelTag,objPropName];





                nameField=struct('Type','text','Name',[attrName,':'],'RowSpan',[n,n],'ColSpan',[1,1]);



                if usePrferredSize
                    nameField.Elide=true;
                    nameField.PreferredSize=150;
                end



                if any(strcmp(highlightProperties,attrName))
                    nameField.Bold=true;
                    nameField.ForegroundColor=slreq.gui.CustomAttributeItemPanel.HIGHLIGHT_COLOR;
                end

                customAttrPanel.Items{end+1}=nameField;
                customAttrPanel.Items{end+1}=editField;
            end

            customAttrPanel.LayoutGrid=[length(customAttributeRegistries),3];
            customAttrPanel.RowSpan=[nRow,nRow];
            customAttrPanel.ColStretch=[0,0,1];
        end
    end
end
