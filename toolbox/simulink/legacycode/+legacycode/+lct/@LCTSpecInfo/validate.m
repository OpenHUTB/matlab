




function validate(this)


    if this.hasDynamicArrayArgument||this.hasDynamicArrayAggregate

        if this.Specs.Options.singleCPPMexFile
            error(message('Simulink:tools:LCTSpecParserBadDynamicArrayCodeAPI'));
        end
    end
    if this.hasDynamicArrayAggregate

        for ii=(this.DataTypes.NumSLBuiltInDataTypes+1):this.DataTypes.Numel
            dataType=this.DataTypes.Items(ii);
            if dataType.isAggregateType()
                for jj=1:numel(dataType.Elements)
                    if dataType.Elements(jj).IsDynamicArray
                        error(message('Simulink:tools:LCTSpecParserBadDynamicArrayBusElement',...
                        dataType.Elements(jj).Name,dataType.Name));
                    end
                end
            end
        end
    end


    this.forEachDataSet(@(o,n,s)iValidateIdNumber(this,s,n));




    this.forEachFunction(@(o,k,f)f.forEachArg(@(f,a)validateArg(f,k,a)));

    function validateArg(funSpec,funKind,argSpec)

        if argSpec.Data.isExprArg()

            iValidateExprArgument(this,funSpec,funKind,argSpec);

        else
            if~argSpec.Data.isParameter()


                iValidateParameterInfoAsDimension(this,funSpec,argSpec);


                if~argSpec.Data.isInput()

                    iValidateInputInfoAsDimension(this,funSpec,argSpec);
                end
            end


            iValidateDynamicArraySpecification(this,funSpec,argSpec);
        end

    end

end




function iValidateIdNumber(this,dataSet,dataSetName)


    ids=dataSet.Ids;
    if isempty(dataSet.Ids)
        return
    end


    ids=unique(ids);
    d=diff(ids);
    if isempty(d)
        d=1;
    end


    if ids(1)~=1||max(d)>1


        dataName=dataSetName(1:end-1);
        desc=this.genMsgForCrossSpecError(dataName,'NameStartPos','NameExpr');


        origMsg=message('Simulink:tools:LCTErrorValidateDataId',dataName);
        msg=message('Simulink:tools:LCTErrorRethrowErrorWithSpec',desc,getString(origMsg));
        throw(MException(msg));
    end

end





function iValidateParameterInfoAsDimension(this,funSpec,argSpec)


    dataSpec=argSpec.Data;
    dataKind=char(dataSpec.Kind);
    dataRadix=dataSpec.Radix;
    dataId=dataSpec.Id;


    for ii=1:numel(dataSpec.DimsInfo)


        dimInfo=dataSpec.DimsInfo(ii);
        if dimInfo.Val==-1&&dimInfo.HasInfo==1


            for kk=1:numel(dimInfo.Info)
                exprInfo=dimInfo.Info(kk);


                if~strcmpi(exprInfo.Radix,'p')||~ismember(exprInfo.Kind,{'v','s','n'})
                    continue
                end

                paramId=exprInfo.Id;
                if exprInfo.Kind=='v'

                    dimRef=0;
                elseif exprInfo.Kind=='s'

                    dimRef=exprInfo.Val;
                else

                    dimRef=-1;
                end


                if isempty(this.Parameters.findItem(paramId))
                    msg=message('Simulink:tools:LCTErrorValidateBadParameterOrInputAsDim',...
                    dataKind,dataRadix,dataId,'Parameter','p',paramId);
                    legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                    funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                    getString(msg));
                end



                thisParam=this.Parameters.Items(paramId);
                paramDims=thisParam.Dimensions;
                paramWidth=thisParam.Width;
                if dimRef==0


                    if thisParam.IsComplex==1
                        msg=message('Simulink:tools:LCTErrorValidateBadComplexParamAsDim',...
                        paramId);
                        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                        funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                        getString(msg));
                    end




                    dataType=this.DataTypes.getBottomAliasedType(thisParam.DataTypeId);
                    if dataType.isAggregateType()||...
                        dataType.isFixpointType()||dataType.isEnumType()
                        msg=message('Simulink:tools:LCTErrorValidateBadFixedPointParamAsDim',...
                        paramId);
                        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                        funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                        getString(msg));
                    end



                    if(numel(paramDims)>1)||(paramWidth~=1)
                        msg=message('Simulink:tools:LCTErrorValidateBadParamValueAsDim',...
                        dataKind,dataRadix,dataId,paramId);
                        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                        funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                        getString(msg));
                    end
                else


                    if(dimRef>=1)&&(paramWidth==1)
                        msg=message('Simulink:tools:LCTErrorValidateBadScalarParameterOrInputAsDim',...
                        dataKind,dataRadix,dataId,'Parameter','p',paramId);
                        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                        funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                        getString(msg));
                    end




                    if dimRef>numel(paramDims)
                        msg=message('Simulink:tools:LCTErrorValidateBadDimParameterOrInputAsDim',...
                        dataKind,dataRadix,dataId,'Parameter','p',paramId);
                        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                        funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                        getString(msg));
                    end
                end
            end
        end
    end

end




function iValidateInputInfoAsDimension(this,funSpec,argSpec)


    dataSpec=argSpec.Data;
    dataKind=char(dataSpec.Kind);
    dataRadix=dataSpec.Radix;
    dataId=dataSpec.Id;


    for ii=1:numel(dataSpec.DimsInfo)


        dimInfo=dataSpec.DimsInfo(ii);
        if dimInfo.Val==-1&&dimInfo.HasInfo==1


            for kk=1:numel(dimInfo.Info)
                exprInfo=dimInfo.Info(kk);


                if~strcmpi(exprInfo.Radix,'u')||~ismember(exprInfo.Kind,{'s','n'})
                    continue
                end

                inputId=exprInfo.Id;
                if exprInfo.Kind=='s'

                    dimRef=exprInfo.Val;
                else

                    dimRef=-1;
                end


                if isempty(this.Inputs.findItem(inputId))
                    msg=message('Simulink:tools:LCTErrorValidateBadParameterOrInputAsDim',...
                    dataKind,dataRadix,dataId,'Input','u',inputId);
                    legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                    funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                    getString(msg));
                end



                thisInput=this.Inputs.Items(inputId);
                if(dimRef>=1)&&(thisInput.Width==1)
                    msg=message('Simulink:tools:LCTErrorValidateBadScalarParameterOrInputAsDim',...
                    dataKind,dataRadix,dataId,'Input','u',inputId);
                    legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                    funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                    getString(msg));
                end




                if dimRef>numel(thisInput.DimsInfo)
                    msg=message('Simulink:tools:LCTErrorValidateBadDimParameterOrInputAsDim',...
                    dataKind,dataRadix,dataId,'Input','u',inputId);
                    legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                    funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
                    getString(msg));
                end
            end
        end
    end

end




function iValidateExprArgument(this,funSpec,funKind,argSpec)



    dataType=this.DataTypes.getBottomAliasedType(argSpec.Data.DataTypeId);
    if dataType.isAggregateType()||dataType.isFixpointType()||dataType.isEnumType()
        msg=message('Simulink:tools:LCTErrorValidateSizeArgDataType',...
        argSpec.Expression,funKind);
        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
        funSpec.Expression,argSpec.TypeStartPos,numel(argSpec.TypeExpr),...
        getString(msg));
    end



    for ii=1:numel(argSpec.Data.DimsInfo.Info)



        exprInfo=argSpec.Data.DimsInfo.Info(ii);
        if~ismember(exprInfo.Kind,{'v','s','n'})
            continue
        end

        dataKind=legacycode.lct.spec.Common.Radix2RoleMap(exprInfo.Radix);
        dataKindSet=[dataKind,'s'];
        if exprInfo.Kind=='s'

            dataDim=exprInfo.Val;
        else

            dataDim=-1;
        end


        if isempty(this.(dataKindSet).findItem(exprInfo.Id))
            msg=message('Simulink:tools:LCTErrorValidateSizeArgDataId',...
            argSpec.Expression,funKind,lower(dataKind),exprInfo.Id);
            legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
            funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
            getString(msg));
        end


        theData=this.(dataKindSet).Items(exprInfo.Id);
        if(dataDim>1)&&(dataDim>numel(theData.DimsInfo))
            msg=message('Simulink:tools:LCTErrorValidateSizeArgDataDim',...
            argSpec.Expression,funKind,lower(dataKind),exprInfo.Id);
            legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
            funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression),...
            getString(msg));
        end
    end

end




function iValidateDynamicArraySpecification(this,funSpec,argSpec)


    isInf=[argSpec.Data.DimsInfo.IsInf];
    if~(all(isInf==true)||all(isInf==false))
        [argStr,numS]=legacycode.lct.spec.Common.remWhiteSpaces(argSpec.DimExpr);
        msg=message('Simulink:tools:LCTSpecParserBadMixedDynFixDims',argSpec.DimExpr);
        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
        funSpec.Expression,numS+argSpec.DimStartPos-1,numel(argStr),...
        getString(msg));
    end


    if this.Specs.Options.convertNDArrayToRowMajor&&argSpec.Data.IsDynamicArray
        matInfo=this.getNDArrayMarshalingInfo(argSpec.Data);
        if matInfo>0
            [argStr,numS]=legacycode.lct.spec.Common.remWhiteSpaces(argSpec.DimExpr);
            msg=message('Simulink:tools:LCTSpecParserBadDynamicArrayRowMajor',argSpec.DimExpr);
            legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
            funSpec.Expression,numS+argSpec.DimStartPos-1,numel(argStr),...
            getString(msg));
        end
    end


    if argSpec.Data.isDWork()&&argSpec.Data.IsDynamicArray
        [argStr,numS]=legacycode.lct.spec.Common.remWhiteSpaces(argSpec.DimExpr);
        msg=message('Simulink:tools:LCTSpecParserBadDynamicArrayDWork',argSpec.DimExpr);
        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
        funSpec.Expression,numS+argSpec.DimStartPos-1,numel(argStr),...
        getString(msg));
    end


    if argSpec.Data.isParameter()&&argSpec.Data.IsDynamicArray
        [argStr,numS]=legacycode.lct.spec.Common.remWhiteSpaces(argSpec.DimExpr);
        msg=message('Simulink:tools:LCTSpecParserBadDynamicArrayParameter',argSpec.DimExpr);
        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
        funSpec.Expression,numS+argSpec.DimStartPos-1,numel(argStr),...
        getString(msg));
    end

end


