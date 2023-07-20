classdef Autocorrelator<matlab.system.SFunSystem






















































%#function mdspacf2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)








        MaximumLagSource='Auto';





        MaximumLag=1;









        Scaling='None';




        Method='Time Domain';







        RoundingMethod='Floor';





        OverflowAction='Wrap';







        ProductDataType='Full precision';








        CustomProductDataType=numerictype([],32,30);







        AccumulatorDataType='Full precision';








        CustomAccumulatorDataType=numerictype([],32,30);







        OutputDataType='Same as accumulator';








        CustomOutputDataType=numerictype([],16,15);













        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Constant,Hidden)
        MaximumLagSourceSet=matlab.system.StringSet({'Auto','Property'});
        ScalingSet=matlab.system.StringSet({...
        'None','Biased',...
        'Unbiased','Unity at zero-lag'});
        MethodSet=matlab.system.StringSet({...
        'Time Domain','Frequency Domain'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumProd');
    end

    methods

        function obj=Autocorrelator(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:Autocorrelator_NotSupported');
            obj@matlab.system.SFunSystem('mdspacf2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomOutputDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            MaximumLagSourceIdx=...
            getIndex(obj.MaximumLagSourceSet,obj.MaximumLagSource);
            ScalingIdx=getIndex(obj.ScalingSet,obj.Scaling);
            MethodIdx=getIndex(obj.MethodSet,obj.Method);
            MaximumLagSourceIdx=double(~(MaximumLagSourceIdx-1));

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                MaximumLagSourceIdx,...
                obj.MaximumLag,...
                ScalingIdx,...
                MethodIdx,...
                [],[],...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                3,...
1...
                });
            elseif strcmp(obj.Method,'Frequency Domain')||obj.FullPrecisionOverride
                obj.compSetParameters({...
                MaximumLagSourceIdx,...
                obj.MaximumLag,...
                ScalingIdx,...
                MethodIdx,...
                [],[],...
                5,...
                2,...
                2,...
                5,...
                2,...
                2,...
                4,...
                2,...
                2,...
                3,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(...
                obj,{'Product','Accumulator','Output'});

                obj.compSetParameters({...
                MaximumLagSourceIdx,...
                obj.MaximumLag,...
                ScalingIdx,...
                MethodIdx,...
                [],[],...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'MaximumLag'
                if~strcmp(obj.MaximumLagSource,'Property')
                    flag=true;
                end
            case 'FullPrecisionOverride'
                if strcmp(obj.Method,'Frequency Domain')
                    flag=true;
                end
            case{'RoundingMethod','OverflowAction'}
                if strcmp(obj.Method,'Frequency Domain')||...
                    obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision'))
                    flag=true;
                end
            case{'ProductDataType','AccumulatorDataType','OutputDataType'}
                if strcmp(obj.Method,'Frequency Domain')||...
                    obj.FullPrecisionOverride
                    flag=true;
                end
            case 'CustomProductDataType'
                if strcmp(obj.Method,'Frequency Domain')||...
                    obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if strcmp(obj.Method,'Frequency Domain')||...
                    obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    flag=true;
                end
            case 'CustomOutputDataType'
                if strcmp(obj.Method,'Frequency Domain')||...
                    obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as accumulator')&&...
                    strcmpi(obj.ProductDataType,'Full precision')&&...
                    strcmpi(obj.AccumulatorDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.Autocorrelator',...
            dsp.Autocorrelator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspstat3/Autocorrelation';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'MaximumLagSource',...
            'MaximumLag',...
            'Scaling',...
            'Method'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'RoundingMethod','OverflowAction',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end
