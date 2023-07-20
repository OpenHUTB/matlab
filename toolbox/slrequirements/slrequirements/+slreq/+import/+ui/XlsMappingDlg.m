classdef XlsMappingDlg<handle














    properties(Access=private)
        table=[];
        docObj=[];
        lastRow=[];
    end

    properties(Access=public)
        caller=[];
        srcDoc='';
        subDoc='';
        headersRow=[];
        allColumns=[];
        columnIndex=[];
        columnOptions=[];
        fromRow=[];
        toRow=[];
    end

    methods(Access=public)



        function dlgstruct=getDialogSchema(this)

            dlgstruct.Sticky=true;
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq_import:SelectRangeToImport'));
            dlgstruct.DialogTag='SlreqImportChildDialog';
            dlgstruct.Geometry=[400,200,800,500];
            dlgstruct.LayoutGrid=[3,2];

            this.docObj=rmidotnet.docUtilObj(this.srcDoc);

            if~isempty(this.docObj)
                docName=this.docObj.sName;
                subDocName=this.subDoc;
            else

                [~,fileName]=fileparts(this.srcDoc);
                docName=fileName;
                subDocName='';
            end

            title.Type='text';
            title.Name=getString(message('Slvnv:slreq_import:PartInDoc',subDocName,docName));
            title.Bold=true;
            title.Alignment=7;
            title.RowSpan=[1,1];
            title.ColSpan=[1,1];

            headersSelectorBtn.Name=getString(message('Slvnv:slreq_import:SelectHeaderRow'));
            headersSelectorBtn.Tag='SlreqImportDlg_xlsHeaderSelect';
            headersSelectorBtn.Type='pushbutton';
            headersSelectorBtn.RowSpan=[1,1];
            headersSelectorBtn.ColSpan=[2,2];
            headersSelectorBtn.MaximumSize=[205,25];
            headersSelectorBtn.Alignment=6;
            headersSelectorBtn.ObjectMethod='SlreqImportDlg_xlsHeaderSelect_callback';
            headersSelectorBtn.MethodArgs={'%dialog'};
            headersSelectorBtn.ArgDataTypes={'handle'};

            if~isempty(this.docObj)&&isempty(this.table)
                this.table=this.makeTable();
            end

            if isempty(this.table)



                msg1.Type='text';
                msg1.Name=getString(message('Slvnv:slreq_import:NoHeadersInDoc',docName));
                msg1.RowSpan=[2,2];
                msg1.ColSpan=[1,2];
                msg1.Alignment=6;

                msg2.Type='text';
                msg2.Name=getString(message('Slvnv:slreq_import:NoHeadersAdvice'));
                msg2.RowSpan=[3,3];
                msg2.ColSpan=[1,2];
                msg2.Alignment=6;

                dlgstruct.Items={headersSelectorBtn,title,msg1,msg2};
                errorToDisplay=getString(message('Slvnv:slreq_import:NoHeadersError',docName));
                dlgstruct.StandaloneButtonSet=this.setStandaloneButtons(errorToDisplay);

            else



                colsGroup.Type='group';
                colsGroup.Name=getString(message('Slvnv:slreq_import:ColsToImport'));
                colsGroup.RowSpan=[2,2];
                colsGroup.ColSpan=[1,2];
                colsGroup.Items={this.table};



                labelFrom.Type='text';
                labelFrom.Name=getString(message('Slvnv:slreq_import:FromRow'));
                labelFrom.Alignment=7;
                labelFrom.RowSpan=[1,1];
                labelFrom.ColSpan=[1,1];

                editFrom.Type='edit';
                editFrom.Tag='SlreqImportDlg_editFrom';
                editFrom.Value=num2str(this.fromRow);
                editFrom.RowSpan=[1,1];
                editFrom.ColSpan=[2,2];
                editFrom.MaximumSize=[60,30];
                editFrom.ObjectMethod='SlreqImportDlg_editFrom_callback';
                editFrom.MethodArgs={'%dialog'};
                editFrom.ArgDataTypes={'handle'};


                labelTo.Type='text';
                labelTo.Name=getString(message('Slvnv:slreq_import:ToRow'));
                labelTo.Alignment=7;
                labelTo.RowSpan=[1,1];
                labelTo.ColSpan=[3,3];

                editTo.Type='edit';
                editTo.Value=num2str(this.toRow);
                editTo.Tag='SlreqImportDlg_editTo';
                editTo.RowSpan=[1,1];
                editTo.ColSpan=[4,4];
                editTo.MaximumSize=[60,30];
                editTo.ObjectMethod='SlreqImportDlg_editTo_callback';
                editTo.MethodArgs={'%dialog'};
                editTo.ArgDataTypes={'handle'};

                spacer.Type='text';
                spacer.Name=' ';
                spacer.RowSpan=[1,1];
                spacer.ColSpan=[5,6];

                rowsGroup.Type='group';
                rowsGroup.Name=getString(message('Slvnv:slreq_import:RowsToImport'));
                rowsGroup.RowSpan=[3,3];
                rowsGroup.ColSpan=[1,2];
                rowsGroup.LayoutGrid=[1,6];
                rowsGroup.Items={labelFrom,editFrom,labelTo,editTo,spacer};



                dlgstruct.Items={headersSelectorBtn,title,colsGroup,rowsGroup};
                [ok,info]=this.isValidOption();
                if~ok
                    beep;
                end
                dlgstruct.StandaloneButtonSet=this.setStandaloneButtons(info);
            end

            dlgstruct.CloseCallback='slreq.import.ui.attrDlg_mgr';
            dlgstruct.CloseArgs={'clear'};

        end

    end



    methods(Access=private)

        function table=makeTable(this)

            if isempty(this.headersRow)

                [this.headersRow,headersText]=rmidotnet.MSExcel.getColumnHeaders(this.srcDoc,this.subDoc);
                this.allColumns=1:size(headersText,2);
                this.columnIndex=this.allColumns;



                if isempty(headersText{1})
                    headersText(1)=[];
                    this.columnIndex(1)=[];
                end

                if this.headersRow<0
                    beep();
                    givenRow=this.promptForHeadersRow();
                    if givenRow<0
                        table=[];
                        return;
                    else
                        this.headersRow=givenRow;
                    end
                    headersText=this.verifyGivenHeadersRow();
                end
            else

                headersText=this.verifyGivenHeadersRow();
            end




            if isempty(headersText)
                table=[];
                return;
            end

            this.fromRow=this.headersRow+1;
            this.lastRow=this.docObj.countRows();
            this.toRow=this.lastRow;


            numRowsToPreview=20;
            rowRange=[this.headersRow+1,this.headersRow+numRowsToPreview];
            textFromCells=rmidotnet.MSExcel.getTextFromRange(this.srcDoc,rowRange,this.columnIndex);
            [isId,isNaturalText,isColumnEmpty]=rmidotnet.MSExcel.classifyContents(textFromCells);
            headersOptions=this.makeHeadersOptions(headersText,isId,isNaturalText,isColumnEmpty);


            table.Type='table';
            table.Tag='SlreqImportDlgExcelPreview';
            table.Editable=true;


            widths=ones(size(headersText));
            for i=1:length(headersText)
                widths(i)=length(headersText{i})+3;
            end
            table.ColumnCharacterWidth=widths;
            table.HeaderVisibility=[1,1];
            table.ColHeader=headersText;

            hintForMapControls=getString(message('Slvnv:slreq_import:HintForMapControls'));
            rowNumbers=split(num2str(rowRange(1):rowRange(end)));
            rowNumbers=strcat(rowNumbers,':');
            table.RowHeader=([hintForMapControls;rowNumbers])';

            table.Size=size(textFromCells)+[1,0];
            table.Data=[headersOptions;textFromCells];
            table.ReadOnlyRows=1:size(table.Data,1)-1;
            table.ValueChangedCallback=@this.optionValueChanged;
            table.ColumnStretchable=zeros(1,size(table.Data,2));
        end

        function options=makeHeadersOptions(this,headersText,isId,isNaturalText,isColumnEmpty)
            count=length(headersText);
            this.columnOptions=zeros(1,count);
            options=cell(1,count);
            supportedOptions=slreq.import.propNameMap();

            defaultOption=slreq.import.propNameMap('ATTR');
            primaryIdIdx=slreq.import.propNameMap('customId');
            summaryIdx=slreq.import.propNameMap('summary');
            descriptionIdx=slreq.import.propNameMap('description');
            rationaleIdx=slreq.import.propNameMap('rationale');
            skipIdx=slreq.import.propNameMap('SKIP');
            for i=1:count
                options{i}.Type='combobox';
                options{i}.Tag=sprintf('SlreqImportDlgExcelOption%d',i);
                options{i}.Entries=supportedOptions;
                options{i}.Values=(1:length(options{i}.Entries))-1;
                options{i}.Value=defaultOption;
                this.columnOptions(i)=defaultOption;




            end

            for i=find(isColumnEmpty)
                options{i}.Value=skipIdx;
                this.columnOptions(i)=skipIdx;
            end

            summaryCol=this.lookForSummary(headersText);
            if~isempty(summaryCol)
                options{summaryCol}.Value=summaryIdx;
                this.columnOptions(summaryCol)=summaryIdx;
            end

            if any(isId)
                suitableColumns=find(isId);
                useAsId=suitableColumns(1);
                options{useAsId}.Value=primaryIdIdx;
                this.columnOptions(useAsId)=primaryIdIdx;
            end

            descriptionColumn=0;
            for i=1:count
                if options{i}.Value~=defaultOption
                    continue;
                end
                if isNaturalText(i)
                    descriptionColumn=i;
                    options{i}.Value=descriptionIdx;
                    this.columnOptions(i)=descriptionIdx;


                    next=i+1;
                    while next<length(headersText)&&strcmp(headersText{next},headersText{i})
                        options{next}.Value=descriptionIdx;
                        this.columnOptions(next)=descriptionIdx;
                        descriptionColumn=next;
                        next=next+1;
                    end
                    break;
                end
            end

            for i=descriptionColumn+1:count
                if options{i}.Value~=defaultOption
                    continue;
                end
                if isNaturalText(i)
                    options{i}.Value=rationaleIdx;
                    this.columnOptions(i)=rationaleIdx;


                    next=i+1;
                    while next<length(headersText)&&strcmp(headersText{next},headersText{i})
                        options{next}.Value=rationaleIdx;
                        this.columnOptions(next)=rationaleIdx;
                    end
                    break;
                end
            end
        end

        function idx=lookForSummary(~,headersText)



            for i=1:length(headersText)
                thisHeader=lower(headersText{i});
                if contains(thisHeader,'summary')
                    idx=i;
                    return;
                end
            end
            idx=[];
        end

        function optionValueChanged(this,dlg,~,col,value)
            ncol=col+1;
            this.columnOptions(ncol)=value;
            dlg.refresh();
        end

        function[ok,msg]=isValidOption(this)
            ok=true;
            msg='';




            if isempty(this.docObj)
                ok=false;
                return;
            end


            primaryIdIdx=slreq.import.propNameMap('customId');
            if sum(this.columnOptions==primaryIdIdx)>1
                ok=false;
                msg=getString(message('Slvnv:slreq_import:OnlyOneColumnForID'));
                return;
            end


            descriptionIdx=slreq.import.propNameMap('description');
            descIdx=find(this.columnOptions==descriptionIdx);
            if length(descIdx)>1
                if any((descIdx(2:end)-descIdx(1:end-1))>1)
                    ok=false;
                    msg=getString(message('Slvnv:slreq_import:DescriptionBroken'));
                    return;
                end
            end


            summaryIdx=slreq.import.propNameMap('summary');
            countSummaryColumns=sum(this.columnOptions==summaryIdx);
            if countSummaryColumns>1
                ok=false;
                msg=getString(message('Slvnv:slreq_import:OnlyOneColumnCanBeSummary'));
                return;
            elseif countSummaryColumns<1&&isempty(descIdx)
                msg=getString(message('Slvnv:slreq_import:MustSelectColumnForSummary'));
                return;
            end


            rationaleIdx=slreq.import.propNameMap('rationale');
            ratIdx=find(this.columnOptions==rationaleIdx);
            if length(ratIdx)>1
                if any((ratIdx(2:end)-ratIdx(1:end-1))>1)
                    ok=false;
                    msg=getString(message('Slvnv:slreq_import:RationaleBroken'));
                    return;
                end
            end
        end

        function out=setStandaloneButtons(this,errorMessage)

            noteText.Type='text';
            noteText.Name=errorMessage;
            noteText.ForegroundColor=[255,0,0];
            noteText.RowSpan=[1,1];
            noteText.ColSpan=[1,2];

            okButton.Name=getString(message('Slvnv:slreq_import:OK'));
            okButton.Tag='SlreqImportDlgExcel_OK';
            okButton.Type='pushbutton';
            okButton.RowSpan=[1,1];
            okButton.ColSpan=[3,3];
            okButton.ObjectMethod='SlreqImportDlgExcel_OK_callback';


            okButton.Enabled=isempty(errorMessage)&&this.isValidOption();

            cancelButton.Name=getString(message('Slvnv:slreq_import:Cancel'));
            cancelButton.Tag='SlreqImportDlgExcel_Cancel';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[4,4];
            cancelButton.ObjectMethod='SlreqImportDlgExcel_Cancel_callback';

            out.Tag='SlreqImportDlg_standalonebuttons';
            out.LayoutGrid=[1,4];
            out.Name='';
            out.Type='panel';
            out.Items={noteText,okButton,cancelButton};

        end

    end



    methods(Access=public,Hidden=true)

        function SlreqImportDlgExcel_Cancel_callback(this)
            this.caller.getSource.setExcelOptionsFromChildDialog(this,false);
            slreq.import.ui.attrDlg_mgr('clear');
        end

        function SlreqImportDlgExcel_OK_callback(this)
            this.caller.getSource.setExcelOptionsFromChildDialog(this,true);
            slreq.import.ui.attrDlg_mgr('clear');
        end

        function SlreqImportDlg_editTo_callback(this,dlg)
            value=dlg.getWidgetValue('SlreqImportDlg_editTo');
            givenRow=str2num(value);%#ok<ST2NM>
            if givenRow<=this.lastRow
                this.toRow=givenRow;
            else
                beep;
                dlg.setWidgetValue('SlreqImportDlg_editTo',num2str(this.lastRow));
            end
        end

        function SlreqImportDlg_editFrom_callback(this,dlg)
            value=dlg.getWidgetValue('SlreqImportDlg_editFrom');
            givenRow=str2num(value);%#ok<ST2NM>
            if givenRow<=this.headersRow
                beep;
                dlg.setWidgetValue('SlreqImportDlg_editFrom',num2str(this.headersRow+1));
            else
                this.fromRow=givenRow;
            end
        end

        function row=promptForHeadersRow(this)
            msgTitle=getString(message('Slvnv:slreq_import:NoHeaders'));
            msgText=getString(message('Slvnv:slreq_import:NoHeadersManualInput'));
            response=inputdlg(msgText,msgTitle);
            if isempty(response)||isempty(response{1})
                row=-1;
            else
                row=str2num(response{1});%#ok<ST2NM>
                if isempty(row)
                    row=this.promptForHeadersRow();
                end
            end
        end

        function headersText=verifyGivenHeadersRow(this)
            rowRange=[this.headersRow,this.headersRow];
            colRange=[this.allColumns(1),this.allColumns(end)];
            headersText=rmidotnet.MSExcel.getTextFromRange(this.srcDoc,rowRange,colRange);
            this.columnIndex=this.allColumns;
            [~,~,isCellEmpty]=rmidotnet.MSExcel.classifyContents(headersText);



            if any(isCellEmpty)
                slreq.import.deduplicate();
                previous='';
                skip=false(size(headersText));
                for i=1:length(headersText)
                    if isempty(headersText{i})
                        if isempty(previous)
                            skip(i)=true;
                        else
                            headersText{i}=slreq.import.deduplicate(previous);
                        end
                    else
                        checked=slreq.import.deduplicate(headersText{i});
                        if strcmp(checked,headersText{i})
                            previous=headersText{i};
                        else
                            headersText{i}=checked;
                        end
                    end
                end
                if any(skip)
                    headersText(skip)=[];
                    this.columnIndex(skip)=[];
                end
            end
        end

        function SlreqImportDlg_xlsHeaderSelect_callback(this,dlg)
            givenRow=this.promptForHeadersRow();
            if givenRow<0
                return;
            else
                this.headersRow=givenRow;
            end
            this.table=[];
            dlg.refresh();
            reqmgt('winFocus',getString(message('Slvnv:slreq_import:SelectRangeToImport')));
        end

        function XlsMappingDiglogTestOnly_forceRow(this,dlg,row)

            this.headersRow=row;
            this.table=[];
            dlg.refresh();
            reqmgt('winFocus',getString(message('Slvnv:slreq_import:SelectRangeToImport')));
        end
    end


end

