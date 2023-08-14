function writeSfcnTempVariableFor2DRowMatrix(~,fid,infoStruct,fcnInfo)






    hasComment=false;
    if fcnInfo.LhsArgs.NumArgs==1
        emitLocalDWorkAccess(fcnInfo.LhsArgs.Arg(1));
    end

    for ii=1:fcnInfo.RhsArgs.NumArgs
        emitLocalDWorkAccess(fcnInfo.RhsArgs.Arg(ii));
    end

    function emitLocalDWorkAccess(arg)
        if strcmpi(arg.Type,'SizeArg')
            return
        end

        thisData=legacycode.util.lct_pGetDataFromArg(infoStruct,arg);
        if thisData.CMatrix2D.DWorkId>0
            if hasComment==false

                fprintf(fid,'/*\n');
                fprintf(fid,' * Locally declared variable(s) for 2D Row Major Matrix\n');
                fprintf(fid,' */\n');
                hasComment=true;
            end

            thisDataType=infoStruct.DataTypes.DataType(arg.DataTypeId);
            thisDWorkNumber=infoStruct.DWorks.NumDWorks+thisData.CMatrix2D.DWorkId-1;

            fprintf(fid,'%s *__%sM2D = (%s *) ssGetDWork(S, %d);\n',...
            thisDataType.Name,arg.Identifier,thisDataType.Name,thisDWorkNumber);
        end
    end

end
