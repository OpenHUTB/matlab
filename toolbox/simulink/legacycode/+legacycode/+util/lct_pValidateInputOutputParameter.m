function lct_pValidateInputOutputParameter(infoStruct)







    if infoStruct.Parameters.Num>0
        err=iValidateIdNumber(infoStruct.Parameters.Id);
        if err
            DAStudio.error('Simulink:tools:LCTErrorValidateDataId','Parameter');
        end



        for ii=1:infoStruct.Parameters.Num
            thisData=infoStruct.Parameters.Parameter(ii);
            thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);

            if thisData.IsComplex
                if thisDataType.Id>infoStruct.DataTypes.NumSLBuiltInDataTypes-1

                    if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))||...
                        (thisDataType.Id==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedThruTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IsBus==1||thisDataType.IsStruct==1||thisDataType.IsEnum==1)

                        DAStudio.error('Simulink:tools:LCTErrorValidateBadBooleanComplex',...
                        'Parameter',ii);
                    end
                end
            end
        end



        iValidateDynamicallySizedDimensions(infoStruct,'Parameter');

    end


    if infoStruct.Inputs.Num>0
        err=iValidateIdNumber(infoStruct.Inputs.Id);
        if err
            DAStudio.error('Simulink:tools:LCTErrorValidateDataId','Input');
        end
        for ii=1:infoStruct.Inputs.Num
            thisData=infoStruct.Inputs.Input(ii);
            thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);

            if thisData.IsComplex
                if thisDataType.Id>infoStruct.DataTypes.NumSLBuiltInDataTypes-1

                    if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))||...
                        (thisDataType.Id==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedThruTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IsBus==1||thisDataType.IsStruct==1||thisDataType.IsEnum==1)

                        DAStudio.error('Simulink:tools:LCTErrorValidateBadBooleanComplex',...
                        'Input',ii);
                    end
                end
            end

        end



        iValidateParameterInfoAsDimension(infoStruct,'Input','u');



        iValidateDynamicallySizedDimensions(infoStruct,'Input');

    end


    if infoStruct.Outputs.Num>0
        err=iValidateIdNumber(infoStruct.Outputs.Id);
        if err
            DAStudio.error('Simulink:tools:LCTErrorValidateDataId','Output');
        end
        for ii=1:infoStruct.Outputs.Num
            thisData=infoStruct.Outputs.Output(ii);
            thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);

            if thisData.IsComplex
                if thisDataType.Id>infoStruct.DataTypes.NumSLBuiltInDataTypes-1

                    if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))||...
                        (thisDataType.Id==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedThruTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IsBus==1||thisDataType.IsStruct==1||thisDataType.IsEnum==1)

                        DAStudio.error('Simulink:tools:LCTErrorValidateBadBooleanComplex',...
                        'Output',ii);
                    end
                end
            end

        end



        iValidateParameterInfoAsDimension(infoStruct,'Output','y');



        iValidateInputInfoAsDimension(infoStruct,'Output','y');



        iValidateDynamicallySizedDimensions(infoStruct,'Output');

    end


    if infoStruct.DWorks.Num>0
        err=iValidateIdNumber(infoStruct.DWorks.Id);
        if err
            DAStudio.error('Simulink:tools:LCTErrorValidateDataId','Work');
        end
        for ii=1:infoStruct.DWorks.Num
            thisData=infoStruct.DWorks.DWork(ii);
            thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);

            if thisData.IsComplex
                if thisDataType.Id>infoStruct.DataTypes.NumSLBuiltInDataTypes-1

                    if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))||...
                        (thisDataType.Id==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IdAliasedThruTo==infoStruct.DataTypes.NumSLBuiltInDataTypes)||...
                        (thisDataType.IsBus==1||thisDataType.IsStruct==1||thisDataType.IsEnum==1)

                        DAStudio.error('Simulink:tools:LCTErrorValidateBadBooleanComplex',...
                        'Work',ii);
                    end
                end
            end

        end



        iValidateParameterInfoAsDimension(infoStruct,'DWork','work');



        iValidateInputInfoAsDimension(infoStruct,'DWork','work');



        iValidateDynamicallySizedDimensions(infoStruct,'DWork');

    end


    iValidateSizeArgument(infoStruct,'InitializeConditions');
    iValidateSizeArgument(infoStruct,'Start');
    iValidateSizeArgument(infoStruct,'Output');
    iValidateSizeArgument(infoStruct,'Terminate');



    if infoStruct.Specs.Options.convertNDArrayToRowMajor
        if infoStruct.Specs.Options.singleCPPMexFile
            DAStudio.error('Simulink:tools:LCTSFcnCodeAPIError2DMatrixNotSupported');
        end
        iVerifySupportedDimensionsForRowMajorConversion(infoStruct);
    end

end


function err=iValidateIdNumber(num)

    err=0;

    num=unique(num);
    d=diff(num);
    if isempty(d)
        d=1;
    end
    if num(1)~=1||max(d)>1
        err=1;
    end

end


function iValidateParameterInfoAsDimension(infoStruct,type,radixName)



    for ii=1:infoStruct.([type,'s']).Num
        thisData=infoStruct.([type,'s']).(type)(ii);


        for jj=1:length(thisData.Dimensions)


            if thisData.Dimensions(jj)==-1&&thisData.DimsInfo.HasInfo(jj)==1
                if strcmp(thisData.DimsInfo.DimInfo(jj).Type,'Parameter')


                    paramId=thisData.DimsInfo.DimInfo(jj).DataId;
                    if~ismember(paramId,infoStruct.Parameters.Id)
                        DAStudio.error('Simulink:tools:LCTErrorValidateBadParameterOrInputAsDim',...
                        type,radixName,ii,'Parameter','p',paramId);
                    end


                    thisParam=infoStruct.Parameters.Parameter(paramId);



                    if thisData.DimsInfo.DimInfo(jj).DimRef==0


                        if thisParam.IsComplex==1
                            DAStudio.error('Simulink:tools:LCTErrorValidateBadComplexParamAsDim',...
                            paramId);
                        end




                        thisDataType=infoStruct.DataTypes.DataType(thisParam.DataTypeId);
                        if thisDataType.Id~=thisDataType.IdAliasedThruTo
                            thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                        end
                        if(thisDataType.IsBus==1)||(thisDataType.IsStruct==1)||...
                            (thisDataType.IsFixedPoint==1)||(thisDataType.IsEnum==1)
                            DAStudio.error('Simulink:tools:LCTErrorValidateBadFixedPointParamAsDim',...
                            paramId);
                        end



                        if(length(thisParam.Dimensions)>1||thisParam.Width~=1)
                            DAStudio.error('Simulink:tools:LCTErrorValidateBadParamValueAsDim',...
                            type,radixName,ii,paramId);
                        end

                    else


                        if(thisData.DimsInfo.DimInfo(jj).DimRef>=1)&&...
                            (thisParam.Width==1)
                            DAStudio.error('Simulink:tools:LCTErrorValidateBadScalarParameterOrInputAsDim',...
                            type,radixName,ii,'Parameter','p',paramId);
                        end




                        if(thisData.DimsInfo.DimInfo(jj).DimRef>length(thisParam.Dimensions))
                            DAStudio.error('Simulink:tools:LCTErrorValidateBadDimParameterOrInputAsDim',...
                            type,radixName,ii,'Parameter','p',paramId);
                        end

                    end

                end
            end
        end
    end

end


function iValidateInputInfoAsDimension(infoStruct,type,radixName)


    for ii=1:infoStruct.([type,'s']).Num
        thisData=infoStruct.([type,'s']).(type)(ii);


        for jj=1:length(thisData.Dimensions)


            if thisData.Dimensions(jj)==-1&&thisData.DimsInfo.HasInfo(jj)==1
                if strcmp(thisData.DimsInfo.DimInfo(jj).Type,'Input')
                    inputId=thisData.DimsInfo.DimInfo(jj).DataId;


                    if~ismember(inputId,infoStruct.Inputs.Id)
                        DAStudio.error('Simulink:tools:LCTErrorValidateBadParameterOrInputAsDim',...
                        type,radixName,ii,'Input','u',inputId);
                    end


                    thisInput=infoStruct.Inputs.Input(inputId);



                    if(thisData.DimsInfo.DimInfo(jj).DimRef>=1)&&(thisInput.Width==1)
                        DAStudio.error('Simulink:tools:LCTErrorValidateBadScalarParameterOrInputAsDim',...
                        type,radixName,ii,'Input','u',inputId);
                    end




                    if(thisData.DimsInfo.DimInfo(jj).DimRef>length(thisInput.Dimensions))
                        DAStudio.error('Simulink:tools:LCTErrorValidateBadDimParameterOrInputAsDim',...
                        type,radixName,ii,'Input','u',inputId);
                    end

                end
            end
        end
    end

end


function iValidateDynamicallySizedDimensions(infoStruct,type)




    for ii=1:infoStruct.([type,'s']).Num
        thisData=infoStruct.([type,'s']).(type)(ii);











        isDynSized=legacycode.util.lct_pIsTrueDynamicSize(infoStruct,thisData);

        if any(isDynSized==true)
            if~all(isDynSized==true)
                DAStudio.error('Simulink:tools:LCTErrorValidateAllDynSize',...
                lower(type),ii);
            end
        end
    end

end


function iValidateSizeArgument(infoStruct,fcnSpecType)


    fcnArgs=infoStruct.Fcns.(fcnSpecType).RhsArgs;


    if fcnArgs.NumArgs==0
        return
    end


    sizeArgIdx=find(strncmp('SizeArg',{fcnArgs.Arg(:).Type},7));
    if isempty(sizeArgIdx)
        return
    end

    for ii=1:length(sizeArgIdx)

        thisArg=fcnArgs.Arg(sizeArgIdx(ii));



        thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
        if thisDataType.Id~=thisDataType.IdAliasedThruTo
            thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
        end
        if(thisDataType.IsBus==1)||(thisDataType.IsStruct==1)||...
            (thisDataType.IsFixedPoint==1)||(thisDataType.IsEnum==1)
            DAStudio.error('Simulink:tools:LCTErrorValidateSizeArgDataType',...
            thisArg.Expression,fcnSpecType);
        end



        dataKind=thisArg.DimsInfo.DimInfo.Type;
        dataId=thisArg.DimsInfo.DimInfo.DataId;
        dataDim=thisArg.DimsInfo.DimInfo.DimRef;


        if infoStruct.([dataKind,'s']).Num<dataId
            DAStudio.error('Simulink:tools:LCTErrorValidateSizeArgDataId',...
            thisArg.Expression,fcnSpecType,lower(dataKind),dataId);
        end


        theData=infoStruct.([dataKind,'s']).(dataKind)(dataId);


        if dataDim>length(theData.Dimensions)
            DAStudio.error('Simulink:tools:LCTErrorValidateSizeArgDataDim',...
            thisArg.Expression,fcnSpecType,lower(dataKind),dataId);
        end

    end

end


function iVerifySupportedDimensionsForRowMajorConversion(infoStruct)


    fType={'Input','Output','Parameter'};
    for ii=1:numel(fType)
        for jj=1:infoStruct.([fType{ii},'s']).Num
            thisData=infoStruct.([fType{ii},'s']).(fType{ii})(jj);
            thisDataType=infoStruct.DataTypes.DataType(thisData.DataTypeId);
            if thisDataType.IsBus||thisDataType.IsStruct
                nVerifyBusElementDimensions(thisData.Identifier,thisDataType);
            end
            if numel(thisData.Dimensions)==2&&thisData.IsComplex


                DAStudio.error('Simulink:tools:LCTSFcnCplx2DMatrixNotSupported',...
                thisData.Identifier);
            end
        end
    end

    function nVerifyBusElementDimensions(dataName,busType)
        for kk=1:busType.NumElements
            el=busType.Elements(kk);
            dt=infoStruct.DataTypes.DataType(el.DataTypeId);

            if el.NumDimensions==2&&el.IsComplex



                DAStudio.error('Simulink:tools:LCTSFcnBusElementCplx2DMatrixNotSupported',...
                el.Name,busType.Name,dataName);
            end

            if dt.IsBus||dt.IsStruct

                nVerifyBusElementDimensions(dataName,dt);
            end
        end
    end
end


