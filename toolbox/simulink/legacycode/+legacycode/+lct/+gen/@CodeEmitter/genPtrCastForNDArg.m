






function ptrCastStr=genPtrCastForNDArg(kind,arg1,arg2)

    ptrCastStr='';

    switch kind
    case 1
        lctSpecInfo=arg1;
        thisData=arg2;


        thisDataType=lctSpecInfo.DataTypes.getTypeForDeclaration(thisData.DataTypeId);
        dtName=thisDataType.Name;
        ptrCastStr=genCastStr(dtName,thisData.Dimensions);

    case 2
        ptrCastStr=genCastStr(arg1,arg2);

    otherwise

    end

    function ptrCastStr=genCastStr(dtName,dataDims)












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
    end
end


