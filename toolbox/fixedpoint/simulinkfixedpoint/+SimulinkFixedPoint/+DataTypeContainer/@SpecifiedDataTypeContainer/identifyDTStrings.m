function success=identifyDTStrings(this,dataTypeString)





    success=true;
    this.evaluatedDTString=dataTypeString;
    if SimulinkFixedPoint.DataTypeContainer.isStrFltptType(dataTypeString)

        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.FloatingPoint;
        this.evaluatedNumericType=this.getSimulinkNumericType(this.getFloatingPointNumericType(dataTypeString));
        this.evaluatedDTString=this.getEvalString(dataTypeString);
    elseif SimulinkFixedPoint.DataTypeContainer.isInheritedDTStr(dataTypeString)

        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.Inherited;
    elseif SimulinkFixedPoint.DataTypeContainer.isStringBoolean(dataTypeString)

        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.Boolean;
        this.evaluatedNumericType=fixdt('boolean');
    elseif strncmpi(regexprep(dataTypeString,'\s',''),'Enum:',5)||Simulink.data.isSupportedEnumClass(dataTypeString)

        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.Enum;
    elseif strncmpi(dataTypeString,'Bus:',4)

        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.Bus;
    else
        success=false;
    end

    if~success&&SimulinkFixedPoint.DataTypeContainer.isStringBuiltInInteger(dataTypeString)

        numericType=fixdt(dataTypeString);
        success=identifyNumericTypeObject(this,numericType,false);
    end

end
