classdef RemoveSameDT<DataTypeOptimization.Preprocessing.BlockActions








    properties(SetAccess=private,GetAccess=public)
blocks
    end

    methods
        function this=RemoveSameDT()
            this.ActionDescription=message('SimulinkFixedPoint:dataTypeOptimization:removeSameDTActionDescription').getString;
        end

        function performAction(this,environmentContext)

            allBlocks=this.getAllBlocks(environmentContext);



            hasPropertyActive=false(numel(allBlocks),1);
            for bIndex=1:numel(allBlocks)
                if isprop(allBlocks(bIndex),'InputSameDT')
                    hasPropertyActive(bIndex)=strcmp(allBlocks(bIndex).InputSameDT,'on');
                end
            end
            allBlocks(~hasPropertyActive)='';
            this.blocks=allBlocks;


            this.changeSetting('off');
        end

        function revertAction(this)

            this.changeSetting('on');
        end

        function si=exportSimulationInput(this,environmentContext)
            si=Simulink.SimulationInput(environmentContext.TopModel);
            bPath=arrayfun(@(x)(x.getFullName),this.blocks,'UniformOutput',false)';
            pName='InputSameDT';
            pValue='off';
            si.BlockParameters=cellfun(@(x)(Simulink.Simulation.BlockParameter(x,pName,pValue)),bPath);
        end

    end

    methods(Hidden)
        function changeSetting(this,settingValueStr)

            set(this.blocks,'InputSameDT',settingValueStr);

        end
    end
end