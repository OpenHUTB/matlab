function tblData=getDimsPropTableData(this)





    block=this.getBlock;

    numDims=this.getNumDims;

    lstIdxOptsForCompare=block.getPropAllowedValues('IdxOptString');
    lstIdxOptsForDisplay=block.getPropAllowedValues('IdxOptString',true);

    tblData=cell(numDims,3);

    idxoptId=this.getColId('idxopt');
    idxId=this.getColId('idx');
    outsizeId=this.getColId('outsize');

    for i=1:numDims

        col_idxopt.Type='combobox';
        col_idxopt.Entries=lstIdxOptsForDisplay;
        col_idxopt.Value=this.getEnumValFromStr(this.DialogData.IndexOptionArray{i},lstIdxOptsForCompare);
        tblData{i,idxoptId}=col_idxopt;


        col_idxparam.Type='edit';
        col_idxparam.Alignment=6;
        if this.isDialogOpt(col_idxopt.Value)
            col_idxparam.Value=this.DialogData.IndexParamArray{i};
            col_idxparam.Enabled=true;
        else
            if this.isAllOpt(col_idxopt.Value)
                col_idxparam.Value=this.getIndexStrForAllOpt;
            else
                col_idxparam.Value=this.getIndexStrForPortOpt(i);
            end
            col_idxparam.Enabled=false;
        end
        tblData{i,idxId}=col_idxparam;


        col_outsize.Type='edit';
        col_outsize.Alignment=6;
        col_outsize.Value=this.DialogData.OutputSizeArray{i};
        col_outsize.Enabled=true;
        tblData{i,outsizeId}=col_outsize;
    end

end
