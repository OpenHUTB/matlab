function protoStr=generateTlcFcnWrapperCallString(h,infoStruct,fcnInfo,fcnType)%#ok<INUSL>







    protoStr=sprintf('%s_wrapper_%s(',infoStruct.Specs.SFunctionName,fcnType);

    if fcnInfo.LhsArgs.NumArgs==1
        thisArg=fcnInfo.LhsArgs.Arg(1);
        thisName=thisArg.Identifier;


        protoStr=sprintf('%s %%<%s_ptr>',protoStr,thisName);


        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)
            protoStr=sprintf('%s, %%<%sBUS_ptr>',protoStr,thisName);
        end


        thisData=infoStruct.([thisArg.Type,'s']).(thisArg.Type)(thisArg.DataId);
        if thisData.CMatrix2D.DWorkId>0
            protoStr=sprintf('%s, %%<%sM2D_ptr>',protoStr,thisName);
        end

        if fcnInfo.RhsArgs.NumArgs
            protoStr=sprintf('%s,',protoStr);
        end

    end

    sep=' ';
    for ii=1:fcnInfo.RhsArgs.NumArgs

        thisArg=fcnInfo.RhsArgs.Arg(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        thisName=thisArg.Identifier;

        suffix='_val';



        hasObject=~isempty(thisDataType.HeaderFile);
        if hasObject||strcmp(thisArg.AccessType,'pointer')
            suffix='_ptr';
        end



        castStr='';
        if~hasObject&&strcmp(thisArg.Type,'SizeArg')


            dtName=thisDataType.Name;
            if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))==0

                rootDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                dtName=rootDataType.Name;
            end
            castStr=sprintf('(%s)',dtName);
        end

        isParameterSpecialCase=hasObject&&strcmp(thisArg.Type,'Parameter')&&strcmp(thisArg.AccessType,'direct');
        isSizeArgSpecialCase=hasObject&&strcmp(thisArg.Type,'SizeArg');
        if isParameterSpecialCase



            protoStr=sprintf('%s%s(void *)&p%d_val',protoStr,sep,thisArg.DataId);
        elseif isSizeArgSpecialCase

            protoStr=sprintf('%s%s(void *)&%s_val',protoStr,sep,thisArg.Identifier);
        else
            protoStr=sprintf('%s%s%s%%<%s%s>',protoStr,sep,castStr,thisName,suffix);
        end
        sep=', ';


        if(thisDataType.IsBus==1||thisDataType.IsStruct==1)
            protoStr=sprintf('%s%s%%<%sBUS_ptr>',protoStr,sep,thisArg.Identifier);
        end


        if~strcmp(thisArg.Type,'SizeArg')
            thisData=infoStruct.([thisArg.Type,'s']).(thisArg.Type)(thisArg.DataId);
            if thisData.CMatrix2D.DWorkId>0
                protoStr=sprintf('%s, %%<%sM2D_ptr>',protoStr,thisName);
            end
        end
    end

    protoStr=sprintf('%s)',protoStr);



