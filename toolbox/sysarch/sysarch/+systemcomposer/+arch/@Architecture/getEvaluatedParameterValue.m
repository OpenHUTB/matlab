function[val,unit]=getEvaluatedParameterValue(this,paramFQN)
    valStruct=this.ElementImpl.getParamVal(paramFQN);
    val=[];
    unit=valStruct.units;

    if~isempty(valStruct.expression)
        def=this.ElementImpl.getParameterDefinition(paramFQN);
        if~isempty(def)
            val=this.castValueToCorrectDataType(def.type,valStruct.expression);
        end
    end
end
