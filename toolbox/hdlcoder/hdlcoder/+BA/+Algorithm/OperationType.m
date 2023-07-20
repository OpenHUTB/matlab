



classdef OperationType<handle

    methods(Static)

        function[opType,numInputs,dimension]=get(pirOutSignal)
            import BA.Abstraction.*;
            opType=OPTYPE.UNKNOWN;
            numInputs=0;
            drivingPort=pirOutSignal.getDrivers;
            if isempty(drivingPort)||length(drivingPort)~=1
                return;
            end
            drivingComp=drivingPort.Owner;
            numInputs=length(drivingComp.getInputSignals('data'));
            dimension=BA.Algorithm.OperationType.getNumDimension(drivingComp);
            if~strcmp(drivingComp.ClassName,'network')...
                &&~isempty(drivingComp)&&drivingComp.isNetworkInstance
                opType=OPTYPE.INSTANCE;
            end
            if BA.Algorithm.OperationType.isEMLComp(drivingComp)
                if BA.Algorithm.OperationType.isAdd(drivingComp)
                    opType=OPTYPE.ADD;
                elseif BA.Algorithm.OperationType.isMult(drivingComp)
                    opType=OPTYPE.MULT;
                elseif BA.Algorithm.OperationType.isDiv(drivingComp)
                    opType=OPTYPE.DIV;
                elseif BA.Algorithm.OperationType.isDelay(drivingComp)
                    opType=OPTYPE.DELAY;
                elseif BA.Algorithm.OperationType.isRelop(drivingComp)
                    opType=OPTYPE.RELOP;
                end
            end
        end

        function flag=isEMLComp(comp)
            flag=strcmp(comp.ClassName,'eml_comp');
        end

        function dim=getNumDimension(comp)
            dim=1;
            if BA.Algorithm.OperationType.isEMLComp(comp)...
                &&(strcmp(comp.IpFileName,'hdleml_sum_of_elements')...
                ||strcmp(comp.IpFileName,'hdleml_product_of_elements'))
                inputSignal=comp.getInputSignals('data');
                dim=inputSignal.Type.dimension;
            end
        end

        function flag=isAdd(comp)
            flag=strcmp(comp.IpFileName,'hdleml_sum_of_vararg_elements')...
            ||strcmp(comp.IpFileName,'hdleml_sum_of_elements')...
            ||strcmp(comp.IpFileName,'hdleml_add_withcast')...
            ||strcmp(comp.IpFileName,'hdleml_sub_withcast')...
            ||strcmp(comp.IpFileName,'hdleml_subsub');
        end

        function flag=isMult(comp)
            flag=strcmp(comp.IpFileName,'hdleml_gain')...
            ||strcmp(comp.IpFileName,'hdleml_product_of_elements')...
            ||strcmp(comp.IpFileName,'hdleml_product');
        end

        function flag=isDiv(comp)
            flag=strcmp(comp.IpFileName,'hdleml_divide');
        end

        function flag=isDelay(comp)
            flag=strcmp(comp.IpFileName,'hdleml_delay')...
            ||strcmp(comp.IpFileName,'hdleml_intdelay');
        end

        function flag=isRelop(comp)
            flag=strcmp(comp.IpFileName,'hdleml_relop');
        end

    end
end
