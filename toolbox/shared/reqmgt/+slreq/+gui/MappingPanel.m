classdef MappingPanel<handle





    properties
        importNode;
        reqSet;


        mapping;


        type;
        props;


        builtInSep;
        currentSep;
    end

    properties(Constant)


        data=slreq.gui.MappingPanelData();
    end

    methods
        function this=MappingPanel(importNode)
            this.importNode=importNode;
            this.reqSet=this.importNode.getReqSet();


            this.data.init(importNode);


            this.builtInSep='--Built-In Attributes--';


            this.currentSep='--Current Value--';

            this.mapping=slreq.data.ReqData.getInstance.getMapping(this.reqSet,this.importNode.customId);
        end

        function panel=getDialogSchema(this)

            panel=struct('Type','togglepanel','LayoutGrid',[5,4],'ColStretch',[0,1,1,0],'RowStretch',[0,0,0,1,0],'Name',...
            getString(message('Slvnv:slreq:ImportMapping')),'Tag','ImportMapping');
            panel.Expand=slreq.gui.togglePanelHandler('get',panel.Tag,false);
            panel.ExpandCallback=@slreq.gui.togglePanelHandler;
            panel.Items={};


            instructionsPanel.Type='text';

            instructionsPanel.Name=getString(message('Slvnv:slreq:ImportMappingInstructions'));
            instructionsPanel.RowSpan=[1,1];
            instructionsPanel.ColSpan=[1,4];
            instructionsPanel.Alignment=2;
            instructionsPanel.Tag='MappingInstructions';
            panel.Items{end+1}=instructionsPanel;


            attrListTable=struct('Type','table','Tag','MappingTable','RowSpan',[1,5],'ColSpan',[2,3],...
            'ColumnCharacterWidth',[10,20],...
            'ColumnStretchable',[0,0,0,0,0,0],'Editable',true,'SelectionBehavior','Row');

            attrListTable.Data={};


            attrListTable.ReadOnlyColumns=[0:2,4:5];

            if~isempty(this.mapping)
                types=this.mapping.types.toArray;


                this.type=types(1);
                this.props=this.type.attributes.toArray;

                if~isempty(this.props)
                    for n=1:length(this.props)
                        prop=this.props(n);

                        mapsToName=prop.mapsTo.name;
                        mapsToType=char(prop.mapsTo.type);

                        if(prop.mapsTo.kind==slreq.datamodel.AttributeKindEnum.BuiltinAttribute)
                            mapsAs=getString(message('Slvnv:slreq:MappingToBuiltIn'));
                        elseif(prop.mapsTo.kind==slreq.datamodel.AttributeKindEnum.CustomAttribute)
                            mapsAs=getString(message('Slvnv:slreq:MappingToCustomAttribute'));
                        end


                        if prop.isAutoMapped
                            isUserMapped='No';
                        else
                            isUserMapped='Yes';
                        end

                        externalType=prop.type;

                        attrListTable.Data{n,1}=num2str(n);
                        attrListTable.Data{n,2}=prop.name;
                        attrListTable.Data{n,3}=char(externalType);


                        attrListTable.Data{n,5}=mapsAs;
                        attrListTable.Data{n,6}=mapsToType;















                        mapsToCombo.Type='combobox';
                        mapsToCombo.Tag=sprintf('MapsToCombo%d',n);
                        mapsTocomboValues=this.builtInAttributeChoices(mapsToName);
                        mapsToCombo.Entries=mapsTocomboValues;
                        mapsToCombo.Values=(1:numel(mapsTocomboValues))-1;
                        mapsToCombo.Value=this.getIndex(mapsToCombo.Entries,mapsToName);
                        mapsToCombo.Editable=true;
                        attrListTable.Data{n,4}=mapsToCombo;
                    end
                end
            end

            attrListTable.ColHeader={...
            getString(message('Slvnv:slreq:MappingExternalIndex')),...
            getString(message('Slvnv:slreq:MappingExternalAttribute')),...
            getString(message('Slvnv:slreq:MappingExternalType')),...
            getString(message('Slvnv:slreq:MappingMappedTo')),...
            getString(message('Slvnv:slreq:MappingMappedAs')),...
            getString(message('Slvnv:slreq:MappingMappedAsType'))};
            attrListTable.Size=size(attrListTable.Data);
            attrListTable.HeaderVisibility=[0,1];

            attrListTable.ValueChangedCallback=@this.mappingChanged;

            attrListTable.RowSpan=[2,2];
            attrListTable.ColSpan=[1,4];

            panel.Items{end+1}=attrListTable;


            buttonPanel=this.createButtonPanel();
            buttonPanel.RowSpan=[3,3];
            buttonPanel.ColSpan=[1,4];

            panel.Items{end+1}=buttonPanel;

            previewHeaderPanel=this.createPreviewHeaderPanel();
            previewHeaderPanel.RowSpan=[4,4];
            previewHeaderPanel.ColSpan=[1,4];

            panel.Items{end+1}=previewHeaderPanel;

            panelBuiltins=this.createPanelForBuiltIns();
            panelBuiltins.RowSpan=[5,5];
            panelBuiltins.ColSpan=[1,4];

            panel.Items{end+1}=panelBuiltins;

            panelAttributes=this.createPanelForAttributes();
            panelAttributes.RowSpan=[6,6];
            panelAttributes.ColSpan=[1,4];
            panel.Items{end+1}=panelAttributes;
        end







        function[out,msg]=isMappingValid(this,oldName,oldType,newName,newType)

            out=true;
            msg='';

            found=false;
            for n=1:length(this.props)
                prop=this.props(n);
                mapsTo=prop.mapsTo;
                mapsToName=mapsTo.name;
                mapsToType=mapsTo.type;


                if strcmp(mapsToName,newName)
                    found=true;
                    break;
                end
            end

            if found
                out=false;

                newName=this.data.toDisplayName(newName);
                msg=getString(message('Slvnv:reqmgt:remapping:AttributeAlreadyMapped',newName));
            end
        end

        function mappingChanged(this,dlg,row,col,str)

            oldMapsTo=this.props(row+1);
            oldMapping=oldMapsTo.mapsTo;
            oldName=oldMapping.name;
            oldType=oldMapping.type;
            oldDisplayName=this.data.toDisplayName(oldName);


            if strcmp(str,this.builtInSep)||strcmp(str,this.currentSep)

                dlg.setTableItemValue('MappingTable',row,col,oldDisplayName);

                dlg.refresh();
                return;
            end

            newValue=dlg.getTableItemValue('MappingTable',row,col);


            newValue=strtrim(newValue);

            if isempty(newValue)

                dlg.setTableItemValue('MappingTable',row,col,oldDisplayName);

                dlg.refresh();
                return;
            end


            [newValueInternal,idx]=this.data.toInternalName(newValue);
            isCustom=isempty(idx);


            if strcmp(oldName,newValueInternal)
                return;
            end



            [isValid,msg]=this.isMappingValid(oldName,oldType,newValueInternal,...
            slreq.datamodel.AttributeTypeEnum.String);
            if~isValid
                this.data.mappingMessage=msg;

                dlg.setTableItemValue('MappingTable',row,col,oldDisplayName);

                dlg.refresh();
                return;
            else
                this.data.clearMessages();
            end












            reqData=slreq.data.ReqData.getInstance();

            oldDisplayName=this.data.toDisplayName(oldName);


            if isCustom


                newMapsTo=reqData.createMapToCustomAttribute(...
                oldName,oldType,newValueInternal,oldType,false);
            else


                builtInType=this.getBuiltInTypeEnum(newValueInternal);
                newMapsTo=reqData.createMapToBuiltIn(...
                oldName,oldType,newValueInternal,builtInType);
            end



            try
                reqData.remapAttribute(this.reqSet,this.importNode,oldMapsTo,newMapsTo);
            catch ex

                this.data.mappingMessage=ex.message;


                dlg.setTableItemValue('MappingTable',row,col,oldDisplayName);
                dlg.refresh();
                return;
            end


            if~isempty(idx)

                this.data.highlightProperty(this.data.toPropertyName(newValueInternal));
            else

                this.data.highlightProperty(newValueInternal);
            end


            oldMapping.destroy();
            oldMapsTo.mapsTo=newMapsTo.mapsTo;

            oldMapsTo.isAutoMapped=false;



            dlg.refresh();



            mgr=slreq.app.MainManager.getInstance();
            reqEditor=mgr.requirementsEditor;

            cols=reqEditor.Columns;


            changed={this.data.toPropertyName(oldName),...
            this.data.toPropertyName(newValueInternal)};


            if any(ismember(lower(cols),lower(changed)))
                this.refreshME();
            end
        end


        function refreshME(this)

            mgr=slreq.app.MainManager.getInstance;
            mgr.refreshUI();
        end

        function type=getBuiltInTypeEnum(this,attributeName)
            type=this.data.getBuiltInTypeEnum(attributeName);
        end

        function out=typeChoices(this)

            anyVal=slreq.datamodel.AttributeTypeEnum.Any;
            allVals=enumeration(anyVal);

            out=allVals.cellstr';
        end




        function out=builtInAttributeChoices(this,name)
            idx=find(strcmp(this.data.getInternalNames(),name));

            if isempty(idx)


                out=[this.builtInSep;this.data.getDisplayNames();this.currentSep;name];
            else
                out=[this.builtInSep;this.data.getDisplayNames()];
            end
        end


        function out=getIndex(this,values,name)
            idx=find(strcmp(this.data.getInternalNames(),name));
            if~isempty(idx)

                name=this.data.getDisplayName(idx);
            end

            out=[];
            idx=find(strcmp(values,name));
            if~isempty(idx)
                out=idx-1;
            end
        end

        function dlgstruct=createButtonPanel(this)

            isMappingAvailable=~isempty(this.mapping);


            typeButton=struct('Type','pushbutton',...
            'Tag','objTypeMapping',...
            'Name',getString(message('Slvnv:slreq_objtypes:TypeMappingTitle')),...
            'RowSpan',[1,1],'ColSpan',[1,1],...
            'ToolTip',getString(message('Slvnv:slreq_objtypes:TypeMappingButtonTooltip')));
            typeButton.MatlabMethod='slreq.gui.MappingPanel.mapTypes_callback';
            typeButton.MatlabArgs={this,'%dialog'};
            typeButton.Enabled=isMappingAvailable;


            saveButton=struct('Type','pushbutton',...
            'Tag','exportMapping',...
            'Name',getString(message('Slvnv:slreq:MappingButtonExport')),...
            'RowSpan',[1,1],'ColSpan',[2,2],...
            'ToolTip',getString(message('Slvnv:slreq:MappingButtonExportTooltip')));
            saveButton.MatlabMethod='slreq.gui.MappingPanel.saveMapping_callback';
            saveButton.MatlabArgs={this,'%dialog'};
            saveButton.Enabled=isMappingAvailable;


            loadButton=struct('Type','pushbutton',...
            'Tag','importMapping',...
            'Name',getString(message('Slvnv:slreq:MappingButtonImport')),...
            'Enabled',isMappingAvailable,...
            'RowSpan',[1,1],'ColSpan',[3,3],...
            'ToolTip',getString(message('Slvnv:slreq:MappingButtonImportTooltip')));
            loadButton.MatlabMethod='slreq.gui.MappingPanel.loadMapping_callback';
            loadButton.MatlabArgs={this,'%dialog'};


            resetButton=struct('Type','pushbutton',...
            'Tag','resetMapping',...
            'Name',getString(message('Slvnv:slreq:MappingButtonReset')),...
            'Enabled',isMappingAvailable,...
            'RowSpan',[1,1],'ColSpan',[4,4],...
            'ToolTip',getString(message('Slvnv:slreq:MappingButtonResetTooltip')));
            resetButton.MatlabMethod='slreq.gui.MappingPanel.resetMapping_callback';
            resetButton.MatlabArgs={this,'%dialog'};


            mappingMsgPanel.Type='text';
            mappingMsgPanel.ForegroundColor=[255,0,0];
            mappingMsgPanel.Bold=true;
            mappingMsgPanel.Name=this.data.mappingMessage;
            mappingMsgPanel.RowSpan=[1,1];
            mappingMsgPanel.ColSpan=[5,5];
            mappingMsgPanel.Alignment=1;
            mappingMsgPanel.Tag='MappingMessage';

            dlgstruct=struct('Type','panel');
            dlgstruct.LayoutGrid=[1,5];
            dlgstruct.ColStretch=[0,0,0,0,1];
            dlgstruct.Items={typeButton,saveButton,loadButton,resetButton,mappingMsgPanel};
        end

        function dlgstruct=createPreviewHeaderPanel(this)
            dlgstruct=struct('Type','group','LayoutGrid',[4,3],...
            'Alignment',1);

            dlgstruct.Name=getString(message('Slvnv:slreq:ImportMappingPreview'));
            dlgstruct.ColSpan=[1,4];
            dlgstruct.ColStretch=[0,0,1];
            dlgstruct.Items={};























            prevButton=struct('Type','pushbutton',...
            'Tag','prevPreview',...
            'Name',getString(message('Slvnv:slreq:MappingButtonPreviewPrev')),...
            'Enabled',this.data.hasPrevRequirement(),...
            'RowSpan',[1,1],'ColSpan',[1,1],...
            'ToolTip',getString(message('Slvnv:slreq:MappingButtonPreviewPrevTooltip')));
            prevButton.MatlabMethod='slreq.gui.MappingPanel.previewPrev_callback';
            prevButton.MatlabArgs={this,'%dialog'};
            dlgstruct.Items{end+1}=prevButton;

            nextButton=struct('Type','pushbutton',...
            'Tag','nextPreview',...
            'Name',getString(message('Slvnv:slreq:MappingButtonPreviewNext')),...
            'Enabled',this.data.hasNextRequirement(),...
            'RowSpan',[1,1],'ColSpan',[2,2],...
            'ToolTip',getString(message('Slvnv:slreq:MappingButtonPreviewNextTooltip')));
            nextButton.MatlabMethod='slreq.gui.MappingPanel.previewNext_callback';
            nextButton.MatlabArgs={this,'%dialog'};
            dlgstruct.Items{end+1}=nextButton;
        end
    end

    methods(Static)




        function mapTypes_callback(obj,dlg)
            obj.mapTypes(dlg);
        end


        function saveMapping_callback(obj,dlg)
            obj.saveMapping(dlg);
        end


        function previewPrev_callback(obj,dlg)
            obj.previewPrevRequirement(dlg);
        end
        function previewNext_callback(obj,dlg)
            obj.previewNextRequirement(dlg);
        end


        function loadMapping_callback(obj,dlg)
            obj.loadMapping(dlg);
        end


        function resetMapping_callback(obj,dlg)
            obj.resetMapping(dlg);
        end
    end

    methods




        function resetMapping(this,dlg)



            if isempty(this.mapping)
                return;
            end

            reqData=slreq.data.ReqData.getInstance();

            doRefresh=false;
            mappedAttribs=this.type.attributes.toArray;
            for n=1:length(mappedAttribs)
                mappedAttrib=mappedAttribs(n);

                mapsTo=mappedAttrib.mapsTo;


                if mappedAttrib.kind==slreq.datamodel.AttributeKindEnum.CustomAttribute

                    remappedAttrib=reqData.createMapToCustomAttribute(...
                    mapsTo.name,mapsTo.type,mappedAttrib.name,mappedAttrib.type,true);
                else
                    remappedAttrib=reqData.createMapToBuiltIn(...
                    mapsTo.name,mapsTo.type,mappedAttrib.name,mappedAttrib.type);
                end

                try
                    reqData.remapAttribute(this.reqSet,this.importNode,mappedAttrib,remappedAttrib);
                catch ex



                    break;
                end


                mappedAttrib.mapsTo.destroy();
                mappedAttrib.isAutoMapped=true;
                mappedAttrib.mapsTo=remappedAttrib.mapsTo;

                remappedAttrib.mapsTo=slreq.datamodel.MappedAttribute.empty();
                remappedAttrib.destroy();




                doRefresh=true;
            end


            this.data.clearHighlightedProperties();
            this.data.clearMessages();


            if doRefresh
                dlg.refresh();
                this.refreshME();
            end
        end

        function mapTypes(this,dlg)
            dlgObj=slreq.gui.TypeMappingDialog(this.importNode);
            DAStudio.Dialog(dlgObj);
        end

        function saveMapping(this,dlg)

            fileFilters={'*.xml','Attribute mapping file';...
            '*.*','All files'};

            [filename,pathname]=uiputfile(fileFilters,...
            getString(message('Slvnv:slreq:ImportMappingPutFile')));
            filepath=[];
            if~isequal(filename,0)
                filepath=fullfile(pathname,filename);
            end

            if isempty(filepath)
                return;
            end

            slreq.data.ReqData.getInstance.saveMapping(this.mapping,filepath);
        end


        function loadMapping(this,dlg)

            fileFilters={'*.xml','Attribute mapping file';...
            '*.*','All files'};

            [filename,pathname]=uigetfile(fileFilters,...
            getString(message('Slvnv:slreq:ImportMappingGetFile')));

            filepath=[];
            if~isequal(filename,0)
                filepath=fullfile(pathname,filename);
            end

            if isempty(filepath)
                return;
            end

            reqData=slreq.data.ReqData.getInstance();
            newMapping=reqData.loadMapping(filepath);

            if isempty(newMapping)

                return;
            end


            mappingType=reqData.getMappingDirection(newMapping);
            if mappingType~=slreq.datamodel.MappingDirectionEnum.Import
                error(getString(message('Slvnv:slreq:MappingError')));
            end

            oldMappedType=this.type;


            newMappedType=newMapping.types{'SpecObject'};
            if isempty(newMappedType)
                error(getString(message('Slvnv:slreq:MappingError')));
            end

            doRefresh=false;
            mappedAttribs=newMappedType.attributes.toArray;
            for n=1:length(mappedAttribs)
                newAttrib=mappedAttribs(n);


                oldAttrib=oldMappedType.attributes{newAttrib.name};




                if isempty(oldAttrib)
                    continue;
                end

                oldMapsTo=oldAttrib.mapsTo;


                newMapsTo=newAttrib.mapsTo;



                if strcmp(oldMapsTo.name,newMapsTo.name)
                    continue;
                end



                if newMapsTo.kind==slreq.datamodel.AttributeKindEnum.CustomAttribute
                    remappedAttrib=reqData.createMapToCustomAttribute(...
                    oldMapsTo.name,oldMapsTo.type,newMapsTo.name,newMapsTo.type,false);
                else
                    remappedAttrib=reqData.createMapToBuiltIn(...
                    oldMapsTo.name,oldMapsTo.type,newMapsTo.name,newMapsTo.type);
                end

                try
                    reqData.remapAttribute(this.reqSet,this.importNode,oldAttrib,remappedAttrib);
                catch ex



                    break;
                end


                oldAttrib.mapsTo.destroy();
                oldAttrib.mapsTo=remappedAttrib.mapsTo;


                oldAttrib.isAutoMapped=false;

                remappedAttrib.mapsTo=slreq.datamodel.MappedAttribute.empty();
                remappedAttrib.destroy();




                doRefresh=true;
            end




            if doRefresh
                dlg.refresh();
                this.refreshME();
            end
        end

        function previewPrevRequirement(this,dlg)
            this.data.getPrevRequirement();
            dlg.refresh();
        end

        function previewNextRequirement(this,dlg)
            this.data.getNextRequirement();
            dlg.refresh();
        end


        function dlgstruct=createPanelForBuiltIns(this)


            dlgstruct=slreq.gui.generateDDGStructForProperties(this.data.getCurrentRequirement(),...
            this.data.getDASPropertyNames(),'panel','ReqTopPanel','preview',...
            true,true,'preview_',this.data.getHighlightedProperties());


            dlgstruct.LayoutGrid=[5,3];
            dlgstruct.RowStretch=[0,0,1,1,0];
        end


        function dlgstruct=createPanelForAttributes(this)

            reqData=slreq.data.ReqData.getInstance();

            attrRegistries=reqData.getCustomAttributeRegistries(this.reqSet);

            nRow=10;
            customAttrPanel=slreq.gui.CustomAttributeItemPanel.getPreviewDialogSchema(this.data.getCurrentRequirement(),...
            attrRegistries,nRow,'CustomAttributePreview',this.data.getHighlightedProperties());
            dlgstruct=customAttrPanel;
        end

    end
end
