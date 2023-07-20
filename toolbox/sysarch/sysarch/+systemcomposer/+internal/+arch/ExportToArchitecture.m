classdef ExportToArchitecture<systemcomposer.internal.mixin.ModelClose





    properties
        SrcModel char;
        ArchModelName char;
        DstPath char;
    end

    properties(Access=private)
        hasErrors logical;
        widgetsWithWarning cell;
    end

    methods(Static)
        function launch(mdl)


            dlg=findDDGByTag(getDialogTag(mdl));

            if isempty(dlg)
                obj=systemcomposer.internal.arch.ExportToArchitecture(mdl);
                dlg=DAStudio.Dialog(obj);
            end
            dlg.show();
        end
    end

    methods
        function this=ExportToArchitecture(srcModel)


            if nargin==0||isempty(srcModel)
                this.SrcModel='';
            else
                this.SrcModel=srcModel;


                this.ArchModelName=[this.SrcModel,'_arch.slx'];
                this.DstPath=pwd;
            end

            this.hasErrors=false;
            this.widgetsWithWarning={};

            this.registerCloseListener(get_param(srcModel,'handle'));
        end

        function schema=getDialogSchema(this)





            desc.Type='text';
            desc.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogDescription');
            desc.WordWrap=true;
            desc.MinimumSize=[500,10];
            desc.RowSpan=[1,1];
            desc.ColSpan=[1,1];


            descGroup.Type='group';
            descGroup.Name=DAStudio.message('Simulink:dialog:ModelTabFiveName');
            descGroup.Items={desc};
            descGroup.LayoutGrid=[1,1];
            descGroup.RowSpan=[1,1];
            descGroup.ColSpan=[1,1];



            row=0;

            row=row+1;
            srcModel.Type='edit';
            srcModel.Tag='srcModelEdit';
            srcModel.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogSrcModels');
            srcModel.Source=this;
            srcModel.Value=this.SrcModel;
            srcModel.ObjectMethod='setSrcModel';
            srcModel.MethodArgs={'%dialog','%value'};
            srcModel.ArgDataTypes={'handle','char'};
            srcModel.Mode=true;
            srcModel.Graphical=true;
            srcModel.RowSpan=[row,row];
            srcModel.ColSpan=[1,2];
            srcModel.Enabled=false;

            browseSrcs.Type='pushbutton';
            browseSrcs.Tag='browseSrcsButton';
            browseSrcs.Source=this;
            browseSrcs.ObjectMethod='handleClickBrowseSources';
            browseSrcs.MethodArgs={};
            browseSrcs.ArgDataTypes={};
            browseSrcs.Graphical=true;
            browseSrcs.RowSpan=[row,row];
            browseSrcs.ColSpan=[3,3];
            browseSrcs.Enabled=true;
            browseSrcs.ToolTip=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogBrowseSrcTooltip');
            browseSrcs.FilePath=this.resource('open');
            browseSrcs.Enabled=false;

            row=row+1;
            archModelName.Type='edit';
            archModelName.Tag='archModelNameEdit';
            archModelName.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogArchModelName');
            archModelName.Source=this;
            archModelName.Value=this.ArchModelName;
            archModelName.ObjectMethod='setArchModelName';
            archModelName.MethodArgs={'%dialog','%value'};
            archModelName.ArgDataTypes={'handle','char'};
            archModelName.Mode=true;
            archModelName.Graphical=true;
            archModelName.RowSpan=[row,row];
            archModelName.ColSpan=[1,3];

            row=row+1;
            dstPath.Type='edit';
            dstPath.Tag='dstPathEdit';
            dstPath.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogDstFolder');
            dstPath.Source=this;
            dstPath.Value=this.DstPath;
            dstPath.ObjectMethod='setDstPath';
            dstPath.MethodArgs={'%dialog','%value'};
            dstPath.ArgDataTypes={'handle','char'};
            dstPath.Mode=true;
            dstPath.Graphical=true;
            dstPath.RowSpan=[row,row];
            dstPath.ColSpan=[1,2];

            browseDstPath.Type='pushbutton';
            browseDstPath.Tag='browseFileButton';
            browseDstPath.Source=this;
            browseDstPath.ObjectMethod='handleClickBrowseDstPath';
            browseDstPath.MethodArgs={'%dialog'};
            browseDstPath.ArgDataTypes={'handle'};
            browseDstPath.Graphical=true;
            browseDstPath.RowSpan=[row,row];
            browseDstPath.ColSpan=[3,3];
            browseDstPath.Enabled=true;
            browseDstPath.ToolTip=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogBrowseTooltip');
            browseDstPath.FilePath=this.resource('open');

            configGroup.Type='group';
            configGroup.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogConfig');
            configGroup.Items={archModelName,srcModel,browseSrcs,browseDstPath,dstPath};
            configGroup.LayoutGrid=[row,3];
            configGroup.ColStretch=[1,1,0];

            help.Type='pushbutton';
            help.Tag='helpButton';
            help.Source=this;
            help.ObjectMethod='handleClickHelp';
            help.MethodArgs={};
            help.ArgDataTypes={};
            help.Graphical=true;
            help.RowSpan=[1,1];
            help.ColSpan=[1,1];
            help.Enabled=true;
            help.ToolTip=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogHelpTooltip');
            help.FilePath=this.resource('help');
            help.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogHelp');

            cancel.Type='pushbutton';
            cancel.Tag='cancelButton';
            cancel.Source=this;
            cancel.ObjectMethod='handleClickCancel';
            cancel.MethodArgs={'%dialog'};
            cancel.ArgDataTypes={'handle'};
            cancel.Graphical=true;
            cancel.RowSpan=[1,1];
            cancel.ColSpan=[3,3];
            cancel.Enabled=true;
            cancel.ToolTip=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogCancelTooltip');
            cancel.FilePath=this.resource(fullfile('webkit','Cancel_16'));
            cancel.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogCancel');

            export.Type='pushbutton';
            export.Tag='exportButton';
            export.Source=this;
            export.ObjectMethod='handleClickExport';
            archModelName=strrep(this.ArchModelName,'.slx','');
            export.MethodArgs={'%dialog',this.SrcModel,archModelName,this.DstPath};
            export.ArgDataTypes={'handle','string','string','string'};
            export.Graphical=true;
            export.RowSpan=[1,1];
            export.ColSpan=[4,4];
            export.Enabled=~this.hasErrors;
            export.ToolTip=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogExport');
            export.FilePath=this.resource('Validate_16');
            export.Name=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogExport');

            buttonPanel.Type='panel';
            buttonPanel.Items={help,cancel,export};
            buttonPanel.LayoutGrid=[1,4];
            buttonPanel.ColStretch=[0,1,0,0];
            buttonPanel.RowSpan=[3,3];
            buttonPanel.ColSpan=[1,1];

            panel.Type='panel';
            panel.Items={descGroup,configGroup,buttonPanel};
            panel.LayoutGrid=[3,1];
            panel.RowStretch=[0,1,0];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:studio:ExportToArchDialogTitle');

            schema.Items={panel};
            schema.DialogTag=getDialogTag(this.SrcModel);
            schema.Source=this;
            schema.SmartApply=true;
            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.CloseMethod='handleCloseDialog';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','char'};
            schema.StandaloneButtonSet={''};
            schema.MinMaxButtons=false;
            schema.ShowGrid=false;
            schema.DisableDialog=false;
        end

        function handleClickBrowseSources(~,~)




        end

        function handleClickBrowseDstPath(this,dlg)


            dirname=uigetdir(pwd,DAStudio.message('SystemArchitecture:studio:ExportToArchDialogBrowseTooltip'));
            if~ischar(dirname)
                return;
            end
            this.DstPath=dirname;
            dlg.refresh();
        end

        function setArchModelName(this,dlg,val)


            widget='archModelNameEdit';
            [name,ext]=strtok(val,'.');
            if isempty(ext)
                ext='.slx';
            end

            if~isvarname(name)
                this.error(dlg,widget,DAStudio.message('SystemArchitecture:studio:ExportToArchDialogInvalidMATLABVar'));
            elseif~strcmp(ext,'.slx')
                this.error(dlg,widget,DAStudio.message('SystemArchitecture:studio:ExportToArchDialogInvalidExt'));
            elseif exist([name,ext],'file')
                this.warning(dlg,widget,DAStudio.message('SystemArchitecture:studio:ExportToArchDialogFileExists'));
            else
                this.clear(dlg,widget);
            end

            this.ArchModelName=[name,ext];
        end

        function setDstPath(this,dlg,val)


            if strcmp(val,'pwd')
                val=pwd;
                this.clear(dlg,'dstPathEdit');
            elseif~exist(val,'dir')
                this.error(dlg,'dstPathEdit',DAStudio.message('SystemArchitecture:studio:ExportToArchDialogFolderNotExists'));
            else
                this.clear(dlg,'dstPathEdit');
            end
            this.DstPath=val;
        end

        function handleClickHelp(~)

            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'Export_SL_to_arch')
        end

        function handleClickCancel(~,dlg)


            delete(dlg);
        end

        function handleClickExport(~,dlg,srcMdl,archMdl,dstPath)


            dlg.hide();

            try
                doAutoArrange=true;
                showProgress=true;
                systemcomposer.internal.arch.exportToArch(srcMdl,archMdl,dstPath,doAutoArrange,showProgress);
            catch me
                M=MException(message('SystemArchitecture:studio:ErrorExportingToArchitecture',get_param(srcMdl,'Name'),me.getReport));
                M=M.addCause(me);
                dlg.show();
                throw(M);
            end


            delete(dlg);
        end

        function handleOpenDialog(~,~)

        end

        function handleCloseDialog(~,dlg,~)

            delete(dlg);
        end
    end

    methods(Access=private)
        function fpath=resource(~,name)


            fpath=fullfile(matlabroot,'toolbox','shared','dastudio','resources',[name,'.png']);
        end

        function error(this,dlg,widget,msg)


            err=DAStudio.UI.Util.Error;
            err.ID=['SystemComposer:ExportToArch:',widget];
            err.Tag=['Error_',widget];
            err.Type='Error';
            err.Message=msg;
            err.HiliteColor=[255,0,0,255];
            dlg.setWidgetWithError(widget,err);

            this.hasErrors=true;
            dlg.refresh();
        end

        function warning(this,dlg,widget,msg)


            this.clear(dlg,widget);

            err=DAStudio.UI.Util.Error;
            err.ID=['SystemComposer:ExportToArch:',widget];
            err.Tag=['Warning_',widget];
            err.Type='Warning';
            err.Message=msg;
            err.HiliteColor=[255,165,0,255];
            dlg.setWidgetWithError(widget,err);


            this.widgetsWithWarning=[this.widgetsWithWarning,{widget}];
        end

        function clear(this,dlg,widget)


            dlg.clearWidgetWithError(widget);


            idx=strcmp(this.widgetsWithWarning,widget);
            this.widgetsWithWarning=this.widgetsWithWarning(~idx);



            wError=dlg.getWidgetsWithError();
            wWarning=this.widgetsWithWarning();
            wError=setdiff(wError,wWarning);
            this.hasErrors=~isempty(wError);

            dlg.refresh();
        end

    end
end

function tag=getDialogTag(mdl)
    tag=['export_to_arch_model_',mdl];
end
