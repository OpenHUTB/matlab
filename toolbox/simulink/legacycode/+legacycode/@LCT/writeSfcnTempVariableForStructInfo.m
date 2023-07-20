function writeSfcnTempVariableForStructInfo(~,fid,infoStruct)









    if size(infoStruct.DataTypes.BusInfo.BusElementHashTable,1)~=0
        fprintf(fid,'/*\n');
        fprintf(fid,' * Access bus/struct information\n');
        fprintf(fid,' */\n');
        fprintf(fid,'\n');

        trueNumDWorks=infoStruct.DWorks.TotalNumDWorks-infoStruct.DWorks.NumDWorkForBus;


        fprintf(fid,'int32_T *__dtSizeInfo = (int32_T *) ssGetDWork(S, %d);\n',...
        trueNumDWorks-2);
        fprintf(fid,'int32_T *__dtBusInfo = (int32_T *) ssGetDWork(S, %d);\n',...
        trueNumDWorks-1);
        fprintf(fid,'\n');
    end