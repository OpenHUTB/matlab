classdef ReqIFPanel<handle



    properties

        mappingFile;



        mappingMgr;


        errorDetails;

        multiSpecMode=slreq.import.ui.ReqIFPanel.IMPORT_SELECTED;

        selectedSpec;

        specNames;

        hasLinks;

        importLinks;
    end

    events
        ReqSetNameChanged;
    end

    properties(Constant)
        IMPORT_ALL_AS_ONE=1;
        IMPORT_ALL_AS_MULTIPLE=2;
        IMPORT_SELECTED=4;
    end

    methods
        function this=ReqIFPanel()
            this.mappingFile='';
            this.errorDetails='';

            this.specNames={};
            this.selectedSpec='';
            this.hasLinks=false;
            this.importLinks=true;




        end

        function out=getError(this)
            if~isempty(this.errorDetails)
                out=getString(message('Slvnv:slreq_import:InvalidReqifFileDetails',this.errorDetails));
            else
                out='';
            end
        end

        function out=isReady(this)
            out=isempty(this.errorDetails);
        end

        function out=hasMultipleSpecs(this)
            out=length(this.specNames)>1;
        end

    end



    methods
        [items,grid]=getMappingOptions(this,srcDoc);

        [items,grid]=getMultipleSpecs(this);

        dlgstruct=getDialogSchema(this);
    end

    methods(Static)


        testDialog();


        function mappingFile_changed(obj,dlg)
            obj.updateMappingInfo(dlg);
        end


        function multiSpecOption_callback(obj,dlg)
            obj.setMultiSpecMode(dlg);

            val=dlg.getWidgetValue('ReqIFPanel_multiSpecOption');
            enable=(val==slreq.import.ui.ReqIFPanel.IMPORT_SELECTED)&&obj.hasMultipleSpecs();
            dlg.setEnabled('ReqIFPanel_specCombo',enable);


            switch val
            case slreq.import.ui.ReqIFPanel.IMPORT_SELECTED
                tooltip=getString(message('Slvnv:slreq_import:ReqIFMultipleSpecsImportOnlySelectedTooltip'));
            case slreq.import.ui.ReqIFPanel.IMPORT_ALL_AS_ONE
                tooltip=getString(message('Slvnv:slreq_import:ReqIFMultipleSpecsImportAllAsOneReqSetTooltip'));
            case slreq.import.ui.ReqIFPanel.IMPORT_ALL_AS_MULTIPLE
                tooltip=getString(message('Slvnv:slreq_import:ReqIFMultipleSpecsImportAllAsMultiReqSetsTooltip'));
            end

            dlg.updateToolTip('ReqIFPanel_multiSpecOption',tooltip);

        end


        function specCombo_callback(obj,dlg)
            obj.updateSelectedSpec(dlg);
        end


        function importLinks_callback(obj,dlg)
            obj.updateImportLinks(dlg);
        end
    end

    methods

        function out=getAsMutlipleReqSets(this)
            out=(this.multiSpecMode==slreq.import.ui.ReqIFPanel.IMPORT_ALL_AS_MULTIPLE);
        end

        function out=getImportSingleSpec(this)
            out=(this.multiSpecMode==slreq.import.ui.ReqIFPanel.IMPORT_SELECTED);
        end

        function out=getImportLinks(this)
            out=this.importLinks;
        end



        function out=getFirstReqSetName(this)
            if(length(this.specNames)>1)&&this.getAsMutlipleReqSets()
                out=this.specNames{1};
            else
                out='';
            end
        end

        function out=getSelectedSpec(this)
            if this.getImportSingleSpec()
                out=this.selectedSpec;
            else
                out='';
            end
        end

        function setMultiSpecMode(this,dlg)
            this.multiSpecMode=dlg.getWidgetValue('ReqIFPanel_multiSpecOption');


            eventData=slreq.import.ui.ReqIFPanelChanged();
            eventData.dlg=dlg;
            notify(this,'ReqSetNameChanged',eventData);
        end

        function updateImportLinks(this,dlg)
            this.importLinks=dlg.getWidgetValue('ReqIFPanel_importLinks');
        end

        function updateSelectedSpec(this,dlg)
            idx=dlg.getWidgetValue('ReqIFPanel_specCombo');

            if(idx+1)<=length(this.specNames)
                this.selectedSpec=this.specNames{idx+1};
            else
                this.selectedSpec='';
            end
        end

        function out=getMappingInfoDesc(this,mappingInfo)
            out='';

            if isempty(mappingInfo.desc)&&isempty(mappingInfo.name)

                out='Invalid mapping file';
                return;
            end

            out=mappingInfo.desc;



            if isempty(out)
                out=' ';
            end
        end

        function updateMappingInfo(this,dlg)
            mappingName=dlg.getWidgetValue('ReqIFPanel_mappingFile');

            mappingInfo=this.mappingMgr.getMappingInfo(mappingName);
            if~isempty(mappingInfo)
                this.mappingFile=mappingInfo.fullpath;
            else



                this.mappingFile=mappingName;
                mappingInfo=this.mappingMgr.parseMappingInfo(mappingName);

            end

            mappingInfoDesc=this.getMappingInfoDesc(mappingInfo);

            dlg.setWidgetValue('ReqIFPanel_mappingInfo',mappingInfoDesc);
        end

    end

end

