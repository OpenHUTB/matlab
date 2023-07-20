classdef ArrayVectorAdder<matlab.system.SFunSystem























































%#function mdspdmult2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties




        Vector=[0.5,0.25];
    end

    properties(Nontunable)




        Dimension=1;



        VectorSource='Input port';






        RoundingMethod='Floor';




        OverflowAction='Wrap';






        VectorDataType='Same word length as input';







        CustomVectorDataType=numerictype([],16,15);






        AccumulatorDataType='Full precision';








        CustomAccumulatorDataType=numerictype([],32,30);






        OutputDataType='Same as accumulator';








        CustomOutputDataType=numerictype([],16,15);













        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Constant,Hidden)
        VectorSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        VectorDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritFirst');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumFirst');
    end

    methods

        function obj=ArrayVectorAdder(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:ArrayVectorAdder_NotSupported');
            obj@matlab.system.SFunSystem('mdspdmult2');
            setProperties(obj,nargin,varargin{:});
        end

        function set.CustomVectorDataType(obj,val)
            validateCustomDataType(obj,'CustomVectorDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomVectorDataType=val;
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

            VectorOptionIdx=getIndex(...
            obj.VectorSourceSet,obj.VectorSource);
            VectorOptionIdx=3-VectorOptionIdx;

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                3,...
                obj.Dimension,...
                VectorOptionIdx,...
                obj.Vector,...
                [],[],...
                [],[],...
                2,...
                2,...
                2,...
                5,...
                0,...
                0,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                3,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Vector','Accumulator','Output'});

                if obj.FullPrecisionOverride
                    obj.compSetParameters({...
                    3,...
                    obj.Dimension,...
                    VectorOptionIdx,...
                    obj.Vector,...
                    [],[],...
                    [],[],...
                    dtInfo.VectorDataType,...
                    dtInfo.VectorWordLength,...
                    dtInfo.VectorFracLength,...
                    5,...
                    0,...
                    0,...
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
                    obj.compSetParameters({...
                    3,...
                    obj.Dimension,...
                    VectorOptionIdx,...
                    obj.Vector,...
                    [],[],...
                    [],[],...
                    dtInfo.VectorDataType,...
                    dtInfo.VectorWordLength,...
                    dtInfo.VectorFracLength,...
                    5,...
                    0,...
                    0,...
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

        function y=supportsUnboundedIO(~)
            y=true;
        end

    end

    methods(Access=protected)


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'CustomVectorDataType'
                if(strcmp(obj.VectorSource,'Property')&&...
                    ~matlab.system.isSpecifiedTypeMode(obj.VectorDataType))||...
                    ~strcmp(obj.VectorSource,'Property')
                    flag=true;
                end
            case{'Vector','VectorDataType'}
                if~strcmp(obj.VectorSource,'Property')
                    flag=true;
                end
            case{'RoundingMethod','OverflowAction'}
                if obj.FullPrecisionOverride||...
                    (strcmpi(obj.AccumulatorDataType,'Full precision')&&...
                    strcmpi(obj.OutputDataType,'Same as accumulator'))



                    flag=true;
                end
            case{'AccumulatorDataType','OutputDataType'}
                if obj.FullPrecisionOverride
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if obj.FullPrecisionOverride||...
                    (strcmpi(obj.AccumulatorDataType,'Full precision')&&...
                    strcmpi(obj.OutputDataType,'Same as accumulator'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)




                    flag=true;
                end
            case 'CustomOutputDataType'
                if obj.FullPrecisionOverride||...
                    (strcmpi(obj.AccumulatorDataType,'Full precision')&&...
                    strcmpi(obj.OutputDataType,'Same as accumulator'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)




                    flag=true;
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.ArrayVectorAdder',...
            dsp.ArrayVectorAdder.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspmtrx3/Array-Vector Add';
        end


        function props=getDisplayPropertiesImpl()
            props={...
'Dimension'...
            ,'VectorSource'...
            ,'Vector'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'RoundingMethod','OverflowAction'...
            ,'VectorDataType','CustomVectorDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'OutputDataType','CustomOutputDataType'...
            };
        end




        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Vector=3;
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
