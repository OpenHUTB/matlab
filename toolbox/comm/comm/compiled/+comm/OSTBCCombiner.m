classdef OSTBCCombiner<matlab.system.SFunSystem































































































































%#function mcomostbccomb

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        NumTransmitAntennas=2;





        SymbolRate=3/4;



        NumReceiveAntennas=1;







        RoundingMethod='Floor';





        OverflowAction='Wrap';



        ProductDataType='Full precision';







        CustomProductDataType=numerictype([],32,16);



        AccumulatorDataType='Full precision';







        CustomAccumulatorDataType=numerictype([],32,16);





        EnergyProductDataType='Full precision';







        CustomEnergyProductDataType=numerictype([],32,16);






        EnergyAccumulatorDataType='Full precision';








        CustomEnergyAccumulatorDataType=numerictype([],32,16);





        DivisionDataType='Same as accumulator';







        CustomDivisionDataType=numerictype([],32,16);
    end

    properties(Constant,Hidden)
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=matlab.system.internal.StringSetGF({'Full precision',...
        'Custom'},{'Internal rule'},{'Full precision'});
        AccumulatorDataTypeSet=matlab.system.internal.StringSetGF({'Full precision',...
        'Same as product','Custom'},{'Internal rule'},{'Full precision'});
        EnergyProductDataTypeSet=matlab.system.internal.StringSetGF({'Full precision',...
        'Same as product','Custom'},{'Internal rule'},{'Full precision'});
        EnergyAccumulatorDataTypeSet=matlab.system.internal.StringSetGF({'Full precision',...
        'Same as energy product','Same as accumulator','Custom'},...
        {'Internal rule'},{'Full precision'});
        DivisionDataTypeSet=matlab.system.StringSet({'Same as accumulator',...
        'Custom'});
    end

    methods

        function obj=OSTBCCombiner(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomostbccomb');
            setProperties(obj,nargin,varargin{:},'NumTransmitAntennas','NumReceiveAntennas');
            setVarSizeAllowedStatus(obj,true);
            setForceInputRealToComplex(obj,1,true);
            setForceInputRealToComplex(obj,2,true);
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'SCALED','AUTOSIGNED'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomDivisionDataType(obj,val)
            validateCustomDataType(obj,'CustomDivisionDataType',val,...
            {'SCALED','AUTOSIGNED'});
            obj.CustomDivisionDataType=val;
        end

        function set.CustomEnergyAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomEnergyAccumulatorDataType',val,...
            {'SCALED','AUTOSIGNED'});
            obj.CustomEnergyAccumulatorDataType=val;
        end

        function set.CustomEnergyProductDataType(obj,val)
            validateCustomDataType(obj,'CustomEnergyProductDataType',val,...
            {'SCALED','AUTOSIGNED'});
            obj.CustomEnergyProductDataType=val;
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'SCALED','AUTOSIGNED'});
            obj.CustomProductDataType=val;
        end


        function set.NumTransmitAntennas(obj,value)
            validateattributes(value,{'numeric'},{'>=',2,'<=',4,'scalar','integer'},'','NumTransmitAntennas');
            obj.NumTransmitAntennas=value;
        end

        function set.SymbolRate(obj,value)
            validateattributes(value,{'numeric'},{'scalar'},'','SymbolRate');
            if value~=3/4&&value~=1/2
                coder.internal.errorIf(true,'comm:system:OSTBCCombiner:invalidSymbolRate');
            else
                obj.SymbolRate=value;
            end
        end

        function set.NumReceiveAntennas(obj,value)
            validateattributes(value,{'double'},{'>=',1,'<=',8,'scalar','integer'},'','NumReceiveAntennas');
            obj.NumReceiveAntennas=value;
        end
    end

    methods(Hidden)
        function setParameters(obj)



            NumTransmitAntennasIdx=obj.NumTransmitAntennas-1;
            switch(obj.SymbolRate)
            case 3/4
                SymbolRateIdx=1;
            case 1/2
                SymbolRateIdx=2;
            end

            RoundingMethodIdx=getIndex(...
            obj.RoundingMethodSet,obj.RoundingMethod);
            OverflowActionIdx=getIndex(...
            obj.OverflowActionSet,obj.OverflowAction);
            ProductDataTypeIdx=getIndex(...
            obj.ProductDataTypeSet,obj.ProductDataType);
            AccumulatorDataTypeIdx=getIndex(...
            obj.AccumulatorDataTypeSet,obj.AccumulatorDataType);
            EnergyProductDataTypeIdx=getIndex(...
            obj.EnergyProductDataTypeSet,obj.EnergyProductDataType);
            EnergyAccumulatorDataTypeIdx=getIndex(...
            obj.EnergyAccumulatorDataTypeSet,obj.EnergyAccumulatorDataType);
            DivisionDataTypeIdx=getIndex(...
            obj.DivisionDataTypeSet,obj.DivisionDataType);







            obj.compSetParameters({...
            NumTransmitAntennasIdx,...
            SymbolRateIdx,...
            obj.NumReceiveAntennas,...
            RoundingMethodIdx,...
            OverflowActionIdx,...
            ProductDataTypeIdx,...
            obj.CustomProductDataType.WordLength,...
            obj.CustomProductDataType.FractionLength,...
            AccumulatorDataTypeIdx,...
            obj.CustomAccumulatorDataType.WordLength,...
            obj.CustomAccumulatorDataType.FractionLength,...
            EnergyProductDataTypeIdx,...
            obj.CustomEnergyProductDataType.WordLength,...
            obj.CustomEnergyProductDataType.FractionLength,...
            EnergyAccumulatorDataTypeIdx,...
            obj.CustomEnergyAccumulatorDataType.WordLength,...
            obj.CustomEnergyAccumulatorDataType.FractionLength,...
            DivisionDataTypeIdx,...
            obj.CustomDivisionDataType.WordLength,...
            obj.CustomDivisionDataType.FractionLength...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if obj.NumTransmitAntennas==2
                props{end+1}='SymbolRate';
            end


            if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                props{end+1}='CustomProductDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                props{end+1}='CustomAccumulatorDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.EnergyProductDataType)
                props{end+1}='CustomEnergyProductDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.EnergyAccumulatorDataType)
                props{end+1}='CustomEnergyAccumulatorDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.DivisionDataType)
                props{end+1}='CustomDivisionDataType';
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)


            if isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,1);
            end

        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.OSTBCCombiner',...
            comm.OSTBCCombiner.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commmimo/OSTBC Combiner';
        end

        function props=getDisplayPropertiesImpl
            props={...
            'NumTransmitAntennas',...
            'SymbolRate',...
'NumReceiveAntennas'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl
            props={...
            'RoundingMethod','OverflowAction',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'EnergyProductDataType','CustomEnergyProductDataType',...
            'EnergyAccumulatorDataType','CustomEnergyAccumulatorDataType',...
            'DivisionDataType','CustomDivisionDataType'...
            };
        end


        function props=getValueOnlyProperties()
            props={'NumTransmitAntennas','NumReceiveAntennas'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end

