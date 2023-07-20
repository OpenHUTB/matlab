function writeSfcnCGIRClass(obj,fid,infoStruct)









    if infoStruct.canUseSFcnCGIRAPI==false
        return
    end


    infoStruct.indent4='    ';
    infoStruct.indent8=[infoStruct.indent4,infoStruct.indent4];
    infoStruct.indent12=[infoStruct.indent8,infoStruct.indent4];
    infoStruct.indent16=[infoStruct.indent12,infoStruct.indent4];


    fprintf(fid,'#if defined(MATLAB_MEX_FILE)\n');
    fprintf(fid,'using namespace SFun;\n');
    fprintf(fid,'\n');
    delim=repmat('=',1,64-length(infoStruct.Specs.SFunctionName));
    fprintf(fid,'/* Class: %s %s\n',infoStruct.Specs.SFunctionName,delim);
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    An instance of this class is called when Simulink Coder is generating\n');
    fprintf(fid,' *    the model.rtw file and the S-Function uses the Code Construction API.\n');
    fprintf(fid,' */\n');
    fprintf(fid,'class %s_Block : public SFun::Block\n',infoStruct.Specs.SFunctionName);
    fprintf(fid,'{\n');







    propStr=iGetNDMatrixDimsInfoProperties(obj,infoStruct);


    if~isempty(propStr)
        fprintf(fid,'  private:\n');
        fprintf(fid,'    /*\n');
        fprintf(fid,'     * Attributes for quicker access to data dimension info\n');
        fprintf(fid,'     */\n');
        for ii=1:size(propStr,1)
            fprintf(fid,'%s\n',propStr{ii,1});
        end
        fprintf(fid,'\n');
    end


    fprintf(fid,'  public:\n');
    fprintf(fid,'    /*\n');
    fprintf(fid,'     * Constructor\n');
    fprintf(fid,'     */\n');
    fprintf(fid,'    %s_Block(SFun::SFun_Block_Impl* pImpl) : SFun::Block(pImpl)\n',...
    infoStruct.Specs.SFunctionName);
    fprintf(fid,'    {\n');

    if~isempty(propStr)

        for ii=1:size(propStr,1)

            fprintf(fid,'%s\n',propStr{ii,2});
        end
    end
    fprintf(fid,'    }\n');
    fprintf(fid,'\n');

    if infoStruct.Fcns.Start.IsSpecified
        fprintf(fid,'    /*\n');
        fprintf(fid,'     * Perform initializations on startup\n');
        fprintf(fid,'     */\n');
        fprintf(fid,'    virtual void cgStart()\n');
        fprintf(fid,'    {\n');
        iWriteCGIRMethod(obj,fid,infoStruct,'Start');
        fprintf(fid,'    }\n');
    end

    if infoStruct.Fcns.InitializeConditions.IsSpecified
        fprintf(fid,'    /*\n');
        fprintf(fid,'     * Perform initializations on startup or subsystem restart\n');
        fprintf(fid,'     */\n');
        fprintf(fid,'    virtual void cgInitialize()\n');
        fprintf(fid,'    {\n');
        iWriteCGIRMethod(obj,fid,infoStruct,'InitializeConditions');
        fprintf(fid,'    }\n');
    end

    if infoStruct.Fcns.Output.IsSpecified
        fprintf(fid,'    /*\n');
        fprintf(fid,'     * Compute the signals that this block emits\n');
        fprintf(fid,'     */\n');
        fprintf(fid,'    virtual void cgOutput()\n');
        fprintf(fid,'    {\n');
        iWriteCGIRMethod(obj,fid,infoStruct,'Output');
        fprintf(fid,'    }\n');
    end

    if infoStruct.Fcns.Terminate.IsSpecified
        fprintf(fid,'    /*\n');
        fprintf(fid,'     * Clean up the block on termination\n');
        fprintf(fid,'     */\n');
        fprintf(fid,'    virtual void cgTerminate()\n');
        fprintf(fid,'    {\n');
        iWriteCGIRMethod(obj,fid,infoStruct,'Terminate');
        fprintf(fid,'    }\n');
    end

    fprintf(fid,'};\n');
    fprintf(fid,'#endif\n');
    fprintf(fid,'\n');

end



function propStr=iGetNDMatrixDimsInfoProperties(obj,infoStruct)



    propStr=cell(0,2);

    function nGetDimsForData(aData,aDataKind,aDataId)



        if aData.Width==1||numel(aData.Dimensions)<=2



        else

            varDeclStr=sprintf('%sDimsInfo_T dimsInfo_%s;\n',infoStruct.indent4,aData.Identifier);
            varDeclStr=sprintf('%s%sint_T dimsArray_%s[%d];\n',...
            varDeclStr,infoStruct.indent4,aData.Identifier,numel(aData.Dimensions));

            tmpTxt=sprintf('%sdimsInfo_%s.numDims = %d;\n',...
            infoStruct.indent8,aData.Identifier,numel(aData.Dimensions));

            if any(aData.Dimensions==-1)


                widthStr=iGetDataWidthWithSFcnAPI(aDataKind,aDataId);

                tmpTxt=sprintf('%s%sdimsInfo_%s.width = %s;\n',...
                tmpTxt,infoStruct.indent8,aData.Identifier,widthStr);

                for jj=1:numel(aData.Dimensions)






                    dimStr=iGetDynamicallySizedDataDimWithSFcnAPI(obj,...
                    infoStruct,aDataKind,aDataId,jj);

                    tmpTxt=sprintf('%s%sdimsArray_%s[%d] = %s;\n',...
                    tmpTxt,infoStruct.indent8,...
                    aData.Identifier,jj-1,dimStr);
                end

            else

                tmpTxt=sprintf('%s%sdimsInfo_%s.width = %d;\n',...
                tmpTxt,infoStruct.indent8,aData.Identifier,aData.Width);

                for jj=1:numel(aData.Dimensions)
                    tmpTxt=sprintf('%s%sdimsArray_%s[%d] = %d;\n',...
                    tmpTxt,infoStruct.indent8,aData.Identifier,jj-1,aData.Dimensions(jj));
                end
            end

            tmpTxt=sprintf('%s%sdimsInfo_%s.dims = &dimsArray_%s[0];\n',...
            tmpTxt,infoStruct.indent8,aData.Identifier,aData.Identifier);


            propStr(end+1,1:2)={varDeclStr,tmpTxt};
        end
    end

    for ii=1:infoStruct.Inputs.Num

        thisData=infoStruct.Inputs.Input(ii);
        nGetDimsForData(thisData,'Input',ii);
    end

    for ii=1:infoStruct.Outputs.Num

        thisData=infoStruct.Outputs.Output(ii);
        nGetDimsForData(thisData,'Output',ii);
    end

    for ii=1:infoStruct.Parameters.Num

        thisData=infoStruct.Parameters.Parameter(ii);
        nGetDimsForData(thisData,'Parameter',ii);
    end

    for ii=1:infoStruct.DWorks.Num

        thisData=infoStruct.DWorks.DWork(ii);
        nGetDimsForData(thisData,'DWork',ii);
    end

end



function iWriteCGIRMethod(obj,fid,infoStruct,methodName)


    fcnStruct=infoStruct.Fcns.(methodName);

    function newDataKind=nGetAPIDataKind(dataKind)


        switch dataKind
        case 'Input'
            newDataKind='input';
        case 'Parameter'
            newDataKind='param';
        case 'Output'
            newDataKind='output';
        case 'DWork'
            newDataKind='dWork';
        otherwise

        end
    end

    function[typeStr,argStr,extraStr]=nGetDataTypeAndArgStr(aData,aArg)





        dataKind=nGetAPIDataKind(aArg.Type);





        extraStr='';


        dataTypeStr=iGetDataTypeWithSFcnAPI(aArg.Type,aArg.DataId);
        typeStr=sprintf('Type(%s)',dataTypeStr);

        if aData.IsComplex
            typeStr=sprintf('complex(%s)',typeStr);
        end

        if aData.Width==1

            if~strcmp(aArg.AccessType,'direct')
                typeStr=sprintf('%spointerTo(%s)',infoStruct.indent12,typeStr);



                if strcmpi(dataKind,'input')||strcmp(dataKind,'param')



                    extraStr=sprintf('%sReference %s%d_tmp(createLocal(%s(%d).type()));',...
                    infoStruct.indent8,dataKind,aArg.DataId-1,dataKind,aArg.DataId-1);

                    extraStr=sprintf('%s\n%s%s%d_tmp = %s(%d);',...
                    extraStr,infoStruct.indent8,dataKind,aArg.DataId-1,dataKind,aArg.DataId-1);

                    argStr=sprintf('addressOf(%s%d_tmp)',dataKind,aArg.DataId-1);

                elseif strcmpi(dataKind,'output')||strcmpi(dataKind,'dwork')


                    extraStr=sprintf('%sReference %s%d_tmp(%s(%d));\n',...
                    infoStruct.indent8,dataKind,aArg.DataId-1,dataKind,aArg.DataId-1);

                    argStr=sprintf('addressOf(%s%d_tmp)',dataKind,aArg.DataId-1);

                else
                    argStr=sprintf('%addressOf(s(%d))',dataKind,aArg.DataId-1);

                end

            else

                typeStr=sprintf('%s%s',infoStruct.indent12,typeStr);
                argStr=sprintf('%s(%d)',dataKind,aArg.DataId-1);
            end

        else


            hasDynSize=any(aData.Dimensions==-1);

            if numel(aData.Dimensions)<2

                if hasDynSize
                    widthStr=iGetDataWidthWithSFcnAPI(aArg.Type,aArg.DataId);
                    typeStr=sprintf('%svectorOf(%s, %s)',...
                    infoStruct.indent12,typeStr,widthStr);
                else
                    typeStr=sprintf('%svectorOf(%s, %d)',...
                    infoStruct.indent12,typeStr,aData.Width);
                end

            elseif numel(aData.Dimensions)==2

                if hasDynSize
                    dim1Str=iGetDynamicallySizedDataDimWithSFcnAPI(obj,...
                    infoStruct,aArg.Type,aArg.DataId,1);

                    dim2Str=iGetDynamicallySizedDataDimWithSFcnAPI(obj,...
                    infoStruct,aArg.Type,aArg.DataId,2);

                    typeStr=sprintf('%smatrixOf(%s, %s, %s)',...
                    infoStruct.indent12,typeStr,dim1Str,dim2Str);

                else
                    typeStr=sprintf('%smatrixOf(%s, %d, %d)',...
                    infoStruct.indent12,typeStr,aData.Dimensions(1),aData.Dimensions(2));
                end

            else

                typeStr=sprintf('%smatrixOf(%s, dimsInfo_%s)',...
                infoStruct.indent12,typeStr,aData.Identifier);
            end














            if strcmpi(dataKind,'output')||strcmpi(dataKind,'dwork')


                extraStr=sprintf('%sReference %s%d_tmp(%s(%d));\n',...
                infoStruct.indent8,dataKind,aArg.DataId-1,dataKind,aArg.DataId-1);

                argStr=sprintf('addressOf(%s%d_tmp)',dataKind,aArg.DataId-1);

                typeStr=sprintf('%spointerTo(%s)',infoStruct.indent12,strtrim(typeStr));

            else
                argStr=sprintf('%s(%d)',dataKind,aArg.DataId-1);
            end

        end
    end


    sepTypeStr='';
    sepArgStr='';
    typeArrayStr='';
    rhsArgStr='';
    rhsArgExtraStr='';


    useArrayofInputArg=fcnStruct.RhsArgs.NumArgs>3;

    if useArrayofInputArg
        rhsArgArrayStr=sprintf('%sValue inputArgs[] = {\n',infoStruct.indent8);
    end


    hasOutputOnRhs=false;

    for ii=1:fcnStruct.RhsArgs.NumArgs
        thisArg=fcnStruct.RhsArgs.Arg(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);

        if strcmp(thisArg.Type,'SizeArg')
            if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))

            else

                thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
            end





            dataTypeEnum=thisDataType.Enum;


            sizeArgStr=obj.generateSfcnCGIRSizeArgString(infoStruct,thisArg);

            typeStr=sprintf('%sType(%s)',infoStruct.indent12,dataTypeEnum);
            argStr=sprintf('Value(Type(%s), %s)',dataTypeEnum,sizeArgStr);


        else
            if strcmpi(thisArg.Type,'output')
                hasOutputOnRhs=true;
            end

            thisData=infoStruct.([thisArg.Type,'s']).(thisArg.Type)(thisArg.DataId);
            [typeStr,argStr,extraStr]=nGetDataTypeAndArgStr(thisData,thisArg);

            if~isempty(extraStr)


                rhsArgExtraStr=[rhsArgExtraStr,extraStr];%#ok<AGROW>
            end

        end

        typeArrayStr=sprintf('%s%s%s',typeArrayStr,sepTypeStr,typeStr);

        if useArrayofInputArg

            rhsArgArrayStr=sprintf('%s%s%s%s',rhsArgArrayStr,sepArgStr,infoStruct.indent12,argStr);
            sepArgStr=sprintf(', \n');
        else

            rhsArgStr=sprintf('%s%s%s',rhsArgStr,sepArgStr,argStr);
            sepArgStr=', ';
        end

        sepTypeStr=sprintf(', \n');

    end

    if useArrayofInputArg

        rhsArgArrayStr=sprintf('%s\n%s};\n',rhsArgArrayStr,infoStruct.indent8);
        rhsArgStr=sprintf('inputArgs, %d',fcnStruct.RhsArgs.NumArgs);
    end

    if~isempty(typeArrayStr)
        fprintf(fid,'%s/* Array of Input Data Types */\n',infoStruct.indent8);
        fprintf(fid,'%sType inputTypes[] = {\n%s\n%s};\n',infoStruct.indent8,typeArrayStr,infoStruct.indent8);
        inputTypesStr='inputTypes';
    else
        inputTypesStr='NULL';
    end

    fprintf(fid,'\n');


    lhsArgStr='';
    fprintf(fid,'%s/* Output Data Type */\n',infoStruct.indent8);
    if fcnStruct.LhsArgs.NumArgs==1
        thisArg=fcnStruct.LhsArgs.Arg(1);


        dataTypeStr=iGetDataTypeWithSFcnAPI(thisArg.Type,thisArg.DataId);
        fprintf(fid,'%sType outputType = Type(%s);\n',infoStruct.indent8,dataTypeStr);


        lhsArgStr=sprintf('output(%d) = ',thisArg.DataId-1);
    else

        fprintf(fid,'%sType outputType = Type::voidType();\n',infoStruct.indent8);
    end
    fprintf(fid,'\n');


    headerFileName='NULL';
    if~isempty(infoStruct.Specs.HeaderFiles)
        headerFileName=infoStruct.Specs.HeaderFiles{1};
    end


    token=regexpi(fcnStruct.RhsExpression,'(\w*)\s*\(','tokens');
    fcnName=token{1}{1};


    fprintf(fid,'        /* Function object mapped to the external function */\n');
    fprintf(fid,'        Function _%s_obj("%s", "%s", outputType, %s, %d);\n',...
    fcnName,fcnName,headerFileName,inputTypesStr,fcnStruct.RhsArgs.NumArgs);
    fprintf(fid,'\n');









    isPure=(infoStruct.Specs.Options.isMacro==false)&&...
    (infoStruct.Specs.Options.isVolatile==false)&&...
    (fcnStruct.LhsArgs.NumArgs==1)&&(hasOutputOnRhs==false);
    if isPure
        isPureStr='true';
    else
        isPureStr='false';
    end

    fprintf(fid,'        _%s_obj.setPure(%s);\n',fcnName,isPureStr);
    fprintf(fid,'\n');

    if~isempty(rhsArgExtraStr)

        fprintf(fid,'        /* Locally defined argument(s) */\n');
        fprintf(fid,'%s\n',rhsArgExtraStr);
    end

    if useArrayofInputArg
        fprintf(fid,'        /* Input argument(s) */\n');
        fprintf(fid,'%s\n',rhsArgArrayStr);
    end

    fprintf(fid,'        /* Invoke the function in the generated code */\n');
    fprintf(fid,'        %s _%s_obj(%s);\n',...
    lhsArgStr,fcnName,rhsArgStr);

end



function widthStr=iGetDataWidthWithSFcnAPI(aDataKind,aDataId)


    switch aDataKind
    case 'Parameter',
        widthStr=sprintf('mxGetNumberOfElements(ssGetSFcnParam(getSimStruct(), %d))',...
        aDataId-1);

    case 'DWork'
        widthStr=sprintf('ssGetDWorkWidth(getSimStruct(), %d)',...
        aDataId-1);

    case 'Input'
        widthStr=sprintf('ssGetInputPortWidth(getSimStruct(), %d)',...
        aDataId-1);

    case 'Output'
        widthStr=sprintf('ssGetOutputPortWidth(getSimStruct(), %d)',...
        aDataId-1);

    otherwise

        widthStr='DYNAMICALLY_SIZED';
    end

end


function dataTypeStr=iGetDataTypeWithSFcnAPI(aDataKind,aDataId)


    switch aDataKind
    case 'Parameter',

        dataTypeStr=sprintf('(ssGetRunTimeParamInfo(getSimStruct(), %d))->dataTypeId',...
        aDataId-1);

    case 'DWork'
        dataTypeStr=sprintf('ssGetDWorkDataType(getSimStruct(), %d)',...
        aDataId-1);

    case 'Input'
        dataTypeStr=sprintf('ssGetInputPortDataType(getSimStruct(), %d)',...
        aDataId-1);

    case 'Output'
        dataTypeStr=sprintf('ssGetOutputPortDataType(getSimStruct(), %d)',...
        aDataId-1);

    otherwise

        dataTypeStr='DYNAMICALLY_TYPED';
    end

end



function dimStr=iGetDynamicallySizedDataDimWithSFcnAPI(obj,infoStruct,aDataKind,aDataId,aDataDim)



    switch aDataKind
    case{'Input','Parameter'}



        fakeData.DimsInfo.DimInfo.Type=aDataKind;
        fakeData.DimsInfo.DimInfo.DataId=aDataId;
        fakeData.DimsInfo.DimInfo.DimRef=aDataDim;

        dimStr=obj.generateSfcnCGIRSizeArgString(infoStruct,fakeData);

    case{'Output','DWork'}


        fakeData.DimsInfo.DimInfo.Type=aDataKind;
        fakeData.DimsInfo.DimInfo.DataId=aDataId;
        fakeData.DimsInfo.DimInfo.DimRef=aDataDim;

        dimStr=obj.generateSfcnCGIRSizeArgString(infoStruct,fakeData);

    otherwise

        dimStr='DYNAMICALLY_SIZED';
    end

end
