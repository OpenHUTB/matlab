classdef StereotypeAttributeItemPanel<slreq.gui.CustomAttributeItemPanel




    methods(Static)
        function stereotypeAttrPanel=getDialogSchema(dasObj,nRow,panelTag)

            stereotypeAttrPanel=[];
            if isempty(dasObj)
                return;
            end

            if isa(dasObj,'slreq.das.Requirement')||isa(dasObj,'slreq.das.Link')
                if isa(dasObj,'slreq.das.Requirement')
                    isLocked=dasObj.IsLocked;
                else
                    isLocked=false;
                end

                typeName=dasObj.Type;
                if isa(dasObj,'slreq.das.Link')
                    typeName=dasObj.dataModelObj.type;
                end

                attributes=slreq.internal.ProfileReqType.getStereotypeAttributes(typeName);
                if isempty(attributes)

                    return;
                end

            else
                return;
            end

            stereotypeAttrPanel=struct('Type','togglepanel','Name','Stereotype Attributes','Tag',panelTag);
            stereotypeAttrPanel.Expand=slreq.gui.togglePanelHandler('get',stereotypeAttrPanel.Tag,false);
            stereotypeAttrPanel.ExpandCallback=@slreq.gui.togglePanelHandler;
            stereotypeAttrPanel.Items={};

            attributeNames={attributes.Name};

            usePreferredSize=slreq.gui.CustomAttributeItemPanel.checkUsePreferredSize([],attributes,[]);

            for n=1:length(attributeNames)
                attrName=[typeName,'.',attributeNames{n}];
                type=slreq.internal.ProfileReqType.getStereotypeAttrType(attrName);
                objPropName=slreq.utils.customAttributeNamesHash('hash',attrName);

                value=dasObj.dataModelObj.getStereotypeAttr(attrName,true);

                switch type
                case 'string'
                    editField=slreq.gui.CustomAttributeItemPanel.makeEditField(dasObj,objPropName,n,isLocked);

                case 'boolean'
                    editField=slreq.gui.CustomAttributeItemPanel.makeCheckboxField(n,isLocked);

                    spacer=struct('Type','panel','Name','','RowSpan',[n,n],'ColSpan',[3,3]);
                    stereotypeAttrPanel.Items{end+1}=spacer;

                    editField.Value=value;
                otherwise
                    if any(strcmp(type,{'uint8','uint16','uint32','uint64','double','int8','int16','int32','int64','single'}))
                        editField=slreq.gui.CustomAttributeItemPanel.makeEditField(dasObj,objPropName,n,isLocked);
                        editField.Value=num2str(value);
                    else

                        type=slreq.internal.ProfileReqType.getStereotypeAttrType(attrName);
                        try

                            editField=struct('Type','combobox','RowSpan',[n,n],'ColSpan',[2,2],...
                            'Graphical',true);

                            editField.Entries=cellstr(enumeration(type));

                            editField.Enabled=~isLocked;
                            editField.Mode=1;
                            spacer=struct('Type','panel','Name','','RowSpan',[n,n],'ColSpan',[3,3]);
                            stereotypeAttrPanel.Items{end+1}=spacer;
                        catch ME

                            editField=slreq.gui.CustomAttributeItemPanel.makeEditField(dasObj,objPropName,n,isLocked);
                            editField.Value=slreq.internal.ProfileReqType.getStereotypeDefaultValue(attrName);
                            rootNode=dasObj.RequirementSet.parent;
                            profName=slreq.internal.ProfileReqType.getProfileStereotype(attrName);
                            msgId='Slvnv:slreq:ProfileEnumFileMissing';
                            rootNode.showSuggestion(msgId,getString(message(msgId,[type,'.m'],profName)));
                        end
                    end
                end

                editField.Tag=objPropName;

                if~strcmp(editField.Type,'text')
                    editField.ObjectProperty=objPropName;
                end

                nameField=struct('Type','text','Name',[attributeNames{n},':'],'RowSpan',[n,n],'ColSpan',[1,1]);


                nameField.ToolTip=[dasObj.Type,'.',attrName];
                if usePreferredSize
                    nameField.Elide=true;
                    nameField.PreferredSize=slreq.gui.CustomAttributeItemPanel.MAX_LENGTH_OF_FIRST_COLUMN*10;
                end

                stereotypeAttrPanel.Items{end+1}=nameField;
                stereotypeAttrPanel.Items{end+1}=editField;
            end

            stereotypeAttrPanel.LayoutGrid=[numel(attributeNames),3];
            stereotypeAttrPanel.RowSpan=[nRow,nRow];
            stereotypeAttrPanel.ColStretch=[0,0,1];
        end
    end
end