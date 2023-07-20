function protoStr=generateTlcFcnWrapperProtoString(h,infoStruct,fcnInfo,fcnType)%#ok<INUSL>







    protoStr=sprintf('%s_wrapper_%s(',infoStruct.Specs.SFunctionName,fcnType);

    if fcnInfo.LhsArgs.NumArgs==1
        thisArg=fcnInfo.LhsArgs.Arg(1);
        thisData=infoStruct.([thisArg.Type,'s']).(thisArg.Type)(thisArg.DataId);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        thisName=thisArg.Identifier;


        prefix='*';
        dtName='';%#ok<NASGU>
        if~isempty(thisDataType.HeaderFile)

            dtName='void';

        else
            if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                dtName=thisDataType.Name;
            else

                thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                dtName=thisDataType.Name;
            end

            if thisData.IsComplex==1

                dtName=sprintf('c%s',thisDataType.Name);
            end
        end

        protoStr=sprintf('%s %s %s%s',protoStr,dtName,prefix,thisName);


        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)
            protoStr=sprintf('%s, void *__%sBUS',protoStr,thisName);
        end


        if thisData.CMatrix2D.DWorkId>0
            protoStr=sprintf('%s, %s *__%sM2D',protoStr,dtName,thisName);
        end

        if fcnInfo.RhsArgs.NumArgs
            protoStr=sprintf('%s,',protoStr);
        end
    end

    sep=' ';
    for ii=1:fcnInfo.RhsArgs.NumArgs

        thisArg=fcnInfo.RhsArgs.Arg(ii);
        isSizeArg=strcmp(thisArg.Type,'SizeArg');
        if~isSizeArg
            thisData=infoStruct.([thisArg.Type,'s']).(thisArg.Type)(thisArg.DataId);
        end
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        thisName=thisArg.Identifier;

        prefix='';
        dtName='';%#ok<NASGU>
        if~isempty(thisDataType.HeaderFile)

            dtName='void';
            prefix='*';

        else
            if strcmp(thisArg.AccessType,'pointer')
                prefix='*';
            end

            if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                dtName=thisDataType.Name;
            else

                thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                dtName=thisDataType.Name;
            end

            if~isSizeArg&&thisData.IsComplex==1

                dtName=sprintf('c%s',dtName);
            end
        end


        if~strcmp(thisArg.Type,'Output')&&~strcmp(thisArg.Type,'DWork')
            qualifier='const';
        else
            qualifier='';
        end


        if strcmp(thisArg.Type,'DWork')&&strcmp(thisDataType.Name,'void')
            qualifier='';
            if strcmp(thisArg.AccessType,'pointer')
                prefix='**';
            else
                prefix='*';
            end
        end

        protoStr=sprintf('%s%s%s %s %s%s',protoStr,sep,qualifier,dtName,prefix,thisName);

        sep=', ';


        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)
            protoStr=sprintf('%s%svoid *__%sBUS',protoStr,sep,thisName);
        end


        if~isSizeArg&&thisData.CMatrix2D.DWorkId>0
            protoStr=sprintf('%s, %s *__%sM2D',protoStr,dtName,thisName);
        end
    end

    voidStr='';

    if fcnInfo.LhsArgs.NumArgs==0&&fcnInfo.RhsArgs.NumArgs==0
        voidStr='void';
    end
    protoStr=sprintf('void %s%s)',protoStr,voidStr);


