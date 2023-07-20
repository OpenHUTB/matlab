function ptrCastStr=generatePtrCastForMultiDimArg(kind,arg1,arg2)






    ptrCastStr='';

    switch kind
    case 1
        infoStruct=arg1;
        thisData=arg2;
        thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);

        if(thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1)

            dtName=thisDataType.Name;
        else

            thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
            dtName=thisDataType.Name;
        end

        ptrCastStr=iGenCastStr(dtName,thisData.Dimensions);

    case 2
        ptrCastStr=iGenCastStr(arg1,arg2);

    otherwise

    end


    function ptrCastStr=iGenCastStr(dtName,dataDims)













        numDims=numel(dataDims);
        strSet=cell(1,numDims);
        allIsStar=dataDims(end)==-1;
        for ii=1:numDims
            if allIsStar
                strSet{ii}='*';
            elseif dataDims(ii)==-1||ii==1
                strSet{ii}='(*)';
            else
                strSet{ii}=sprintf('[%d]',dataDims(ii));
            end
        end
        ptrCastStr=sprintf('(%s ',dtName);
        for ii=1:numDims
            ptrCastStr=sprintf('%s%s',ptrCastStr,strSet{ii});
        end
        ptrCastStr=sprintf('%s)',ptrCastStr);



