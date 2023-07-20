




function validateFun(this,funSpec,funKind)

    funSpec.forEachArg(@(f,a)validate(f,a))

    function validate(funSpec,argSpec)

        if argSpec.Data.isInput()

            if~strcmpi(funKind,'Output')
                legacycode.lct.spec.Common.error('LCTSpecParserBadInputAccessForMethod',...
                funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression));
            end
        elseif argSpec.Data.isOutput()
            if this.Specs.Options.outputsConditionallyWritten




                if strcmpi(funKind,'Terminate')
                    legacycode.lct.spec.Common.error('LCTSpecParserBadOutputAccessForTerminate',...
                    funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression));
                end
            else

                if~strcmpi(funKind,'Output')
                    legacycode.lct.spec.Common.error('LCTSpecParserBadOutputAccessForMethod',...
                    funSpec.Expression,argSpec.PosOffset,numel(argSpec.Expression));
                end
            end
        elseif argSpec.Data.isDSM()

            nChar=numel(argSpec.Data.Identifier);
            legacycode.lct.spec.Common.error('LCTDSMFunctionArgNotSupported',funSpec.Expression,argSpec.NameStartPos-1,nChar,funKind);
        end

        iValidateComplexDataType(this,funSpec,argSpec);
        iValidateDynamicallySizedDimensions(this,funSpec,argSpec);
    end

end




function iValidateComplexDataType(this,funSpec,argSpec)


    dataSpec=argSpec.Data;
    dataType=this.DataTypes.Items(dataSpec.DataTypeId);

    if dataSpec.IsComplex&&(dataType.Id>this.DataTypes.NumSLBuiltInDataTypes-1)

        if dataType.isBooleanType()||...
            dataType.isAliasType()||...
            this.DataTypes.isBooleanType(dataType.IdAliasedTo)||...
            this.DataTypes.isBooleanType(dataType.IdAliasedThruTo)||...
            dataType.isAggregateType()||...
            dataType.isEnumType()



            msg=message('Simulink:tools:LCTErrorValidateBadBooleanComplex',...
            char(dataSpec.Kind),dataSpec.Id);
            legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
            funSpec.Expression,argSpec.PosOffset,numel(argSpec.TypeExpr),...
            getString(msg));
        end
    end

end





function iValidateDynamicallySizedDimensions(this,funSpec,argSpec)


    dataSpec=argSpec.Data;
    if dataSpec.isExprArg()
        return
    end










    isDynSized=this.isTrueDynamicSize(dataSpec);

    if any(isDynSized==true)&&~all(isDynSized==true)


        msg=message('Simulink:tools:LCTErrorValidateAllDynSize',...
        char(dataSpec.Kind),dataSpec.Id);
        legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
        funSpec.Expression,argSpec.DimStartPos-1,numel(argSpec.DimExpr),...
        getString(msg));
    end

end


