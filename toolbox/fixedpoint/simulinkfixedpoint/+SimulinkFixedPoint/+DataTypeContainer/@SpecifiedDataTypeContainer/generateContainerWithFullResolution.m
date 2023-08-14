function generateContainerWithFullResolution(this,contextObj)













    if isRecursiveCreationNeeded(this)

        dataTypeString=getDataTypeStringForRecursiveCreation(this);



        success=this.identifyDTStrings(dataTypeString);
        if~success
            success=identifyStringWithEval(this,dataTypeString);
        end



        if~success
            this.childDTContainerObj=SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer(dataTypeString,contextObj);
            this.evaluatedNumericType=this.childDTContainerObj.evaluatedNumericType;
            this.containerType=this.childDTContainerObj.containerType;
            this.evaluatedDTString=this.childDTContainerObj.evaluatedDTString;
        end
    end
end
