function[tblColHead,tblData]=getMaskPrmIterTableData(this)





    block=this.getBlock;

    numSubsysMaskParameters=length(this.DialogData.SubsysMaskParameterNamesArray);

    paramnameId=this.getColId('blkname');
    paramiterId=this.getColId('inpiter');
    paramiterdimId=this.getColId('inpiterdim');
    paramiterstepsizeId=this.getColId('inpiterstepsize');

    tblColHead{paramnameId}=DAStudio.message('Simulink:dialog:ForEachPrmColHead');
    tblColHead{paramiterId}=block.IntrinsicDialogParameters.SubsysMaskParameterPartition.Prompt;
    tblColHead{paramiterdimId}=block.IntrinsicDialogParameters.SubsysMaskParameterPartitionDimension.Prompt;
    tblColHead{paramiterstepsizeId}=block.IntrinsicDialogParameters.SubsysMaskParameterPartitionWidth.Prompt;

    if evalin('base','exist(''ForEachHideNonPartitionableParams'')')~=0
        numTblDataEntries=length(find(...
        double(this.DialogData.SubsysMaskParameterIsPartitionableArray)>0));
        this.DialogData.MaskParamTblMap=cell(numTblDataEntries,1);
    else
        numTblDataEntries=numSubsysMaskParameters;
    end
    tblData=cell(numTblDataEntries,length(tblColHead));


    numData=0;
    for i=1:numSubsysMaskParameters
        if evalin('base','exist(''ForEachHideNonPartitionableParams'')')~=0
            if~(this.DialogData.SubsysMaskParameterIsPartitionableArray{i})

                continue;
            end
            this.DialogData.MaskParamTblMap{numData+1}=i;
        end


        numData=numData+1;


        col_paramname.Type='edit';
        col_paramname.Alignment=6;
        if numData<10
            prtnumStr=sprintf([num2str(i),'    ']);
        elseif numData<100
            prtnumStr=[num2str(i),'   '];
        else
            prtnumStr=[num2str(i),'  '];
        end
        col_paramname.Value=[prtnumStr,this.DialogData.SubsysMaskParameterNamesArray{i}];
        col_paramname.Enabled=false;
        tblData{numData,paramnameId}=col_paramname;

        if(this.DialogData.SubsysMaskParameterIsPartitionableArray{i})
            paramIterVal=isequal(this.DialogData.SubsysMaskParameterPartition{i},'on');

            col_paramiter.Type='checkbox';
            col_paramiter.Value=paramIterVal;
            col_paramiter.Enabled=true;
            tblData{numData,paramiterId}=col_paramiter;
        else
            paramIterVal=false;

            col_paramiter.Type='edit';
            col_paramiter.Value=this.getStrForNotIter;
            col_paramiter.Enabled=false;
            tblData{numData,paramiterId}=col_paramiter;
        end

        needDimPrm=paramIterVal;


        col_paramiterdim.Type='edit';
        col_paramiterdim.Alignment=6;
        if needDimPrm
            col_paramiterdim.Value=this.DialogData.SubsysMaskParameterPartitionDimension{i};
            col_paramiterdim.Enabled=true;
        else
            col_paramiterdim.Value=this.getStrForNotIter;
            col_paramiterdim.Enabled=false;
        end
        tblData{numData,paramiterdimId}=col_paramiterdim;


        col_paramiterstepsize.Type='edit';
        col_paramiterstepsize.Alignment=6;
        if needDimPrm
            col_paramiterstepsize.Value=this.DialogData.SubsysMaskParameterPartitionWidth{i};
            col_paramiterstepsize.Enabled=true;
        else
            col_paramiterstepsize.Value=this.getStrForNotIter;
            col_paramiterstepsize.Enabled=false;
        end
        tblData{numData,paramiterstepsizeId}=col_paramiterstepsize;
    end
end
