function writeSfcnTempVariableForUserStruct(h,fid,infoStruct,fcnInfo)%#ok<INUSL>





    hasComment=false;
    if fcnInfo.LhsArgs.NumArgs==1
        thisArg=fcnInfo.LhsArgs.Arg(1);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        if thisDataType.IsBus==1||thisDataType.IsStruct==1


            if hasComment==false

                fprintf(fid,'/*\n');
                fprintf(fid,' * Locally declared variable(s)\n');
                fprintf(fid,' */\n');
                hasComment=true;
            end


            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            thisDWorkNumber=infoStruct.DWorks.NumPWorks+thisData.BusInfo.DWorkId-1;

            fprintf(fid,'%s *__%sBUS = (%s *) ssGetPWorkValue(S, %d);\n',...
            thisDataType.Name,thisArg.Identifier,thisDataType.Name,thisDWorkNumber);
        end
    end

    for ii=1:fcnInfo.RhsArgs.NumArgs
        thisArg=fcnInfo.RhsArgs.Arg(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        if thisDataType.IsBus==1||thisDataType.IsStruct==1


            if hasComment==false

                fprintf(fid,'/*\n');
                fprintf(fid,' * Locally declared variable(s)\n');
                fprintf(fid,' */\n');
                hasComment=true;
            end


            thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,thisArg);
            thisDWorkNumber=infoStruct.DWorks.NumPWorks+thisData.BusInfo.DWorkId-1;

            fprintf(fid,'%s *__%sBUS = (%s *) ssGetPWorkValue(S, %d);\n',...
            thisDataType.Name,thisArg.Identifier,thisDataType.Name,thisDWorkNumber);
        end
    end


