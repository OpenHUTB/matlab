



classdef hdldelaytypeenum<handle
    enumeration
Delay
DelayEnabled
DelayResettable
DelayEnabledResettable
VariableDelay
VariableDelayEnabled
VariableDelayResettable
VariableDelayEnabledResettable
    end

    methods

        function newObj=convertToVariableDelay(obj)
            switch(obj)
            case hdldelaytypeenum.Delay
                newObj=hdldelaytypeenum.VariableDelay;
            case hdldelaytypeenum.DelayEnabled
                newObj=hdldelaytypeenum.VariableDelayEnabled;
            case hdldelaytypeenum.DelayResettable
                newObj=hdldelaytypeenum.VariableDelayResettable;
            case hdldelaytypeenum.DelayEnabledResettable
                newObj=hdldelaytypeenum.VariableDelayEnabledResettable;
            otherwise
                newObj=obj;
            end
        end

        function whichdelaytype=isRegularDelay(obj)
            whichdelaytype=(hdldelaytypeenum.Delay==obj);
        end

        function whichdelaytype=isDelayEnabled(obj)
            whichdelaytype=(hdldelaytypeenum.DelayEnabled==obj);
        end

        function whichdelaytype=isDelayResettable(obj)
            whichdelaytype=(hdldelaytypeenum.DelayResettable==obj);
        end

        function whichdelaytype=isDelayEnabledResettable(obj)
            whichdelaytype=(hdldelaytypeenum.DelayEnabledResettable==obj);
        end

        function whichdelaytype=isVariableDelay(obj)
            whichdelaytype=(hdldelaytypeenum.VariableDelay==obj);
        end

        function whichdelaytype=isVariableDelayEnabled(obj)
            whichdelaytype=(hdldelaytypeenum.VariableDelayEnabled==obj);
        end

        function whichdelaytype=isVariableDelayResettable(obj)
            whichdelaytype=(hdldelaytypeenum.VariableDelayEnabled==obj);
        end

        function whichdelaytype=isVariableDelayEnabledResettable(obj)
            whichdelaytype=(hdldelaytypeenum.VariableDelayEnabledResettable==obj);
        end

        function[rstsig,portIdx]=getRstSignal(obj,insigs)
            switch(obj)
            case{hdldelaytypeenum.DelayResettable,hdldelaytypeenum.DelayEnabledResettable,hdldelaytypeenum.VariableDelayResettable,hdldelaytypeenum.VariableDelayEnabledResettable}
                portIdx=length(insigs);
                rstsig=insigs(portIdx);
            otherwise
                rstsig=[];
                portIdx=[];
            end
        end

        function[enbsigs,startPortIdx,endPortIdx]=getEnbSignals(obj,insigs)
            switch(obj)
            case hdldelaytypeenum.DelayEnabled
                startPortIdx=2;
                endPortIdx=length(insigs);
                enbsigs=insigs(startPortIdx:endPortIdx);

            case hdldelaytypeenum.DelayEnabledResettable
                startPortIdx=2;
                endPortIdx=length(insigs)-1;
                enbsigs=insigs(startPortIdx:endPortIdx);

            case hdldelaytypeenum.VariableDelayEnabled
                startPortIdx=3;
                endPortIdx=length(insigs);
                enbsigs=insigs(startPortIdx:endPortIdx);

            case hdldelaytypeenum.VariableDelayEnabledResettable
                startPortIdx=3;
                endPortIdx=length(insigs)-1;
                enbsigs=insigs(startPortIdx:endPortIdx);

            otherwise
                enbsigs=[];
            end
        end
    end
end
