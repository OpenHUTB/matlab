function protoStr=generateSfcnFcnCallString(h,infoStruct,fcnInfo)%#ok<INUSL>






    token=regexpi(fcnInfo.RhsExpression,'(\w*)\s*\(','tokens');
    protoStr=token{1}{1};

    if fcnInfo.LhsArgs.NumArgs==1
        thisArg=fcnInfo.LhsArgs.Arg(1);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        thisName=thisArg.Identifier;

        thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
        if thisData.CMatrix2D.DWorkId>0
            thisName=['__',thisName,'M2D'];
        elseif thisDataType.IsBus||thisDataType.IsStruct
            thisName=['__',thisName,'BUS'];
        end

        prefix='';
        if strcmp(thisArg.AccessType,'direct')
            prefix='*';
        end

        protoStr=sprintf('%s%s = %s',prefix,thisName,protoStr);
    end

    protoStr=sprintf('%s(',protoStr);

    sep=' ';
    for ii=1:fcnInfo.RhsArgs.NumArgs

        thisArg=fcnInfo.RhsArgs.Arg(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        thisName=thisArg.Identifier;

        thisData=[];
        if~strcmp(thisArg.Type,'SizeArg')
            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
        end


        ptrCastStr='';
        if strcmp(thisArg.AccessType,'pointer')&&~isempty(thisData)
            if numel(thisData.Dimensions)>1&&false
                ptrCastStr=legacycode.LCT.generatePtrCastForMultiDimArg(1,infoStruct,thisData);
            end
        end

        prefix='';
        if~isempty(thisData)&&thisData.CMatrix2D.DWorkId>0

            thisName=['__',thisName,'M2D'];%#ok<AGROW>
            if strcmp(thisArg.AccessType,'direct')
                prefix='*';
            end

        elseif thisDataType.IsBus==0&&thisDataType.IsStruct==0
            if strcmp(thisArg.AccessType,'direct')&&~strcmp(thisArg.Type,'SizeArg')
                prefix='*';
            end


            if(strcmp(thisArg.Type,'DWork')==true)&&strcmp(thisDataType.DTName,'void')
                thisDWork=infoStruct.DWorks.DWork(thisArg.DataId);
                if~isempty(thisDWork.pwIdx)&&(strcmp(thisArg.AccessType,'pointer')==true)

                    prefix='&';
                else

                    prefix='';
                end
            end
        else

            thisName=['__',thisName,'BUS'];%#ok

            if strcmp(thisArg.AccessType,'direct')
                prefix='*';
            end
        end

        protoStr=sprintf('%s%s%s%s%s',protoStr,sep,prefix,ptrCastStr,thisName);
        sep=', ';
    end

    protoStr=sprintf('%s)',protoStr);


