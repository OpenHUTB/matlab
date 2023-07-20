function writeSfcnArgumentAccess(h,fid,infoStruct,fcnStruct)






    buffStr='';



    for ii=1:fcnStruct.RhsArgs.NumArgs
        thisArg=fcnStruct.RhsArgs.Arg(ii);
        if strcmp(thisArg.Type,'Parameter')
            thisData=infoStruct.Parameters.Parameter(thisArg.DataId);
            thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

            if(thisDataType.IsBus==1)||(thisDataType.IsStruct==1)


                dataTypeName='char';
            else
                if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                    dataTypeName=thisDataType.Name;
                else

                    thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                    dataTypeName=thisDataType.Name;
                end
            end


            if thisData.IsComplex==1
                dataTypeName=sprintf('c%s',dataTypeName);
            end
            buffStr=sprintf('%s  %s *p%d = (%s *) ssGetRunTimeParamInfo(S, %d)->data;\n',...
            buffStr,dataTypeName,thisArg.DataId,dataTypeName,thisArg.DataId-1);
        end
    end



    for ii=1:fcnStruct.RhsArgs.NumArgs
        thisArg=fcnStruct.RhsArgs.Arg(ii);
        if strcmp(thisArg.Type,'Input')
            thisData=infoStruct.Inputs.Input(thisArg.DataId);
            thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

            if(thisDataType.IsBus==1)||(thisDataType.IsStruct==1)


                dataTypeName='char';
            else
                if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                    dataTypeName=thisDataType.Name;
                else

                    thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                    dataTypeName=thisDataType.Name;
                end
            end


            if thisData.IsComplex==1
                dataTypeName=sprintf('c%s',dataTypeName);
            end
            buffStr=sprintf('%s  %s *u%d = (%s *) ssGetInputPortSignal(S, %d);\n',...
            buffStr,dataTypeName,thisArg.DataId,dataTypeName,thisArg.DataId-1);
        end
    end



    for ii=1:fcnStruct.RhsArgs.NumArgs
        thisArg=fcnStruct.RhsArgs.Arg(ii);
        if strcmp(thisArg.Type,'Output')
            thisData=infoStruct.Outputs.Output(thisArg.DataId);
            thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
            if(thisDataType.IsBus==1)||(thisDataType.IsStruct==1)


                dataTypeName='char';
            else
                if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                    dataTypeName=thisDataType.Name;
                else

                    thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                    dataTypeName=thisDataType.Name;
                end
            end


            if thisData.IsComplex==1
                dataTypeName=sprintf('c%s',dataTypeName);
            end
            buffStr=sprintf('%s  %s *y%d = (%s *) ssGetOutputPortSignal(S, %d);\n',...
            buffStr,dataTypeName,thisArg.DataId,dataTypeName,thisArg.DataId-1);
        end
    end



    for ii=1:fcnStruct.RhsArgs.NumArgs
        thisArg=fcnStruct.RhsArgs.Arg(ii);
        if strcmp(thisArg.Type,'DWork')
            thisData=infoStruct.DWorks.DWork(thisArg.DataId);
            thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);


            if~isempty(thisData.pwIdx)
                buffStr=sprintf('%s  void *work%d = ssGetPWorkValue(S, %d);\n',...
                buffStr,thisArg.DataId,thisData.pwIdx-1);
            else
                if(thisDataType.IsBus==1)||(thisDataType.IsStruct==1)


                    dataTypeName='char';
                else
                    if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                        dataTypeName=thisDataType.Name;
                    else

                        thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                        dataTypeName=thisDataType.Name;
                    end
                end


                if thisData.IsComplex==1
                    dataTypeName=sprintf('c%s',dataTypeName);
                end

                buffStr=sprintf('%s  %s *work%d = (%s *) ssGetDWork(S, %d);\n',...
                buffStr,dataTypeName,thisArg.DataId,dataTypeName,thisData.dwIdx-1);
            end
        end
    end


    for ii=1:fcnStruct.RhsArgs.NumArgs
        thisArg=fcnStruct.RhsArgs.Arg(ii);
        if strcmp(thisArg.Type,'SizeArg')
            thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
            if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                dataTypeName=thisDataType.Name;
            else

                thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                dataTypeName=thisDataType.Name;
            end


            impArgStr=iGetSizeArgStr(h,infoStruct,thisArg);
            buffStr=sprintf('%s  %s %s = (%s) %s;\n',...
            buffStr,dataTypeName,thisArg.Identifier,dataTypeName,impArgStr);
        end
    end

    if fcnStruct.LhsArgs.NumArgs==1
        thisArg=fcnStruct.LhsArgs.Arg(1);
        if strcmp(thisArg.Type,'Output')
            thisData=infoStruct.Outputs.Output(thisArg.DataId);
            thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

            if(thisDataType.IsBus==1)||(thisDataType.IsStruct==1)


                dataTypeName='char';
            else
                if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

                    dataTypeName=thisDataType.Name;
                else

                    thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                    dataTypeName=thisDataType.Name;
                end
            end


            if thisData.IsComplex==1
                dataTypeName=sprintf('c%s',dataTypeName);
            end
            buffStr=sprintf('%s  %s *y%d = (%s *) ssGetOutputPortSignal(S, %d);\n',...
            buffStr,dataTypeName,thisArg.DataId,dataTypeName,thisArg.DataId-1);
        end
    end

    if~isempty(buffStr)
        fprintf(fid,'/*\n');
        fprintf(fid,' * Get access to Parameter/Input/Output/DWork/size information\n');
        fprintf(fid,' */\n');
        fprintf(fid,'%s',buffStr);
    end


    function str=iGetSizeArgStr(h,infoStruct,thisArg)





        dataKind=thisArg.DimsInfo.DimInfo.Type;
        dataId=thisArg.DimsInfo.DimInfo.DataId;
        dataDim=thisArg.DimsInfo.DimInfo.DimRef;


        str=h.generateSfcnDataDimStrRecursively(infoStruct,dataKind,dataId,dataDim,'0');

