function traceVarToWorkspace(this)




    if this.isVarName&&(this.isFloat||this.isFixed)

        varUsages=getVarUsage(this);

        if~isempty(varUsages)

            varUsage=varUsages(1);
            numOfVarUsage=length(varUsages);



            for i=1:numOfVarUsage
                if strcmp(varUsages(i).Source,this.contextPath)
                    varUsage=varUsages(i);
                    break;
                end
            end


            this.variableSourceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.convertToEnumSourceType(varUsage.SourceType);


            this.variableSource=varUsage.Source;

        else


            this.variableSourceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.convertToEnumSourceType('function call');


            this.variableSource=this.origDTString;
        end
    end


    this.hasVariableBeenTraced=true;
end

