function setExcelOptionsFromChildDialog(this,childDlgSrc,commit)




    childDlgSrc.caller.setEnabled('SlreqImportDlg_attributeSelector',true);

    if commit









        this.columns=childDlgSrc.columnIndex;
        this.rows=[childDlgSrc.fromRow,childDlgSrc.toRow];
        this.columnHeaders=rmidotnet.MSExcel.getTextFromRange(this.srcDoc,childDlgSrc.headersRow,this.columns);
        if isempty(this.columnHeaders)

            return;
        end

        if any(strcmp(this.columnHeaders,''))
            previous='EMPTY';
            slreq.import.deduplicate();
            for i=1:length(this.columnHeaders)
                if isempty(this.columnHeaders{i})
                    this.columnHeaders{i}=slreq.import.deduplicate(previous);
                else
                    checked=slreq.import.deduplicate(this.columnHeaders{i});
                    if strcmp(checked,this.columnHeaders{i})
                        previous=checked;
                    else
                        this.columnHeaders{i}=checked;
                    end
                end
            end
        end

        columnIndex=childDlgSrc.columnIndex;
        columnOptions=childDlgSrc.columnOptions;


        fullColumnHeaders=this.columnHeaders;
        fullColumnIndex=columnIndex;
        fullColumnOptions=columnOptions;


        this.idColumn=columnIndex(columnOptions==slreq.import.propNameMap('customId'));
        this.summaryColumn=columnIndex(columnOptions==slreq.import.propNameMap('summary'));
        this.descriptionColumn=columnIndex(columnOptions==slreq.import.propNameMap('description'));
        this.rationaleColumn=columnIndex(columnOptions==slreq.import.propNameMap('rationale'));
        this.keywordsColumn=columnIndex(columnOptions==slreq.import.propNameMap('keywords'));
        this.createdByColumn=columnIndex(columnOptions==slreq.import.propNameMap('createdBy'));
        this.modifiedByColumn=columnIndex(columnOptions==slreq.import.propNameMap('modifiedBy'));
        this.attributeColumn=columnIndex(columnOptions==slreq.import.propNameMap('ATTR'));



        if~isempty(this.attributeColumn)
            usedHeaderIdx=find(columnOptions==slreq.import.propNameMap('ATTR'));
            for i=usedHeaderIdx
                while slreq.custom.AttributeHandler.isReservedName(this.columnHeaders{i})
                    title=getString(message('Slvnv:slreq_import:ReservedNameError'));
                    msg=[...
                    getString(message('Slvnv:slreq_import:ReservedNameCannotBeUsed',this.columnHeaders{i}))...
                    ,'  ',getString(message('Slvnv:slreq_import:ReservedNamePleaseModify'))];
                    defaultAnswer={['user_',this.columnHeaders{i}]};
                    beep;
                    response=inputdlg(msg,title,1,defaultAnswer);
                    if isempty(response)||isempty(response{1})






                        return;



                    else
                        this.columnHeaders{i}=response{1};
                    end
                end
            end
        end


        dlg=slreq.import.ui.dlg_mgr('get');
        this.refreshDlg(dlg);

        this.populateExcelMapping(fullColumnIndex,fullColumnOptions,fullColumnHeaders,this.columnHeaders);


        skip=slreq.import.propNameMap('SKIP');
        if any(columnOptions==skip)
            columnIndex(columnOptions==skip)=[];
            this.columns=columnIndex;
            this.columnHeaders(columnOptions==skip)=[];
        end

    end
end
