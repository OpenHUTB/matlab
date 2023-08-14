classdef RTEDataItemOperation<handle




    properties(Access='private')
        Arguments;
        LHSArgString;
    end

    properties(Access='protected')
        OpName;
        PortName;
    end

    methods(Abstract)
        accessFcnName=getAccessFcnName(this);
    end

    methods(Access='public')
        function this=RTEDataItemOperation(opName,portName,args,lhsArgString)
            this.OpName=opName;
            this.PortName=portName;
            this.Arguments=args;
            this.LHSArgString=lhsArgString;
        end

        function res=getOperationName(this)
            res=this.OpName;
        end

        function rhsString=getAccessFcnRHSArgs(this)
            rhsString='';
            for i=1:length(this.Arguments)
                arg=this.Arguments(i);
                if i==1
                    commaOpt='';
                else
                    commaOpt=', ';
                end
                if strcmp(arg.Direction,'In')
                    rhsString=[rhsString,commaOpt,arg.getInArgStr];%#ok<AGROW>
                else
                    assert(any(strcmp(arg.Direction,{'Out','InOut'})),...
                    'Unexpected direction for operation argument: "%s".',...
                    arg.Direction);
                    rhsString=[rhsString,commaOpt,arg.getOutOrInOutArgStr];%#ok<AGROW>
                end
            end
        end

        function lhsString=getAccessFcnLHSArg(this)
            lhsString=this.LHSArgString;
        end
    end
end
