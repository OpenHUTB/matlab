classdef CopyIOAttributes<handle




    properties(SetAccess=private,GetAccess=public)
PortHandles
OutportParameters
OutportValues
    end
    properties(Constant,Access=private)
        ExcludedPortParameters={'PropagatedSignals','PerturbationForJacobian','ConnectionCallback','StorageClass','SignalObject','DataLoggingDecimation','DataLoggingSampleTime','DataLoggingMaxPoints'};
    end

    methods(Access=public)
        function this=CopyIOAttributes(subsys)
            this.PortHandles=get_param(subsys,'PortHandles');


            outports=this.PortHandles.Outport;
            numOutputs=length(outports);
            this.OutportParameters=cell(1,numOutputs);
            this.OutportValues=cell(1,numOutputs);
            for idx=1:numOutputs
                [prmNames,prmVals]=Simulink.ModelReference.Conversion.PortUtils.getOutputSigInfo(outports(idx));
                this.OutportParameters{idx}=prmNames;
                this.OutportValues{idx}=prmVals;
            end
        end

        function copy(this,dstBlk)
            if dstBlk==0
                return;
            end
            dstPortHandles=get_param(dstBlk,'PortHandles');
            outports=dstPortHandles.Outport;

            if(numel(this.PortHandles.Outport)==numel(outports))

                if~isempty(outports)
                    arrayfun(@(idx)this.copyOutportInfo(outports(idx),this.OutportParameters{idx},...
                    this.OutportValues{idx},this.ExcludedPortParameters),1:numel(outports));
                end
            end
        end
    end

    methods(Static,Access=private)
        function copyOutportInfo(dstBlk,portNames,portValues,filteredParams)
            [paramNames,indexes]=setdiff(portNames,filteredParams,'stable');
            paramValues=portValues(indexes);
            arrayfun(@(idx)set_param(dstBlk,paramNames{idx},paramValues{idx}),1:numel(paramNames));
        end
    end
end
