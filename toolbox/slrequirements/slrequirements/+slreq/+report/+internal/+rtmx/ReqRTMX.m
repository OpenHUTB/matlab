classdef ReqRTMX<handle



    properties(Access=private)
        matrixStr;
        filedir=tempname;
        filename='testing.html';
        filepath;
    end


    methods(Access=public)

        function dlgstruct=getDialogSchema(this)





            matrix=getMatrixSchema(this);
            matrix.RowSpan=[1,1];

            bottompart=getBottemPart(this);
            bottompart.RowSpan=[2,2];




            dlgstruct.Items={matrix,bottompart};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.IsScrollable=false;
            dlgstruct.DispatcherEvents={};
            dlgstruct.IgnoreESCClose=true;
            dlgstruct.MinMaxButtons=true;
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq:RequirementTraceabilityMatrix'));







            dlgstruct.LayoutGrid=[2,3];
            dlgstruct.RowStretch=[1,0];
            dlgstruct.Geometry=[10,10,800,600];
            dlgstruct.DialogTag='slreq_rtmx';
            dlgstruct.CloseMethod='callBackCancelButton';
            dlgstruct.CloseMethodArgs={'%dialog'};
            dlgstruct.CloseMethodArgsDT={'handle'};
        end


        function createTableStr(this)
            import slreq.report.internal.rtmx.*
            this.matrixStr=createForwardTable();
        end


        function createHTMLFile(this)
            import slreq.report.internal.rtmx.*
            this.setfullpath();
            fullpath=this.filepath;
            writeTableStrToFile(this.matrixStr,fullpath);
        end


        function show(this)
            dlg=findDDGByTag('slreq_rtmx');



            if ishandle(dlg)
                dlg.show;
            else
                dlg=DAStudio.Dialog(this);
                dlg.show;
            end
        end
    end




    methods(Access=private)

        function this=ReqRTMX()
            this.filedir=tempname;
            this.filename='testing.html';
        end
    end

    methods(Access=private)

        function webTable=getMatrixSchema(this)
            webTable.Tag='RMTXDDGWeb';
            webTable.Type='webbrowser';
            webTable.WebKit=true;


            webTable.Url=this.filepath;


            webTable.EnableJsOnClipboard=true;

            webTable.EnableInspectorInContextMenu=true;





            webTable.ClearCache=true;






            webTable.PreferredSize=[20,20];
        end


        function setfullpath(this)
            if~exist(this.filedir,'dir')
                mkdir(this.filedir);
            end
            this.filepath=fullfile(this.filedir,this.filename);
        end



        function bottomPart=getBottemPart(this)

            refreshButton.Name=getString(message('Slvnv:slreq:Refresh'));
            refreshButton.Tag='slreqrtmx_refresh';
            refreshButton.Type='pushbutton';
            refreshButton.RowSpan=[1,1];
            refreshButton.ColSpan=[2,2];
            refreshButton.ObjectMethod='callBackRefreshButton';
            refreshButton.MethodArgs={'%dialog'};
            refreshButton.ArgDataTypes={'handle'};
            refreshButton.ToolTip='';


            quickrefreshButton.Name='Quick Refresh';
            quickrefreshButton.Tag='slreqrtmx_quickrefresh';
            quickrefreshButton.Type='pushbutton';
            quickrefreshButton.RowSpan=[1,1];
            quickrefreshButton.ColSpan=[3,3];
            quickrefreshButton.ObjectMethod='callBackRefreshFormatButton';
            quickrefreshButton.MethodArgs={'%dialog'};
            quickrefreshButton.ArgDataTypes={'handle'};
            quickrefreshButton.ToolTip='';

            cancelButton.Name=getString(message('Slvnv:slreq:Close'));
            cancelButton.Tag='slreqrtmx_refresh_cancel';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[4,4];
            cancelButton.ObjectMethod='callBackCancelButton';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.ToolTip='ddd';


            bottomPart.Tag='reqrptopt_panel_standalongbuttons';
            bottomPart.LayoutGrid=[1,4];
            bottomPart.Name='';
            bottomPart.Type='panel';
            bottomPart.Items={refreshButton,quickrefreshButton,cancelButton};
            bottomPart.Enabled=true;
        end
    end


    methods(Access=public,Hidden=true)





        function callBackCancelButton(~,dlg)
            dlg.delete();
        end

        function callBackRefreshButton(this,dlg)
            this.createTableStr();
            this.createHTMLFile();



            dlg.refresh;
            msgbox('done');
        end


        function callBackRefreshFormatButton(this,dlg)
            this.createHTMLFile();



            dlg.refresh;
            msgbox('done');
        end

        function out=getFilePath(this)
            out=this.filepath;
        end

    end

    methods(Static)
        function singleton=getInstance()
            persistent reqrtmx;
            if isempty(reqrtmx)||~isvalid(reqrtmx)
                reqrtmx=slreq.report.internal.rtmx.ReqRTMX;
            end
            singleton=reqrtmx;
        end

        function exportToExcel()
            import slreq.report.internal.rtmx.*
            dlg=findDDGByTag('slreq_rtmx');
            imd=DAStudio.imDialog.getIMWidgets(dlg);
            browser=imd.find('tag','RMTXDDGWeb');







            htmlContent=browser.getHTML;
            tableContent=regexp(htmlContent,'<table id="forwardTable">(.*?)</table>','tokens');
            tableContent=tableContent{1}{1};
            htmlStr=createCellStr('table',...
            tableContent,...
            'border','1px');
            bodyStr=createCellStr('body',...
            htmlStr);
            excelInfo{1}=createCellStr('x:Name',...
            'Requirement Traceability Matrix');
            excelInfo{2}=createCellStr(...
            'x:WorksheetOptions','<x:Panes></x:Panes>');
            sheetInfo=createCellStr(...
            'x:ExcelWorksheet',[excelInfo{1},excelInfo{2}]);

            sheetsInfo=createCellStr(...
            'x:ExcelWorksheets',sheetInfo);
            bookInfo=createCellStr(...
            'x:ExcelWorkbook',sheetsInfo);

            xmlInfo=createCellStr(...
            'xml',bookInfo);

            headInfo=createCellStr(...
            'head',xmlInfo);

            htmlStr=createCellStr(...
            'html',[headInfo,bodyStr],...
            'xmlns:x','urn:schemas-microsoft-com:office:excel');

            fid=fopen('testing.xls','w');

            fprintf(fid,'%s',['data:application/vnd.ms-excel,',htmlStr]);
            fclose(fid);

        end
    end



end




