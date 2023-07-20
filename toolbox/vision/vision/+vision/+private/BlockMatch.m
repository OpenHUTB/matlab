classdef(Hidden)BlockMatch<matlab.system.SFunSystem





%#function mvipblockmatch

    properties(Nontunable)
        ReferenceFrameSource='Input port';
        SearchMethod='Exhaustive';
        BlockSize=[17,17];
        Overlap=[0,0];
        MaximumDisplacement=[7,7];
        MatchCriteria='Mean square error (MSE)';
        OutputValue='Magnitude-squared';
        RoundingMethod='Floor';
        OverflowAction='Wrap';
        ProductDataType='Custom';
        CustomProductDataType=numerictype(1,32,0);
        AccumulatorDataType='Custom';
        CustomAccumulatorDataType=numerictype(1,32,0);
        OutputDataType='Custom';
        CustomOutputDataType=numerictype(1,8);
    end

    properties(Constant,Hidden)
        ReferenceFrameSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        SearchMethodSet=matlab.system.StringSet({'Exhaustive','Three-step'});
        MatchCriteriaSet=matlab.system.StringSet({...
        'Mean square error (MSE)',...
        'Mean absolute difference (MAD)'});
        OutputValueSet=matlab.system.StringSet({...
        'Horizontal and vertical components in complex form',...
        'Magnitude-squared'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowMode');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeScaledOnly');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeUnscaledOnly');
    end

    methods

        function obj=BlockMatch(varargin)
            obj@matlab.system.SFunSystem('mvipblockmatch');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)


            SearchMethodIdx=getIndex(...
            obj.SearchMethodSet,obj.SearchMethod);
            MatchCriteriaIdx=getIndex(...
            obj.MatchCriteriaSet,obj.MatchCriteria);
            OutputValueIdx=getIndex(...
            obj.OutputValueSet,obj.OutputValue);

            dtInfo=getFixptDataTypeInfo(obj,...
            {'Product','Accumulator','Output'});
            dtInfo.OutputDataType=0;
            dtInfo.OutputFracLength=0;
            obj.compSetParameters({...
            SearchMethodIdx,...
            obj.BlockSize,...
            obj.Overlap,...
            obj.MaximumDisplacement,...
            MatchCriteriaIdx,...
            OutputValueIdx,...
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

    methods(Static,Hidden)
        function b=generatesCode
            b=false;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end
