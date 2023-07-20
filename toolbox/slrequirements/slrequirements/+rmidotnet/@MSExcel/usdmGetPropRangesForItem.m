

function[summaryRange,descriptionRange,rationaleRange]=usdmGetPropRangesForItem(this,itemIdAddress,lastRow,lastCol)






























    idRow=itemIdAddress(1);
    idCol=itemIdAddress(2);


    summaryRange=[idCol+1,lastCol];



    rationaleRow=idRow+1;
    if rationaleRow>lastRow||isSectionLabelOrEmpty(this,rationaleRow,idCol)
        rationaleRange=[];

        descriptionRange=summaryRange;
        return;
    end


    rationaleRange.address=[rationaleRow,idCol+1];
    rationaleRange.range=[1,lastCol-idCol];


    descriptionRow=rationaleRow+1;
    if descriptionRow>lastRow||isSectionLabelOrEmpty(this,descriptionRow,idCol)
        descriptionRange=summaryRange;
    else

        descriptionRange.address=[descriptionRow,idCol+1];
        descriptionRange.range=[1,lastCol-idCol];
    end
end

function tf=isSectionLabelOrEmpty(this,row,col)
    text=strtrim(this.getTextFromCell(row,col));
    tf=isempty(text)||text(1)=='<';
end

