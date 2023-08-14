classdef SourceSelector<handle








    properties(SetAccess=private)
Ds
        DatasetName char
        SourceIndx double=0
        SourceList={}
        CloseFcnHandle=function_handle.empty
        Txt=''
    end

    properties(Access=private,Constant)
        FORMAT_STR='%-30s'
        PARAM_SKIP_LIST={'SimulationOutput','SendSimulationInputTo',...
        'DatasetName','SourceName','RecordingStartTime','PayloadSizeFieldLen','TotalReceivedSamples','HWSignalInfo','SignalInfo'}
    end


    methods
        function obj=SourceSelector(datasetName)
            datasetName=convertStringsToChars(datasetName);
            try
                obj.Ds=RecordedData(datasetName);
            catch EX
                error(message('ioplayback:utils:InvalidDataset'));
            end
            [~,f]=fileparts(datasetName);
            obj.DatasetName=f;
        end


        function dlg=openDialog(obj,closeFcnHandle)







            validateattributes(closeFcnHandle,{'function_handle'},{'scalar'});
            obj.CloseFcnHandle=closeFcnHandle;
            updateSourceList(obj);
            if~isempty(obj.Ds.Sources)
                updatePropertyList(obj,obj.Ds.Sources{1});
            end
            dlg=DAStudio.Dialog(obj);
            dlg.setWidgetValue('sourcelist',obj.SourceIndx);
        end
    end


    methods(Hidden)

        function dlgCallback(obj,dlg,tag,value)%#ok<INUSL>
            obj.SourceIndx=value;
            updatePropertyList(obj,obj.Ds.Sources{obj.SourceIndx+1});
            dlg.refresh;
        end


        function dlgDoubleClick(obj,dlg,~,indx)
            obj.SourceIndx=indx;
            dlgClose(obj,dlg,'ok');
            obj.CloseFcnHandle=function_handle.empty;
            delete(dlg);
        end

        function dlgClose(obj,dlg,closeaction)%#ok<INUSL>


            if~isempty(obj.CloseFcnHandle)
                isAcceptedSelection=strcmpi(closeaction,'ok');
                if isempty(obj.Ds.Sources)
                    return;
                end
                sourceName=obj.Ds.Sources{obj.SourceIndx+1};
                try
                    feval(obj.CloseFcnHandle,isAcceptedSelection,sourceName);
                catch



                end
            end
        end

        function updatePropertyList(obj,sourceName)
            src=getDataSource(obj.Ds,sourceName);
            props=fieldnames(src.params);
            obj.Txt='&nbsp;<b>Source parameters</b><div class="data"> <table>';
            formatStr='<td>  %-20s</td><td>: %-17s</td>';
            for k=1:min(10,numel(fieldnames(src.params)))
                if ismember(props{k},obj.PARAM_SKIP_LIST)
                    continue;
                end
                obj.Txt=[obj.Txt,['<tr>',...
                strrep(sprintf(formatStr,props{k},string(src.params.(props{k}))),' ','&nbsp;'),...
                '</tr>']];
            end
            obj.Txt=[obj.Txt,'</table>','</div>'];
        end

        function updateSourceList(obj)
            for k=1:numel(obj.Ds.Sources)
                src=getDataSource(obj.Ds,obj.Ds.Sources{k});%#ok<NASGU>
                obj.SourceList{k}=sprintf(obj.FORMAT_STR,...
                obj.Ds.Sources{k});
            end
        end

        function dlgstruct=getDialogSchema(obj)
            srcList.Name=sprintf('%-1s%-30s',' ','Name');
            srcList.Type='listbox';
            srcList.FontFamily='Consolas';
            srcList.Entries=obj.SourceList;
            srcList.Tag='sourcelist';
            srcList.MultiSelect=false;
            srcList.ListDoubleClickCallback=@(hDlg,tag,idx)dlgDoubleClick(obj,hDlg,tag,idx);
            srcList.ObjectMethod='dlgCallback';
            srcList.MethodArgs={'%dialog','%tag','%value'};
            srcList.ArgDataTypes={'handle','string','mxArray'};
            srcList.Value=0;
            srcList.MinimumSize=[300,80];
            srcList.NameLocation=2;


            paramPrompt.Type='text';
            paramPrompt.Name='Details:';

            paramList.Name='Parameters for source';
            paramList.NameLocation=2;
            paramList.FontFamily='Consolas';
            paramList.Type='textbrowser';
            paramList.Text=obj.Txt;

            paramList.MinimumSize=[350,100];

            groupBox.Name='Sources';
            groupBox.Type='group';
            groupBox.Items={srcList,paramPrompt,paramList};
            groupBox.RowSpan=[1,1];
            groupBox.ColSpan=[1,1];
            groupBox.LayoutGrid=[1,1];


            dlgstruct.DialogTitle='Select source';
            dlgstruct.HelpMethod='soc.internal.openDoc';
            dlgstruct.HelpArgs={'soc_ref.pdf'};
            dlgstruct.CloseMethod='dlgClose';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};



            dlgstruct.Sticky=true;




            dlgstruct.StandaloneButtonSet=...
            {'Ok','Cancel','Help'};

            dlgstruct.Items={groupBox};
        end
    end
end

