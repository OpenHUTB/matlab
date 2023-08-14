classdef VectorQuantizerEncoder<matlab.system.SFunSystem





















































































%#function mdspvqenc

%#ok<*EMCLS>
%#ok<*EMCA>

    properties













        Codebook=[1.5,13.3,136.4,6.8;...
        2.5,14.3,137.4,7.8;...
        3.5,15.3,138.4,8.8];






        Weights=[1,1,1];
    end

    properties(Nontunable)



        CodebookSource='Property';









        DistortionMeasure='Squared error';





        WeightsSource='Property';







        TiebreakerRule='Choose the lower index';




        OutputIndexDataType='int32';







        RoundingMethod='Floor';



        OverflowAction='Wrap';



        ProductDataType='Same as input';






        CustomProductDataType=numerictype([],16,15);




        AccumulatorDataType='Same as product';






        CustomAccumulatorDataType=numerictype([],16,15);





        CodewordOutputPort(1,1)logical=false;





        QuantizationErrorOutputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        CodebookSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        DistortionMeasureSet=matlab.system.StringSet({...
        'Squared error',...
        'Weighted squared error'});
        WeightsSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        TiebreakerRuleSet=matlab.system.StringSet({...
        'Choose the lower index',...
        'Choose the higher index'});
        OutputIndexDataTypeSet=matlab.system.StringSet({...
        'int8','uint8','int16','uint16','int32','uint32'});


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
    end

    methods

        function obj=VectorQuantizerEncoder(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:VectorQuantizerEncoder_NotSupported');
            obj@matlab.system.SFunSystem('mdspvqenc');
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
    end

    methods(Hidden)
        function setParameters(obj)

            CBsource=getIndex(...
            obj.CodebookSourceSet,obj.CodebookSource);
            DistMeasure=getIndex(...
            obj.DistortionMeasureSet,obj.DistortionMeasure);
            WgtSrc=getIndex(...
            obj.WeightsSourceSet,obj.WeightsSource);
            TiebreakerRuleIdx=getIndex(...
            obj.TiebreakerRuleSet,obj.TiebreakerRule);
            Idtype=getIndex(...
            obj.OutputIndexDataTypeSet,obj.OutputIndexDataType);

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                CBsource,...
                obj.Codebook,...
                DistMeasure,...
                WgtSrc,...
                obj.Weights,...
                Idtype,...
                TiebreakerRuleIdx,...
                double(obj.CodewordOutputPort),...
                double(obj.QuantizationErrorOutputPort),...
                1,...
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
                dtInfo=getFixptDataTypeInfo(obj,{'Product','Accumulator'});

                obj.compSetParameters({...
                CBsource,...
                obj.Codebook,...
                DistMeasure,...
                WgtSrc,...
                obj.Weights,...
                Idtype,...
                TiebreakerRuleIdx,...
                double(obj.CodewordOutputPort),...
                double(obj.QuantizationErrorOutputPort),...
                1,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
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
            case 'Codebook'
                if~strcmp(obj.CodebookSource,'Property')
                    flag=true;
                end
            case 'Weights'
                if~strcmp(obj.WeightsSource,'Property')||...
                    ~strcmp(obj.DistortionMeasure,'Weighted squared error')
                    flag=true;
                end
            case 'WeightsSource'
                if~strcmp(obj.DistortionMeasure,'Weighted squared error')
                    flag=true;
                end
            case 'CustomProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    flag=true;
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.VectorQuantizerEncoder',dsp.VectorQuantizerEncoder.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspquant2/Vector Quantizer Encoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'CodebookSource'...
            ,'Codebook'...
            ,'DistortionMeasure'...
            ,'WeightsSource'...
            ,'Weights'...
            ,'TiebreakerRule'...
            ,'CodewordOutputPort'...
            ,'QuantizationErrorOutputPort'...
            ,'OutputIndexDataType'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            };
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Codebook=1;
            tunePropsMap.Weights=4;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
    methods(Access=protected)
        function setPortDataTypeConnections(obj)


            portNum=2;
            if(obj.CodewordOutputPort)
                setPortDataTypeConnection(obj,1,portNum);
                portNum=portNum+1;
            end
            if(obj.QuantizationErrorOutputPort)
                setPortDataTypeConnection(obj,1,portNum);
            end
        end
    end
end
