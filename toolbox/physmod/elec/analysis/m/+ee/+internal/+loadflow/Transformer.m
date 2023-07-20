classdef Transformer<ee.internal.loadflow.Block




    properties
        BlockType=getString(message('physmod:ee:loadflow:Transformer'));
        ComponentPath='ee.passive.transformers.two_winding_transformer.abc';
        Name='';
    end

    properties(Dependent)
FromBusbar
P12
P21
Q12
Q21
RatedVoltage
ReactivePowerLoss
RealPowerLoss
ToBusbar
VoltageAngle12
V1
V2
WindingAngle12
    end

    methods
        function obj=Transformer(varargin)



            obj=obj@ee.internal.loadflow.Block(varargin{:});
        end

        function value=get.FromBusbar(obj)
            value=obj.getAttachedBusbarValue('LConn1','Name');
        end

        function value=get.P12(obj)
            value=-1*obj.getAttachedBusbarValue('LConn1','RealPower');
        end

        function value=get.P21(obj)
            value=-1*obj.getAttachedBusbarValue('RConn1','RealPower');
        end

        function value=get.Q12(obj)
            value=-1*obj.getAttachedBusbarValue('LConn1','ReactivePower');
        end

        function value=get.Q21(obj)
            value=-1*obj.getAttachedBusbarValue('RConn1','ReactivePower');
        end

        function value=get.RatedVoltage(obj)
            vRated1=obj.getValue('VRated1','kV');
            vRated2=obj.getValue('VRated2','kV');
            value=sprintf('%g/%g',vRated1,vRated2);
        end

        function value=get.ReactivePowerLoss(obj)
            value=obj.Q12+obj.Q21;
        end

        function value=get.RealPowerLoss(obj)
            value=abs(obj.P12+obj.P21);
        end

        function value=get.ToBusbar(obj)
            value=obj.getAttachedBusbarValue('RConn1','Name');
        end

        function value=get.VoltageAngle12(obj)

            angle1=obj.getAttachedBusbarValue('LConn1','VoltageAngle');
            angle2=obj.getAttachedBusbarValue('RConn1','VoltageAngle');



            value=angle2-angle1;
        end

        function value=get.V1(obj)
            value=obj.getAttachedBusbarValue('LConn1','VoltageMagnitude');
        end

        function value=get.V2(obj)
            value=obj.getAttachedBusbarValue('RConn1','VoltageMagnitude');
        end

        function value=get.WindingAngle12(obj)
            windingConnection=get_param(obj.Name,'Winding1Connection');
            switch windingConnection
            case{'ee.enum.windingconnection.Y',...
                'ee.enum.windingconnection.Yn',...
                'ee.enum.windingconnection.Yg'}
                offset1=0;
            case 'ee.enum.windingconnection.delta1'
                offset1=30;
            case 'ee.enum.windingconnection.delta11'
                offset1=-30;
            otherwise
            end
            windingConnection=get_param(obj.Name,'Winding2Connection');
            switch windingConnection
            case{'ee.enum.windingconnection.Y',...
                'ee.enum.windingconnection.Yn',...
                'ee.enum.windingconnection.Yg'}
                offset2=0;
            case 'ee.enum.windingconnection.delta1'
                offset2=-30;
            case 'ee.enum.windingconnection.delta11'
                offset2=30;
            otherwise
            end
            value=offset1+offset2;
        end

        function value=table(obj)
            tabledata={...
            'Block Type',obj.BlockType;...
            'From Busbar',obj.FromBusbar;...
            'To Busbar',obj.ToBusbar;...
            'Rated Voltage, kV',obj.RatedVoltage;...
            'Voltage V1, pu',obj.V1;...
            'Voltage V2, pu',obj.V2;...
            'Voltage Angle12, deg',obj.VoltageAngle12;...
            'Real Power Flow P12, MW',obj.P12;...
            'Reactive Power Flow Q12, Mvar',obj.Q12;...
            'Real Power Flow P21, MW',obj.P21;...
            'Reactive Power Flow Q21, Mvar',obj.Q21;...
            'Real Power Loss, MW',obj.RealPowerLoss;...
            'Reactive power Loss, Mvar',obj.ReactivePowerLoss;...
            };
            value=cell2table(tabledata(:,2:end)',...
            'RowNames',{obj.Name},...
            'VariableNames',tabledata(:,1)');
        end
    end
end
