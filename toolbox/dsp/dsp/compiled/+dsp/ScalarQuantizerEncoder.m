classdef ScalarQuantizerEncoder<matlab.system.SFunSystem
























































































%#function mdspsqenc

%#ok<*EMCLS>
%#ok<*EMCA>

    properties











        Codebook=1.5:9.5;
    end

    properties(Nontunable)



        BoundaryPointsSource='Property';



        Partitioning='Bounded';







        SearchMethod='Linear';





        TiebreakerRule='Choose the lower index';




        OutputIndexDataType='int32';







        RoundingMethod='Floor';



        OverflowAction='Wrap';





        CodewordOutputPort(1,1)logical=false;





        QuantizationErrorOutputPort(1,1)logical=false;







        ClippingStatusOutputPort(1,1)logical=false;
    end

    properties(Dependent)










        BoundaryPoints=1:10;%#ok<MDEPIN>
    end

    properties(Constant,Hidden)
        BoundaryPointsSourceSet=dsp.CommonSets.getSet(...
        'PropertyOrInputPort');
        PartitioningSet=matlab.system.StringSet({'Bounded','Unbounded'});
        SearchMethodSet=matlab.system.StringSet({'Linear','Binary'});
        TiebreakerRuleSet=matlab.system.StringSet({...
        'Choose the lower index','Choose the higher index'});
        OutputIndexDataTypeSet=matlab.system.StringSet({...
        'int8','uint8','int16','uint16','int32','uint32'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
    end

    properties(Access=protected)
        pBoundaryPointsBounded=1:10;
        pBoundaryPointsUnbounded=2:9;
    end

    methods

        function obj=ScalarQuantizerEncoder(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:ScalarQuantizerEncoder_NotSupported');
            obj@matlab.system.SFunSystem('mdspsqenc');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function value=get.BoundaryPoints(obj)
            if strcmp(obj.Partitioning,'Bounded')
                value=obj.pBoundaryPointsBounded;
            else
                value=obj.pBoundaryPointsUnbounded;
            end
        end

        function set.BoundaryPoints(obj,value)
            if strcmp(obj.Partitioning,'Bounded')
                obj.pBoundaryPointsBounded=value;
            else
                obj.pBoundaryPointsUnbounded=value;
            end
        end
    end

    methods(Hidden)
        function setParameters(obj)

            BoundaryPointsSourceIdx=getIndex(...
            obj.BoundaryPointsSourceSet,obj.BoundaryPointsSource);
            PartitioningIdx=getIndex(...
            obj.PartitioningSet,obj.Partitioning);
            SearchMethodIdx=getIndex(...
            obj.SearchMethodSet,obj.SearchMethod);
            TiebreakerRuleIdx=getIndex(...
            obj.TiebreakerRuleSet,obj.TiebreakerRule);
            OutOfRangeInputActionIdx=1;
            OutputIndexDataTypeIdx=getIndex(...
            obj.OutputIndexDataTypeSet,obj.OutputIndexDataType);

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                BoundaryPointsSourceIdx,...
                PartitioningIdx,...
                obj.BoundaryPoints,...
                obj.BoundaryPoints,...
                SearchMethodIdx,...
                TiebreakerRuleIdx,...
                double(obj.CodewordOutputPort),...
                double(obj.QuantizationErrorOutputPort),...
                obj.Codebook,...
                double(obj.ClippingStatusOutputPort),...
                OutOfRangeInputActionIdx,...
                1,...
                OutputIndexDataTypeIdx,...
                2,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,{});

                obj.compSetParameters({...
                BoundaryPointsSourceIdx,...
                PartitioningIdx,...
                obj.BoundaryPoints,...
                obj.BoundaryPoints,...
                SearchMethodIdx,...
                TiebreakerRuleIdx,...
                double(obj.CodewordOutputPort),...
                double(obj.QuantizationErrorOutputPort),...
                obj.Codebook,...
                double(obj.ClippingStatusOutputPort),...
                OutOfRangeInputActionIdx,...
                1,...
                OutputIndexDataTypeIdx,...
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
            case 'ClippingStatusOutputPort'
                if strcmp(obj.Partitioning,'Unbounded')
                    flag=true;
                end
            case 'BoundaryPoints'
                if strcmp(obj.BoundaryPointsSource,'Input port')
                    flag=true;
                end
            case 'Codebook'
                if strcmp(obj.BoundaryPointsSource,'Input port')||...
                    ~(obj.QuantizationErrorOutputPort||obj.CodewordOutputPort)
                    flag=true;
                end
            end
        end
        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);
            s.BoundaryPoints=obj.BoundaryPoints;
        end
        function obj=loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.SFunSystem(obj,s,wasLocked);
            obj.BoundaryPoints=s.BoundaryPoints;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.ScalarQuantizerEncoder',dsp.ScalarQuantizerEncoder.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspquant2/Scalar Quantizer Encoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'BoundaryPointsSource'...
            ,'Partitioning'...
            ,'BoundaryPoints'...
            ,'SearchMethod'...
            ,'TiebreakerRule'...
            ,'CodewordOutputPort'...
            ,'QuantizationErrorOutputPort'...
            ,'Codebook'...
            ,'ClippingStatusOutputPort'...
            ,'OutputIndexDataType'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod','OverflowAction'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Codebook=8;
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
