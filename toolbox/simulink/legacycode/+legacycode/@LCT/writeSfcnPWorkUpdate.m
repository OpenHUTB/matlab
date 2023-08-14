function writeSfcnPWorkUpdate(h,fid,infoStruct,fcnStruct)%#ok<INUSL>





    buffStr='';


    for ii=1:fcnStruct.RhsArgs.NumArgs
        thisArg=fcnStruct.RhsArgs.Arg(ii);
        if strcmp(thisArg.Type,'DWork')
            thisDWork=infoStruct.DWorks.DWork(thisArg.DataId);
            if~isempty(thisDWork.pwIdx)
                buffStr=sprintf('%s ssSetPWorkValue(S, %d, work%d);\n',...
                buffStr,thisDWork.pwIdx-1,thisArg.DataId);
            end
        end
    end

    if~isempty(buffStr)
        fprintf(fid,'\n');
        fprintf(fid,'/* Update the PWorks */\n');
        fprintf(fid,'%s\n',buffStr);
        fprintf(fid,'\n');
    end

