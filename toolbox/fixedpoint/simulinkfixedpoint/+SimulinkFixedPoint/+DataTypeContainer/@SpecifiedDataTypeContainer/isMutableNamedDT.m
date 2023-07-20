function flag=isMutableNamedDT(this)

















    if isempty(this.variableSourceType)...
        ||this.variableSourceType==SimulinkFixedPoint.AutoscalerVarSourceTypes.Unknown
        flag=false;
    elseif this.variableSourceType==SimulinkFixedPoint.AutoscalerVarSourceTypes.Mask
        flag=false;


    else



        flag=this.isVarName;
    end
end
