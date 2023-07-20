function protoStr=generateTlcFcnCallString(h,infoStruct,fcnInfo,skipLhs)%#ok<INUSL>







    if nargin<3
        skipLhs=0;
    end


    token=regexpi(fcnInfo.RhsExpression,'(\w*)\s*\(','tokens');
    protoStr=token{1}{1};

    if(fcnInfo.LhsArgs.NumArgs==1)&&(skipLhs==0)
        thisArg=fcnInfo.LhsArgs.Arg(1);
        thisName=thisArg.Identifier;

        thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
        if thisData.CMatrix2D.DWorkId>0
            optStar='';
            if strcmp(thisArg.AccessType,'direct')
                optStar='*';
            end
            protoStr=sprintf('%s__%sM2D = %s',optStar,thisName,protoStr);
        else
            suffix='_ptr';
            if strcmp(thisArg.AccessType,'direct')
                suffix='_val';
            end

            protoStr=sprintf('%%<%s%s> = %s',thisName,suffix,protoStr);
        end

    end

    protoStr=sprintf('%s(',protoStr);

    sep=' ';
    for ii=1:fcnInfo.RhsArgs.NumArgs

        thisArg=fcnInfo.RhsArgs.Arg(ii);
        thisName=thisArg.Identifier;


        thisData=[];
        is2DRowMatrix=false;
        if~strcmp(thisArg.Type,'SizeArg')
            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            isDatacomplex=thisData.IsComplex;
            is2DRowMatrix=(thisData.CMatrix2D.DWorkId>0);
        else

            isDatacomplex=false;
        end
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

        suffix='_ptr';
        isPointerAccess=true;
        if strcmp(thisArg.AccessType,'direct')
            suffix='_val';
            isPointerAccess=false;
        end


        needPtrCast=isPointerAccess&&~isempty(thisData)&&...
        isfield(thisData,'Dimensions')&&(numel(thisData.Dimensions)>1);


        needConstCast=~strcmp(thisArg.Type,'Output')&&~strcmp(thisArg.Type,'DWork');


        dtName='';
        if needPtrCast||needConstCast
            if(thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1)

                dtName=thisDataType.Name;
            else


                dataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                dtName=dataType.Name;
            end
        end


        ptrCastStr='';
        if needPtrCast&&false
            ptrCastStr=legacycode.LCT.generatePtrCastForMultiDimArg(2,dtName,thisData.Dimensions);
        end






        constCastStr='';
        if needConstCast
            optStar='';
            if isPointerAccess
                optStar='*';
            end
            if isDatacomplex==1


                dtName=sprintf('c%s',dtName);
            end
            constCastStr=sprintf('(%s%s)',dtName,optStar);
        end

        if~is2DRowMatrix
            protoStr=sprintf('%s%s%s%s%%<%s%s>',protoStr,sep,ptrCastStr,constCastStr,thisName,suffix);
        else


            optStar='';
            if~isPointerAccess
                optStar='*';
            end
            protoStr=sprintf('%s%s%s%s__%sM2D',protoStr,sep,optStar,ptrCastStr,thisName);
        end

        sep=', ';
    end

    protoStr=sprintf('%s)',protoStr);


