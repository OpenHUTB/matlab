classdef SerDesIBISComponent<serdes.internal.ibisami.ibis.AbstractIBISComponent



























    properties
        Differential(1,1){serdes.utilities.mustBeA(Differential,'logical')}=true
        TxModelName(1,1)string="TxModel"
        RxModelName(1,1)string="RxModel"
        IOModelName(1,1)string="io_model"
        ModelTypes(1,1)string="Both Tx and Rx"
        isIO(1,1)logical=false
    end
    methods

        function component=SerDesIBISComponent(varargin)





            if nargin==1
                component.Differential=varargin{1};
                component.ComponentName="SerDes";
                component.RxModelName="RxModel";
                component.TxModelName="TxModel";
                component.ModelTypes="Both Tx And Rx";
            elseif nargin>1
                parser=inputParser;
                parser.addParameter('componentname',"SerDes")
                parser.addParameter('differential',true)
                parser.addParameter('modelnamerx',"RxModel")
                parser.addParameter('modelnametx',"TxModel")
                parser.addParameter('modeltypes',"Both Tx And Rx")
                parser.parse(varargin{:})
                args=parser.Results;
                component.ComponentName=args.componentname;
                component.Differential=args.differential;
                component.RxModelName=args.modelnamerx;
                component.TxModelName=args.modelnametx;
            end
        end
    end
    methods
        function set.Differential(component,differential)
            component.Differential=differential;
            if differential
                diff2=serdes.internal.ibisami.ibis.IBISDiffPin('pinName',"3",...
                'invPinName','4',...
                'vDiff',0.02);
                diff1=serdes.internal.ibisami.ibis.IBISDiffPin('pinName',"1",...
                'invPinName','2');
                component.DiffPins=[diff1,diff2];
                component.Pins(3).PinName="3";
            else
                component.DiffPins=serdes.internal.ibisami.ibis.IBISDiffPin.empty;
                component.Pins(3).PinName="2";
            end
            component.SetModelTypesVisiblity
        end
        function set.RxModelName(component,value)
            component.RxModelName=value;
            component.Pins(3)=serdes.internal.ibisami.ibis.IBISPin('pinName',"3",...
            'signalName',"Rx",...
            'modelName',component.RxModelName);
            component.Pins(4)=serdes.internal.ibisami.ibis.IBISPin('pinName',"4",...
            'signalName',"Rx#",...
            'modelName',component.RxModelName);
            component.SetModelTypesVisiblity
        end
        function set.TxModelName(component,value)
            component.TxModelName=value;
            component.SetPinsForisIO
            component.SetModelTypesVisiblity
        end
        function set.IOModelName(component,value)
            component.IOModelName=value;
            component.SetPinsForisIO
            component.SetModelTypesVisiblity
        end
        function set.ModelTypes(component,modelTypes)
            component.ModelTypes=modelTypes;
            component.SetModelTypesVisiblity
        end
        function set.isIO(component,value)
            component.isIO=value;
            component.SetPinsForisIO
            component.SetModelTypesVisiblity
        end
    end
    methods(Access=private)
        function SetPinsForisIO(component)
            if component.isIO
                component.Pins(1)=serdes.internal.ibisami.ibis.IBISPin('pinName',"1",...
                'signalName',"IO",...
                'modelName',component.IOModelName);
                component.Pins(2)=serdes.internal.ibisami.ibis.IBISPin('pinName',"2",...
                'signalName',"IO#",...
                'modelName',component.IOModelName);
                component.SetModelTypesVisiblity
            else
                component.Pins(1)=serdes.internal.ibisami.ibis.IBISPin('pinName',"1",...
                'signalName',"Tx",...
                'modelName',component.TxModelName);
                component.Pins(2)=serdes.internal.ibisami.ibis.IBISPin('pinName',"2",...
                'signalName',"Tx#",...
                'modelName',component.TxModelName);
            end
        end
        function SetModelTypesVisiblity(component)
            if component.isIO
                component.Pins(1).Hidden=false;
                component.Pins(2).Hidden=~component.Differential;
                component.Pins(3).Hidden=true;
                component.Pins(4).Hidden=true;
                if~isempty(component.DiffPins)
                    component.DiffPins(1).Hidden=false;
                    component.DiffPins(2).Hidden=true;
                end
            else
                switch component.ModelTypes
                case "Tx only"
                    component.Pins(1).Hidden=false;
                    component.Pins(2).Hidden=~component.Differential;
                    component.Pins(3).Hidden=true;
                    component.Pins(4).Hidden=true;
                    if~isempty(component.DiffPins)
                        component.DiffPins(1).Hidden=false;
                        component.DiffPins(2).Hidden=true;
                    end
                case "Rx only"
                    component.Pins(1).Hidden=true;
                    component.Pins(2).Hidden=true;
                    component.Pins(3).Hidden=false;
                    component.Pins(4).Hidden=~component.Differential;
                    if~isempty(component.DiffPins)
                        component.DiffPins(1).Hidden=true;
                        component.DiffPins(2).Hidden=false;
                    end
                otherwise
                    component.Pins(1).Hidden=false;
                    component.Pins(2).Hidden=~component.Differential;
                    component.Pins(3).Hidden=false;
                    component.Pins(4).Hidden=~component.Differential;
                    if~isempty(component.DiffPins)
                        component.DiffPins(1).Hidden=false;
                        component.DiffPins(2).Hidden=false;
                    end
                end
            end
        end
    end
end

