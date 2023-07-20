classdef DCT<matlab.system.SFunSystem





%#function mdspdct3

%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        SineComputation='Table lookup';








        RoundingMethod='Floor';




        OverflowAction='Wrap';




        SineTableDataType='Same word length as input';








        CustomSineTableDataType=numerictype([],16);




        ProductDataType='Full precision';








        CustomProductDataType=numerictype([],32,30);





        AccumulatorDataType='Full precision';








        CustomAccumulatorDataType=numerictype([],32,30);




        OutputDataType='Full precision';








        CustomOutputDataType=numerictype([],16,15);
    end

    properties(Constant,Hidden)
        SineComputationSet=dsp.CommonSets.getSet('SineComputation');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        SineTableDataTypeSet=dsp.CommonSets.getSet('FixptModeUnscaled');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
    end

    properties(Access=protected,Nontunable)
        pIsInverseDCT=false;
        pDimension=1;
    end

    methods
        function obj=DCT(varargin)
            obj@matlab.system.SFunSystem('mdspdct3');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomSineTableDataType(obj,val)
            validateCustomDataType(obj,'CustomSineTableDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomSineTableDataType=val;
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
            CompSineComputation=strcmp(obj.SineComputation,'Table lookup')+1;
            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                double(obj.pIsInverseDCT),...
                CompSineComputation,...
                obj.pDimension,...
                1,...
                0,...
                0,...
                0,...
                1,...
                [],...
                [],...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'SineTable','Product','Accumulator','Output'});
                obj.compSetParameters({...
                double(obj.pIsInverseDCT),...
                CompSineComputation,...
                obj.pDimension,...
                1,...
                0,...
                0,...
                0,...
                1,...
                [],...
                [],...
                dtInfo.SineTableDataType,...
                dtInfo.SineTableWordLength,...
                dtInfo.SineTableFracLength,...
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
            case{'RoundingMethod','OverflowAction',...
                'SineTableDataType','ProductDataType',...
                'AccumulatorDataType','OutputDataType'}
                if strcmp(obj.SineComputation,'Trigonometric function')
                    flag=true;
                end
            case 'CustomSineTableDataType'
                if strcmp(obj.SineComputation,'Trigonometric function')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.SineTableDataType)
                    flag=true;
                end
            case 'CustomProductDataType'
                if strcmp(obj.SineComputation,'Trigonometric function')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if strcmp(obj.SineComputation,'Trigonometric function')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    flag=true;
                end
            case 'CustomOutputDataType'
                if strcmp(obj.SineComputation,'Trigonometric function')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint





            matlab.system.dispFixptHelp('dsp.DCT',dsp.DCT.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function desc=getDescriptionImpl
            desc='Discrete Cosine Transform';
        end
        function props=getDisplayPropertiesImpl()
            props={'SineComputation'};
        end

        function a=getAlternateBlock
            a='dspxfrm3/DCT';
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod','OverflowAction',...
            'SineTableDataType','CustomSineTableDataType',...
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
