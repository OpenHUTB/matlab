function identifyEvaluatedObj(this)





    evaluatedObject=this.resolvedObject;
    dataTypeString=this.origDTString;

    if(isa(evaluatedObject,'Simulink.AliasType'))

        this.isAliasFlag=true;
    elseif isa(evaluatedObject,'Simulink.IntEnumType')||...
        ((isa(evaluatedObject,'meta.class'))&&(evaluatedObject<?Simulink.IntEnumType))

        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.Enum;
    elseif isa(evaluatedObject,'Simulink.Bus')

        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.Bus;
        if~strncmp(dataTypeString,'Bus:',4)
            this.evaluatedDTString=this.getEvalString(['Bus: ',dataTypeString]);
        end
    else
        evaluatedObject=fixdtUpdate(evaluatedObject,[],true);

        try

            scaledDouble=evaluatedObject.isscaleddouble;
        catch


            scaledDouble=false;
        end

        identifyNumericTypeObject(this,evaluatedObject,scaledDouble);
    end
end
