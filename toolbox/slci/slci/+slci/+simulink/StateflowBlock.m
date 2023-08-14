


classdef StateflowBlock<slci.simulink.Block

    properties
        fChart=[];
    end

    methods

        function aObj=StateflowBlock(aBlk,aModel)
            aObj=aObj@slci.simulink.Block(aBlk,aModel);
            aObj.setSupportsBuses(true);
            aObj.setSupportsEnums(true);
            aObj.fChart=slci.stateflow.Chart(aBlk,aObj,aModel);
            aModel.addChart(aObj.fChart);


            aObj.addConstraint(...
            slci.compatibility.SupportedNonInlinedSubsystemConstraint);


            aObj.addConstraint(...
            slci.compatibility.SupportedReuseSubsystemConstraint);


            aObj.addConstraint(...
            slci.compatibility.SupportedNonReuseSubsystemConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

        function out=getChart(aObj)
            out=aObj.fChart;
        end

    end

end

