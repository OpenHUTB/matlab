

classdef CustomGridDialog<handle





    properties(SetObservable=true)


        blockHandle='';
        mdlHandle='';
        mdlName='';
        dlgInstance={};

        Position=[100,100];

    end

    properties(Hidden)
        Url;
        showHelpSub;
        channelPrefix;
        handleStr;
    end

    methods

        function gridDlg=CustomGridDialog(modelName,blockH)
            gridDlg=gridDlg@handle;
            gridDlg.blockHandle=blockH;
            gridDlg.mdlName=modelName;
            gridDlg.mdlHandle=get_param(modelName,'handle');
        end


        function setPositionWrtModelWindow(obj)



            pos=get_param(obj.mdlHandle,'Location');

            obj.Position=round([pos(1)+(pos(3)/3),pos(2)+(pos(4)/3)]);
        end


        function showGridDialog(obj)
            if isempty(obj.dlgInstance)
                obj.dlgInstance=DAStudio.Dialog(obj);
            else
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end

        function closeGridDialog(obj,~)
            message.unsubscribe(obj.showHelpSub);
            if~isempty(obj.dlgInstance)
                delete(obj.dlgInstance);
                obj.dlgInstance={};
            end
        end

        function deleteDialog(obj,~)
            if~isempty(obj.dlgInstance)
                message.unsubscribe(obj.showHelpSub);
                delete(obj.dlgInstance);
                obj.dlgInstance={};
            end
        end

        function[row,col]=getRowColumnsFromLayout(obj,layout)
            layout(strfind(layout,'['))=[];
            layout(strfind(layout,']'))=[];
            grid=sscanf(layout,'%d');
            if numel(grid)==2
                row=num2str(grid(1));
                col=num2str(grid(2));
            end
        end

        function[success,errmsg]=gridDlgPreApplyCB(obj,dlg)
            success=true;
            errmsg='';
            try
                utils.recordDialogUtils.setGridLayout(dlg,obj);
            catch
                success=false;
                errmsg=DAStudio.message('record_playback:errors:InvalidRowColumns');
            end
        end

        function dlgstruct=getDialogSchema(obj)

            dlgSize=[200,120];

            dlgstruct.DialogTitle=...
            DAStudio.message('record_playback:toolstrip:GridDialog',...
            get_param(obj.blockHandle,'Name'));

            layout=utils.recordDialogUtils.getGridFromLayout(obj.blockHandle);
            row='';
            column='';

            if~isempty(layout)
                [row,column]=obj.getRowColumnsFromLayout(layout);
            end

            RowLabel.Type='text';
            RowLabel.Name=...
            DAStudio.message('record_playback:dialogs:Rows');
            RowLabel.WordWrap=true;
            RowLabel.RowSpan=[1,1];
            RowLabel.ColSpan=[1,1];

            RowValue.Type='edit';
            RowValue.Tag='RowValue';
            RowValue.Enabled=true;
            RowValue.Value=row;
            RowValue.RowSpan=[1,1];
            RowValue.ColSpan=[2,2];

            ColLabel.Type='text';
            ColLabel.Name=...
            DAStudio.message('record_playback:dialogs:Columns');
            ColLabel.WordWrap=true;
            ColLabel.RowSpan=[1,1];
            ColLabel.ColSpan=[3,3];

            ColValue.Type='edit';
            ColValue.Tag='ColValue';
            ColValue.Enabled=true;
            ColValue.Value=column;
            ColValue.RowSpan=[1,1];
            ColValue.ColSpan=[4,4];

            dlgstruct.PreApplyMethod='gridDlgPreApplyCB';
            dlgstruct.PreApplyArgs={'%dialog'};
            dlgstruct.PreApplyArgsDT={'handle'};
            dlgstruct.CloseMethod='closeGridDialog';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
            dlgstruct.LayoutGrid=[1,4];
            dlgstruct.ColStretch=[1,0,1,0];
            dlgstruct.Items={RowLabel,RowValue,...
            ColLabel,ColValue};
            dlgstruct.StandaloneButtonSet={'Ok','Cancel'};
            dlgstruct.IsScrollable=false;
            setPositionWrtModelWindow(obj);
            dlgstruct.Geometry=[obj.Position,dlgSize];
            dlgstruct.MinMaxButtons=false;
            dlgstruct.DialogStyle='normal';

        end
    end
end
