function writeTlc2DMatrixConversion(h,fid,infoStruct,fcnInfo,col2Row)%#ok<INUSL>





    if col2Row

        for ii=1:fcnInfo.RhsArgs.NumArgs
            thisArg=fcnInfo.RhsArgs.Arg(ii);
            if strcmp(thisArg.Type,'SizeArg')
                continue
            end

            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            if thisData.CMatrix2D.DWorkId>0&&ismember(thisArg.Type,{'Input','Parameter'})
                nMarshallArgument(thisData,thisArg.DataId-1,thisArg.Type);
            end
        end
    else

        if fcnInfo.LhsArgs.NumArgs==1
            thisArg=fcnInfo.LhsArgs.Arg(1);
            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);

            if strcmpi(thisArg.Type,'Output')&&thisData.CMatrix2D.DWorkId>0
                nMarshallArgument(thisData,thisArg.DataId,thisArg.Type);
            end
        end

        for ii=1:fcnInfo.RhsArgs.NumArgs
            thisArg=fcnInfo.RhsArgs.Arg(ii);
            if strcmp(thisArg.Type,'SizeArg')
                continue
            end

            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            if strcmpi(thisArg.Type,'Output')&&thisData.CMatrix2D.DWorkId>0
                nMarshallArgument(thisData,thisArg.DataId-1,thisArg.Type);
            end
        end

    end

    function nMarshallArgument(thisData,dataId,dataKind)

        switch dataKind
        case 'Input'
            widthStr=sprintf('LibBlockInputSignalWidth(%d)',dataId);
            dimStr=sprintf('LibBlockInputSignalDimensions(%d)',dataId);
            dTypeIdStr=sprintf('LibBlockInputSignalDataTypeId(%d)',dataId);

        case 'Parameter'
            widthStr=sprintf('LibBlockParameterWidth(p%d))',dataId+1);
            dimStr=sprintf('LibBlockParameterDimensions(p%d))',dataId+1);
            dTypeIdStr=sprintf('LibBlockParameterDataTypeId(p%d)',dataId+1);

        case 'Output'
            widthStr=sprintf('LibBlockOutputSignalWidth(%d)',dataId);
            dimStr=sprintf('LibBlockOutputSignalDimensions(%d)',dataId);
            dTypeIdStr=sprintf('LibBlockOutputSignalDataTypeId(%d)',dataId);

        otherwise

        end

        if col2Row
            dirStr='TLC_TRUE';
        else
            dirStr='TLC_FALSE';
        end



        dtName=sprintf('LibGetDataTypeNameFromId(%s)',dTypeIdStr);


        slMatPtrStr=sprintf('((%%<%s>*)__%sBUS)',dtName,thisData.Identifier);
        cMatPtrStr=sprintf('((%%<%s>*)__%sM2D)',dtName,thisData.Identifier);


        fprintf(fid,'      %%<SLibConvert2DMatrix(%s, %s, %s, %s, "%s", "%s", %d, TLC_FALSE, 0)>\n',...
        dirStr,dTypeIdStr,widthStr,dimStr,cMatPtrStr,slMatPtrStr,thisData.CMatrix2D.MatInfo);

    end

end


