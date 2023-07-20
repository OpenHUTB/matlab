classdef CollectVariableInformation<handle
    properties
ConversionData
DataAccessor
ConversionParameters
    end
    properties(Hidden)
busListBefore
busListAfter
numericTypeIDsBefore
numericTypeIDsAfter
    end
    methods(Access=public)
        function this=CollectVariableInformation(ConversionData,DataAccessor)
            this.ConversionData=ConversionData;
            this.ConversionParameters=ConversionData.ConversionParameters;
            this.DataAccessor=DataAccessor;
        end

        function collectBeforeConversion(this)
            varIds=this.DataAccessor.identifyVisibleVariablesDerivedFromClass('Simulink.Bus');
            numericTypeIDs=this.DataAccessor.identifyVisibleVariablesDerivedFromClass('Simulink.NumericType');
            this.numericTypeIDsBefore={numericTypeIDs.Name};
            this.busListBefore={varIds.Name};
        end

        function collectAfterConversion(this)
            varIds=this.DataAccessor.identifyVisibleVariablesDerivedFromClass('Simulink.Bus');
            numericTypeIDs=this.DataAccessor.identifyVisibleVariablesDerivedFromClass('Simulink.NumericType');
            this.numericTypeIDsAfter={numericTypeIDs.Name};
            this.busListAfter={varIds.Name};
        end
        function collectData(this,CompiledIOInfo)

            busNames=Simulink.ModelReference.Conversion.Utilities.cellify(setdiff(this.busListAfter,this.busListBefore));


            numericTypeNames=Simulink.ModelReference.Conversion.Utilities.cellify(setdiff(this.numericTypeIDsAfter,this.numericTypeIDsBefore));
            if~isempty(numericTypeNames)
                cellfun(@(varName)this.ConversionData.addVariable(varName),numericTypeNames);
            end


            if~isempty(busNames)
                if this.ConversionParameters.ExpandVirtualBusPorts
                    this.ConversionData.addNewModelFixObj(Simulink.ModelReference.Conversion.ExpandVirtualBusPortsForModelBlocks(...
                    this.ConversionData,CompiledIOInfo,busNames,this.ConversionData.ModelBlocks));
                else
                    cellfun(@(varName)this.ConversionData.addVariable(varName),busNames);
                end
            end
        end
    end
end