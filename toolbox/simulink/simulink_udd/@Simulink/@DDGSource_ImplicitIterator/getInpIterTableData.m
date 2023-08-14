function[tblColHead,tblData]=getInpIterTableData(this)





    block=this.getBlock;
    inputOverlappingFeatureOn=(slfeature('ForEachSubsystemInputOverlapping')==1);

    numInports=length(this.DialogData.InportBlockNamesArray);

    inpnameId=this.getColId('blkname');
    inpiterId=this.getColId('inpiter');
    inpiterdimId=this.getColId('inpiterdim');
    inpiterstepsizeId=this.getColId('inpiterstepsize');
    inpiterstepoffsetId=this.getColId('inpiterstepoffset');

    tblColHead{inpnameId}=DAStudio.message('Simulink:dialog:ForEachPortColHead');
    tblColHead{inpiterId}=block.IntrinsicDialogParameters.InputPartition.Prompt;
    tblColHead{inpiterdimId}=block.IntrinsicDialogParameters.InputPartitionDimension.Prompt;
    tblColHead{inpiterstepsizeId}=block.IntrinsicDialogParameters.InputPartitionWidth.Prompt;
    if inputOverlappingFeatureOn
        tblColHead{inpiterstepoffsetId}=block.IntrinsicDialogParameters.InputPartitionOffset.Prompt;
    end

    numTblDataEntries=length(find(this.DialogData.InportBlockPtrsArray>0));
    needMap=numTblDataEntries<numInports;

    if needMap
        this.DialogData.InpIterTblMap=cell(numTblDataEntries,1);
    else

        this.DialogData.InpIterTblMap={};
    end


    tblData=cell(numTblDataEntries,length(tblColHead));

    numData=0;
    for i=1:numInports
        nonExistInp=(this.DialogData.InportBlockPtrsArray(i)<0);

        if nonExistInp
            continue;
        end

        numData=numData+1;

        if~isempty(this.DialogData.InpIterTblMap)
            this.DialogData.InpIterTblMap{numData}=i;
        end



        col_inpname.Type='edit';
        col_inpname.Alignment=6;
        if numData<10
            prtnumStr=sprintf([num2str(i),'    ']);
        elseif numData<100
            prtnumStr=[num2str(i),'   '];
        else
            prtnumStr=[num2str(i),'  '];
        end
        col_inpname.Value=[prtnumStr,this.DialogData.InportBlockNamesArray{i}];
        col_inpname.Enabled=false;
        tblData{numData,inpnameId}=col_inpname;



        inpIterVal=isequal(this.DialogData.InputPartition{i},'on');
        col_inpiter.Type='checkbox';
        col_inpiter.Value=inpIterVal;
        col_inpiter.Enabled=true;
        tblData{numData,inpiterId}=col_inpiter;


        needDimPrm=inpIterVal;


        col_inpiterdim.Type='edit';
        col_inpiterdim.Alignment=6;
        if needDimPrm
            col_inpiterdim.Value=this.DialogData.InputPartitionDimension{i};
            col_inpiterdim.Enabled=true;
        else
            col_inpiterdim.Value=this.getStrForNotIter;
            col_inpiterdim.Enabled=false;
        end
        tblData{numData,inpiterdimId}=col_inpiterdim;



        col_inpiterstepsize.Type='edit';
        col_inpiterstepsize.Alignment=6;
        if needDimPrm
            col_inpiterstepsize.Value=this.DialogData.InputPartitionWidth{i};
            col_inpiterstepsize.Enabled=true;
        else
            col_inpiterstepsize.Value=this.getStrForNotIter;
            col_inpiterstepsize.Enabled=false;
        end
        tblData{numData,inpiterstepsizeId}=col_inpiterstepsize;



        if inputOverlappingFeatureOn
            col_inpiterstepoffset.Type='edit';
            col_inpiterstepoffset.Alignment=6;
            if needDimPrm
                col_inpiterstepoffset.Value=this.DialogData.InputPartitionOffset{i};
                col_inpiterstepoffset.Enabled=true;
            else
                col_inpiterstepoffset.Value=this.getStrForNotIter;
                col_inpiterstepoffset.Enabled=false;
            end
            tblData{numData,inpiterstepoffsetId}=col_inpiterstepoffset;
        end
    end
end
