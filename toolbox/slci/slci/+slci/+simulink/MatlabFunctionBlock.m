


classdef MatlabFunctionBlock<slci.simulink.Block

    properties

        fEMChart=[];
    end

    methods




        function obj=MatlabFunctionBlock(aBlkHdl,aModel)
            obj=obj@slci.simulink.Block(aBlkHdl,aModel);
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
            chartId=sfprivate('block2chart',aBlkHdl);
            emUDDObject=idToHandle(sfroot,chartId);
            assert(numel(emUDDObject)==1);
            obj.fEMChart=slci.matlab.EMChart(obj,emUDDObject);
            obj.addConstraints();
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
            assert(~isempty(aObj.fEMChart));
            out=[out,aObj.fEMChart.checkCompatibility()];
        end


        function listCompatibility(aObj)
            listCompatibility@slci.simulink.Block(aObj);
            assert(~isempty(aObj.fEMChart));
            aObj.fEMChart.listCompatibility();
        end


        function em=getEMChart(aObj)
            em=aObj.fEMChart;
        end

    end

    methods(Access=private)

        function addConstraints(aObj)



            aObj.removeConstraint('SupportedPortDataTypes');
            aObj.removeConstraint('BlockPortsNonComplex');


            aObj.addConstraint(...
            slci.compatibility.SupportedNonInlinedSubsystemConstraint);


            aObj.addConstraint(...
            slci.compatibility.SupportedReuseSubsystemConstraint);


            aObj.addConstraint(...
            slci.compatibility.SupportedNonReuseSubsystemConstraint);
        end

    end

end
