


classdef ExportToReqIFDialog<handle

    properties

        reqSet;
        importNode;


        outputFile;


        errorText;
        warningText;


        allMappings;
        mappingMgr;


        storedMapping;
storedMappingIdx
        storedMappingName;

        useStoredmapping;


        mappingFile;
        mappingDesc;
        templateFile;
    end

    properties(Constant)
        REQIF='.reqif';
        REQIFZ='.reqifz';
        PREFIX='export_';
        USER_WARNING='warning';
        USER_ERROR='error';
    end

    methods
        function this=ExportToReqIFDialog(reqSet,importNode)
            if(nargin<2)
                importNode=[];
            end

            this.errorText='';
            this.warningText='';
            this.outputFile='';
            this.mappingFile='';
            this.mappingDesc='';
            this.templateFile='';

            this.storedMapping=[];
            this.allMappings={};

            this.reqSet=reqSet;
            this.importNode=importNode;






            if isempty(this.importNode)
                importNodes=this.reqSet.children;
                if length(importNodes)==1&&importNodes(1).isReqIF()
                    this.importNode=importNodes(1);
                end
            end



            this.outputFile=this.getDefaultOutputFile();


            if~isempty(this.importNode)
                this.retrieveMapping();
            end


            this.mappingMgr=slreq.app.MappingFileManager.getInstance();
        end

    end

    methods

        function exportLinks_callback(~,dlg)
            value=dlg.getWidgetValue('ExportDlg_exportLinks');
            if value
                dlg.setWidgetValue('ExportDlg_exportLinksNote',...
                getString(message('Slvnv:slreq:ExportLinksCreatesProxy')));
            else
                dlg.setWidgetValue('ExportDlg_exportLinksNote',...
                getString(message('Slvnv:slreq:ExportLinksYouWillNot')));
            end
        end

        function retrieveMapping(this)

            reqData=slreq.data.ReqData.getInstance();
            varMapping=reqData.getMapping(this.reqSet,this.importNode.customId);




            if~isempty(varMapping)&&~strcmp(varMapping.description,'NOT-FOR-EXPORT')
                this.storedMapping=varMapping;
            end
        end


        function out=getDefaultOutputFile(this)
            [fPath,fName,~]=fileparts(this.reqSet.filepath);



            if slreq.internal.hasImagesToExport(this.reqSet.name)
                fExt=this.REQIFZ;
            else
                fExt=this.REQIF;
            end


            reqIFname=[this.PREFIX,fName,fExt];
            out=fullfile(fPath,reqIFname);
        end

        function dlgstruct=getDialogSchema(this,~)
            panel=struct('Type','panel','LayoutGrid',[3,1],'RowStretch',[0,0,1]);

            instructions=struct('Type','text','Name',getString(message('Slvnv:slreq:ExportInstructions')),...
            'RowSpan',[1,1],'ColSpan',[1,1]);

            panel.Items={instructions};

            schema.Type='panel';
            [schema.Items,schema.LayoutGrid]=this.exportMappingOptions();
            panel.Items{end+1}=schema;

            schema.Type='panel';
            [schema.Items,schema.LayoutGrid]=this.linkOptions();
            panel.Items{end+1}=schema;

            schema.Type='panel';
            [schema.Items,schema.LayoutGrid]=this.ouputFileOptions();
            panel.Items{end+1}=schema;

            dlgstruct.DialogTag='ExportDlg';
            dlgstruct.DialogTitle=this.getDialogTitle();
            dlgstruct.StandaloneButtonSet=this.setStandaloneButtons();
            dlgstruct.Items={panel};

            dlgstruct.CloseMethod='ExportDlg_Cancel_callback';
            dlgstruct.CloseMethodArgs={'%dialog'};
            dlgstruct.CloseMethodArgsDT={'handle'};

            dlgstruct.Sticky=true;
        end

        function out=getDialogTitle(this)
            if~isempty(this.importNode)

                out=getString(message('Slvnv:slreq:ExportDialogCurrent',this.importNode.id));
            else

                out=getString(message('Slvnv:slreq:ExportDialog'));
            end
        end

        function out=isReadyForExport(this)
            out=~isempty(this.outputFile)&&(~isempty(this.mappingFile)||this.useStoredmapping)&&isempty(this.errorText);
        end

        function out=setStandaloneButtons(this)

            isReady=this.isReadyForExport();

            if exist(this.outputFile,'file')==2
                this.warningText=getString(message('Slvnv:slreq:ExportDialogWarningOutputFileExists'));
            end

            noteText.Type='text';
            noteText.Tag='ExportDlg_blockingMsg';
            noteText.Name=this.getErrorOrWarning();
            noteText.ForegroundColor=[255,0,0];
            noteText.Alignment=1;
            noteText.RowSpan=[1,1];
            noteText.ColSpan=[1,2];

            exportButton.Name=getString(message('Slvnv:slreq:ExportDialogExport'));
            exportButton.Tag='ExportDlg_Export';
            exportButton.Type='pushbutton';
            exportButton.RowSpan=[1,1];
            exportButton.ColSpan=[3,3];
            exportButton.ObjectMethod='ExportDlg_Export_callback';
            exportButton.MethodArgs={'%dialog'};
            exportButton.ArgDataTypes={'handle'};
            exportButton.Enabled=isReady;

            cancelButton.Name=getString(message('Slvnv:slreq_import:Cancel'));
            cancelButton.Tag='ExportDlg_Cancel';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[4,4];
            cancelButton.ObjectMethod='ExportDlg_Cancel_callback';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.Enabled=true;

            helpButton.Name=getString(message('Slvnv:slreq:ExportDialogHelp'));
            helpButton.Tag='ExportDlg_Help';
            helpButton.Type='pushbutton';
            helpButton.RowSpan=[1,1];
            helpButton.ColSpan=[5,5];
            helpButton.ObjectMethod='ExportDlg_Help_callback';
            helpButton.MethodArgs={'%dialog'};
            helpButton.ArgDataTypes={'handle'};
            helpButton.Enabled=true;

            out.Tag='ExportDlg_standalonebuttons';
            out.LayoutGrid=[1,5];
            out.Name='';
            out.Type='panel';
            out.Items={noteText,exportButton,cancelButton,helpButton};
        end




        function[items,grid]=linkOptions(this)

            exportLinks.Type='checkbox';
            exportLinks.Name=getString(message('Slvnv:slreq:ExportDialogExportLinks'));
            exportLinks.ToolTip=getString(message('Slvnv:slreq:ExportDialogExportLinksTooltip'));
            exportLinks.Tag='ExportDlg_exportLinks';
            exportLinks.Enabled=true;


            exportLinks.Value=false;
            exportLinks.Mode=true;
            exportLinks.Graphical=true;
            exportLinks.RowSpan=[1,1];
            exportLinks.ColSpan=[1,4];
            exportLinks.MatlabMethod='exportLinks_callback';
            exportLinks.MatlabArgs={this,'%dialog'};

            exportLinksNote.Type='text';
            exportLinksNote.Tag='ExportDlg_exportLinksNote';
            exportLinksNote.Name=getString(message('Slvnv:slreq:ExportLinksYouWillNot'));
            exportLinksNote.RowSpan=[2,2];
            exportLinksNote.ColSpan=[1,4];

            exportSpacer.Type='text';
            exportSpacer.Tag='ExportDlg_exportSpacer';
            exportSpacer.Name=' ';
            exportSpacer.RowSpan=[3,3];
            exportSpacer.ColSpan=[1,4];

            exportContentGroup.Type='group';
            exportContentGroup.Name=getString(message('Slvnv:slreq:ExportDialogExportContent'));
            exportContentGroup.LayoutGrid=[3,4];
            exportContentGroup.Items={...
            exportLinks,...
            exportLinksNote,...
            exportSpacer};
            exportContentGroup.RowSpan=[1,2];
            exportContentGroup.ColSpan=[1,1];

            items={exportContentGroup};
            grid=[1,1];
        end

        function[items,grid]=ouputFileOptions(this)

            outputFileValue.Type='text';
            outputFileValue.Tag='ExportDlg_fileValue';
            outputFileValue.Name=this.outputFile;
            outputFileValue.RowSpan=[2,2];
            outputFileValue.ColSpan=[1,4];

            outputFileButton.Type='pushbutton';
            outputFileButton.Name=getString(message('Slvnv:slreq_import:Browse'));
            outputFileButton.Tag='ExportDlg_ouputFileBrowse';
            outputFileButton.RowSpan=[2,2];
            outputFileButton.ColSpan=[5,5];
            outputFileButton.ObjectMethod='ExportDlg_ouputFileBrowse_callback';
            outputFileButton.MethodArgs={'%dialog'};
            outputFileButton.ArgDataTypes={'handle'};

            outputFileSpacer.Type='text';
            outputFileSpacer.Tag='ExportDlg_outputFileSpacer';
            outputFileSpacer.Name=' ';
            outputFileSpacer.RowSpan=[3,3];
            outputFileSpacer.ColSpan=[1,5];

            outputFileGroup.Type='group';
            outputFileGroup.Name=getString(message('Slvnv:slreq:ExportOutputFile'));
            outputFileGroup.LayoutGrid=[3,5];
            outputFileGroup.Items={...
            outputFileValue,outputFileButton,...
            outputFileSpacer};
            outputFileGroup.RowSpan=[3,3];
            outputFileGroup.ColSpan=[1,1];

            items={outputFileGroup};
            grid=[1,1];
        end

        function[items,grid]=exportMappingOptions(this)








            this.useStoredmapping=false;
            this.allMappings=this.mappingMgr.getAllMappings();

            mappingFileValue.Type='combobox';
            mappingFileValue.Tag='ExportDlg_mappingValue';
            genericMapping=this.mappingMgr.getGenericMapping();
            genericMappingName=genericMapping.name;
            genericMappingIdx=find(strcmp(this.allMappings,genericMappingName));
            if~isempty(this.storedMapping)
                this.matchStoredMapping();
                if isempty(this.storedMappingName)
                    firstOption=getString(message('Slvnv:slreq:ExportMappingUseExisting'));
                elseif strcmp(this.storedMappingName,genericMappingName)
                    firstOption=[];
                else
                    firstOption=getString(message('Slvnv:slreq:ExportMappingUseMatched',this.storedMappingName));
                end
                if isempty(firstOption)
                    mappingFileValue.Entries={genericMappingName};
                    mappingFileValue.Values=genericMappingIdx;
                    mappingFileValue.Value=genericMappingIdx;
                    this.commitSelectedMapping(genericMapping);
                else
                    mappingFileValue.Entries={firstOption,genericMappingName};
                    mappingFileValue.Values=[0,genericMappingIdx];
                    mappingFileValue.Value=0;
                    this.commitStoredMapping();
                end
            else
                mappingFileValue.Entries=this.allMappings;
                mappingFileValue.Values=1:numel(this.allMappings);
                mappingFileValue.Value=genericMappingIdx;
                this.commitSelectedMapping(genericMapping);
            end
            mappingFileValue.Editable=false;
            mappingFileValue.Enabled=(numel(mappingFileValue.Values)>1);
            mappingFileValue.RowSpan=[1,1];
            mappingFileValue.ColSpan=[1,4];
            mappingFileValue.ObjectMethod='ExportDlg_mappingFileEdit_callback';
            mappingFileValue.MethodArgs={'%dialog'};
            mappingFileValue.ArgDataTypes={'handle'};

            mappingDescription.Type='text';
            mappingDescription.Tag='ExportDlg_mappingDesc';
            mappingDescription.Name=this.mappingDesc;
            mappingDescription.RowSpan=[2,2];
            mappingDescription.ColSpan=[1,4];

            mappingFileSpacer.Type='text';
            mappingFileSpacer.Tag='ExportDlg_mappingFileSpacer';
            mappingFileSpacer.Name=' ';
            mappingFileSpacer.RowSpan=[3,3];
            mappingFileSpacer.ColSpan=[1,4];

            mappingFileGroup.Type='group';
            mappingFileGroup.Name=getString(message('Slvnv:slreq:ExportMapping'));
            mappingFileGroup.LayoutGrid=[3,4];
            mappingFileGroup.Items={...
            mappingFileValue,...
            mappingDescription,...
            mappingFileSpacer};
            mappingFileGroup.RowSpan=[2,2];
            mappingFileGroup.ColSpan=[1,1];

            items={mappingFileGroup};
            grid=[1,1];
        end

        function matchStoredMapping(this)
            if~isempty(this.storedMapping)
                capturedDescription=this.storedMapping.description;
                for i=1:numel(this.allMappings)
                    mappingName=this.allMappings{i};
                    oneMapping=this.mappingMgr.getMappingInfo(mappingName);
                    if~isempty(oneMapping)
                        if contains(capturedDescription,oneMapping.desc)
                            this.storedMappingIdx=i;
                            this.storedMappingName=mappingName;
                            return;
                        end
                    end
                end

                this.storedMappingName='';
                this.storedMappingIdx=0;
            end
        end


        function out=hasNoError(this)
            out=isempty(this.errorText);
        end


        function out=getErrorOrWarning(this)

            if~isempty(this.errorText)
                out=this.errorText;
                return;
            end

            out=this.warningText;
        end

        function clearErrorText(this,dlg)

            this.errorText='';
            this.warningText='';


            dlg.setWidgetValue('ExportDlg_blockingMsg','');


            okToExport=this.hasNoError();
            dlg.setEnabled('ExportDlg_Export',okToExport);

        end

        function setErrorText(this,dlg,value,errorType)
            if nargin<4
                errorType=this.USER_ERROR;
            end

            switch(errorType)
            case this.USER_ERROR
                this.errorText=value;
            case this.USER_WARNING
                this.warningText=value;
            end


            dlg.setWidgetValue('ExportDlg_blockingMsg',value);


            okToExport=this.hasNoError();
            dlg.setEnabled('ExportDlg_Export',okToExport);
        end





        function ExportDlg_ouputFileBrowse_callback(this,dlg)
            fileFilters={...
            '*.reqif;*.reqifz',getString(message('Slvnv:slreq_import:AllReqifFiles','(*.reqif,*.reqifz)'));...
            '*.reqif',getString(message('Slvnv:slreq_import:ReqifFiles','(*.reqif)'));...
            '*.reqifz',getString(message('Slvnv:slreq_import:ReqifzFiles','(*.reqifz)'))};

            [filename,pathname]=uiputfile(fileFilters,...
            getString(message('Slvnv:slreq:ExportOutputPutFile')),this.outputFile);

            if~isequal(filename,0)
                selectedValue=fullfile(pathname,filename);
                dlg.setWidgetValue('ExportDlg_fileValue',selectedValue);
                [isValid,selectedFile]=this.validateOutputFile(dlg);
                if isValid
                    this.outputFile=selectedFile;
                end
            end
        end





        function[isValid,selectedFile]=validateOutputFile(this,dlg)

            selectedFile='';
            isValid=false;


            this.clearErrorText(dlg);

            outputValue=dlg.getWidgetValue('ExportDlg_fileValue');

            if isempty(outputValue)
                this.setErrorText(dlg,getString(message('Slvnv:slreq:ExportDialogErrorNoOutputFile')));
                return;
            end


            [fPath,fName,fExt]=fileparts(outputValue);


            fPath=strtrim(fPath);
            fName=strtrim(fName);
            fExt=strtrim(fExt);


            oldExt=fExt;


            if~any(strcmpi(oldExt,{this.REQIF,this.REQIFZ}))
                this.setErrorText(dlg,getString(message('Slvnv:slreq:ExportDialogErrorNoExtension')));
                return;
            end


            if strcmpi(fExt,this.REQIF)&&slreq.internal.hasImagesToExport(this.reqSet.name)



                fExt=this.REQIFZ;
            end

            if~strcmpi(fExt,oldExt)

                if strcmpi(oldExt,this.REQIF)
                    this.setErrorText(dlg,getString(message('Slvnv:slreq:ExportDialogErrorWrongExtension')));
                    return;
                end
            end


            if isempty(fName)


            end


            if isempty(fPath)


            end



            selectedFile=fullfile(fPath,[fName,fExt]);
            if exist(selectedFile,'file')==2
                this.setErrorText(dlg,getString(message('Slvnv:slreq:ExportDialogWarningOutputFileExists')),this.USER_WARNING);
            end


            isValid=true;
        end

        function ExportDlg_mappingFileEdit_callback(this,dlg)
            mappingValue=dlg.getWidgetValue('ExportDlg_mappingValue');
            if mappingValue==0

                this.commitStoredMapping();
                this.clearErrorText(dlg);
            else


                selectedMappingName=this.allMappings{mappingValue};
                mappingInfo=this.mappingMgr.getMappingInfo(selectedMappingName);
                this.commitSelectedMapping(mappingInfo);
                this.validateTemplate(dlg);

            end
            dlg.setWidgetValue('ExportDlg_mappingDesc',this.mappingDesc);

            if~this.hasNoError
                if exist(this.outputFile,'file')==2
                    warningToDisplay=getString(message('Slvnv:slreq:ExportDialogWarningOutputFileExists'));
                    this.setErrorText(dlg,warningToDisplay,this.USER_WARNING);
                end
            end
        end

        function commitStoredMapping(this)
            this.mappingFile='';
            this.templateFile='';
            this.mappingDesc=getString(message('Slvnv:slreq:ExportMappingUseExistingDesc'));
            this.useStoredmapping=true;
        end

        function commitSelectedMapping(this,selectedMapping)
            this.mappingFile=selectedMapping.fullpath;
            this.mappingDesc=selectedMapping.desc;
            this.templateFile=selectedMapping.template;
        end


        function ExportDlg_Cancel_callback(~,dlg)
            dlg.delete();
        end


        function ExportDlg_Help_callback(~,~)
            helpview(fullfile(docroot,'slrequirements','helptargets.map'),'export_reqif');
        end








        function validateTemplate(this,dlg)


            this.clearErrorText(dlg);


            if isempty(this.templateFile)
                return;
            end


            if exist(this.templateFile,'file')~=2
                this.setErrorText(dlg,getString(message('Slvnv:slreq:ExportDialogErrorTemplateMissing')));
                return;
            end





            templateSourceTool=this.mappingMgr.getSourceTool(this.templateFile);
            if isempty(templateSourceTool)
                this.setErrorText(dlg,getString(message('Slvnv:slreq:ExportDialogErrorTemplateDefinitions')));
                return;
            end

            if isempty(this.storedMapping)

                varDesc=this.mappingDesc;
            else
                varDesc=this.storedMapping.description;
            end


            templateMappingInfo=this.mappingMgr.detectMapping(this.templateFile);

            if~isempty(templateMappingInfo)



                templateDesc=templateMappingInfo.desc;


                if~strcmp(templateDesc,varDesc)
                    this.setErrorText(dlg,getString(message('Slvnv:slreq:ExportDialogErrorTemplateIncompatible')));
                    return;
                end
            end
        end


        function ExportDlg_Export_callback(this,dlg)

            exportLinks=dlg.getWidgetValue('ExportDlg_exportLinks');
            linkOptions=struct('exportLinks',exportLinks,'minimalAttributes',false);

            this.reqSet.exportToReqIF(this.outputFile,this.importNode,this.mappingFile,this.templateFile,linkOptions);
            dlg.delete();
        end
    end
end
