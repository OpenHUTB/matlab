function[tblColHead,tblData]=getOutConcatTableData(this)





    block=this.getBlock;

    numOutports=length(this.DialogData.OutportBlockNamesArray);

    outnameId=this.getColId('blkname');
    outconcatdimId=this.getColId('outconcatdim');

    tblColHead{outnameId}=DAStudio.message('Simulink:dialog:ForEachPortColHead');
    tblColHead{outconcatdimId}=block.IntrinsicDialogParameters.OutputConcatenationDimension.Prompt;

    numTblDataEntries=length(find(this.DialogData.OutportBlockPtrsArray>0));
    needMap=numTblDataEntries<numOutports;

    if needMap
        this.DialogData.OutConcatTblMap=cell(numTblDataEntries,1);
    else

        this.DialogData.OutConcatTblMap={};
    end


    tblData=cell(numTblDataEntries,length(tblColHead));

    numData=0;
    for i=1:numOutports
        nonExistOut=(this.DialogData.OutportBlockPtrsArray(i)<0);

        if nonExistOut
            continue;
        end

        numData=numData+1;

        if~isempty(this.DialogData.OutConcatTblMap)
            this.DialogData.OutConcatTblMap{numData}=i;
        end



        col_outname.Type='edit';
        col_outname.Alignment=6;
        if numData<10
            prtnumStr=sprintf([num2str(i),'    ']);
        elseif numData<100
            prtnumStr=[num2str(i),'   '];
        else
            prtnumStr=[num2str(i),'  '];
        end
        col_outname.Value=[prtnumStr,this.DialogData.OutportBlockNamesArray{i}];
        col_outname.Enabled=false;
        tblData{numData,outnameId}=col_outname;



        col_outconcatdim.Type='edit';
        col_outconcatdim.Alignment=6;
        col_outconcatdim.Value=this.DialogData.OutputConcatenationDimension{i};
        col_outconcatdim.Enabled=true;
        tblData{numData,outconcatdimId}=col_outconcatdim;
    end

end
