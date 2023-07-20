function protoStr=generateTlcFcnCallInWrapperString(h,infoStruct,fcnInfo)%#ok<INUSL>





    token=regexpi(fcnInfo.RhsExpression,'(\w*)\s*\(','tokens');
    protoStr=[token{1}{1},'('];

    if fcnInfo.LhsArgs.NumArgs==1
        thisArg=fcnInfo.LhsArgs.Arg(1);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        thisData=infoStruct.([thisArg.Type,'s']).(thisArg.Type)(thisArg.DataId);

        if thisData.CMatrix2D.DWorkId>0

            argProto=sprintf('*(%s *) __%sM2D = ',thisDataType.Name,thisArg.Identifier);

        elseif thisDataType.IsBus||thisDataType.IsStruct


            argProto=sprintf('*(%s *) __%sBUS = ',thisDataType.Name,thisArg.Identifier);
        else


            argProto=sprintf('*(%s *) %s = ',thisDataType.Name,thisArg.Identifier);
        end
        protoStr=sprintf('%s%s',argProto,protoStr);
    end

    sep=' ';
    for ii=1:fcnInfo.RhsArgs.NumArgs

        thisArg=fcnInfo.RhsArgs.Arg(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        thisName=thisArg.Identifier;

        is2DRowMatrix=false;
        if~strcmp(thisArg.Type,'SizeArg')
            thisData=infoStruct.([thisArg.Type,'s']).(thisArg.Type)(thisArg.DataId);
            is2DRowMatrix=(thisData.CMatrix2D.DWorkId>0);
        end

        prefix='';
        if is2DRowMatrix
            if strcmp(thisArg.AccessType,'direct')
                prefix='*';
            end

            thisName=sprintf('(%s *) __%sM2D',thisDataType.Name,thisName);

        elseif thisDataType.IsBus||thisDataType.IsStruct


            if strcmp(thisArg.AccessType,'direct')
                prefix='*';
            end

            thisName=sprintf('(%s *) __%sBUS',thisDataType.Name,thisName);
        else

            if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))||...
                thisDataType.IsEnum


                if strcmp(thisArg.AccessType,'direct')
                    prefix='*';
                end

                thisName=sprintf('(%s *) %s',thisDataType.Name,thisName);
            else


                if~strcmp(thisArg.Type,'Output')&&~strcmp(thisArg.Type,'DWork')
                    optStar='';
                    if strcmp(thisArg.AccessType,'pointer')
                        optStar='*';
                    end


                    dtName=thisDataType.Name;
                    if(thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo==-1)

                        rootDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                        dtName=rootDataType.Name;
                    end
                    thisName=sprintf('(%s%s)(%s)',dtName,optStar,thisName);
                end
            end
        end


        ptrCastStr='';
        if strcmp(thisArg.AccessType,'pointer')
            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            if numel(thisData.Dimensions)>1&&false
                ptrCastStr=legacycode.LCT.generatePtrCastForMultiDimArg(1,infoStruct,thisData);
            end
        end

        protoStr=sprintf('%s%s%s%s%s',protoStr,sep,ptrCastStr,prefix,thisName);
        sep=', ';
    end

    protoStr=sprintf('%s)',protoStr);


