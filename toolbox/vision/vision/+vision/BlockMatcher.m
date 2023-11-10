classdef(StrictDefaults)BlockMatcher<matlab.System

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)

        ReferenceFrameSource='Property';

        ReferenceFrameDelay=1;

        SearchMethod='Exhaustive';

        BlockSize=[17,17];

        Overlap=[0,0];

        MaximumDisplacement=[7,7];

        MatchCriteria='Mean square error (MSE)';

        OutputValue='Magnitude-squared';

        RoundingMethod='Floor';

        OverflowAction='Saturate';

        ProductDataType='Custom';
        CustomProductDataType=numerictype([],32,0);

        AccumulatorDataType='Custom';
        CustomAccumulatorDataType=numerictype([],32,0);


        OutputDataType='Custom';
        CustomOutputDataType=numerictype([],8);
    end

    properties(Access=private,Nontunable)

cBlockMatch
        pMotionBetweenFrames;
    end

    properties(Access=private)
        pDelayBuffer;
        pMostRecentDFrameIdx;
    end

    properties(Constant,Hidden)

        ReferenceFrameSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        SearchMethodSet=matlab.system.StringSet({...
        'Exhaustive','Three-step'});
        MatchCriteriaSet=matlab.system.StringSet({...
        'Mean square error (MSE)',...
        'Mean absolute difference (MAD)'});
        OutputValueSet=matlab.system.StringSet({...
        'Magnitude-squared',...
        'Horizontal and vertical components in complex form'});


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeScaledOnly');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeUnscaledOnly');
    end

    methods
        function obj=BlockMatcher(varargin)
            setProperties(obj,nargin,varargin{:});
        end


        function set.ReferenceFrameDelay(obj,val)
            validateattributes(val,{'numeric'},{'scalar','integer','>=',0},'','ReferenceFrameDelay');
            obj.ReferenceFrameDelay=val;
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
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomOutputDataType=val;
        end
    end

    methods(Access=protected)
        function out=stepImpl(obj,in,varargin)
            if obj.pMotionBetweenFrames

                oldestFrameIdx=getOldestFrameIdx(obj);
                delayedIn=obj.pDelayBuffer(:,:,oldestFrameIdx);
                out=step(obj.cBlockMatch,in,delayedIn);
                updateDelayBuffer(obj,in);
            else
                out=step(obj.cBlockMatch,in,varargin{1});
            end
        end

        function validateInputsImpl(obj,in,varargin)

            if~ismatrix(in)||isempty(in)
                matlab.system.internal.error(...
                'MATLAB:system:inputMustBeMatrix','I');
            end
            if strcmp(obj.ReferenceFrameSourceSet,'Input port')
                inref=varargin{1};
                coder.internal.errorIf(~(isequal(size(in),size(inref))&&strcmp(class(in),class(inref))),...
                'vision:dims:inputsMismatch');
            end
        end

        function setupImpl(obj,in,varargin)

            propval=get(obj);
            removeprops={'Description','ReferenceFrameSource','ReferenceFrameDelay'};
            for ii=1:length(removeprops)
                if isfield(propval,removeprops{ii})
                    propval=rmfield(propval,removeprops{ii});
                end
            end

            obj.pMotionBetweenFrames=strcmp(obj.ReferenceFrameSource,...
            'Property');

            obj.cBlockMatch=vision.private.BlockMatch;
            set(obj.cBlockMatch,propval);


            if obj.pMotionBetweenFrames
                setupDelayBuffer(obj,in);
            end
        end




        function resetImpl(obj)

            reset(obj.cBlockMatch);
            if obj.pMotionBetweenFrames
                resetDelayBuffer(obj);
            end
        end

        function num=getNumInputsImpl(obj)
            if strcmp(obj.ReferenceFrameSource,'Input port')
                num=2;
            else
                num=1;
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~strcmp(obj.ReferenceFrameSource,'Property');
                props{end+1}='ReferenceFrameDelay';
            end
            if~strcmp(obj.MatchCriteria,'Mean square error (MSE)')
                props=[props,{'ProductDataType','CustomProductDataType'}];
            else
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    props{end+1}='CustomProductDataType';
                end
            end
            flag=ismember(prop,props);
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            if obj.isLocked
                s.pMotionBetweenFrames=obj.pMotionBetweenFrames;
                s.pDelayBuffer=obj.pDelayBuffer;
                s.pMostRecentDFrameIdx=obj.pMostRecentDFrameIdx;
                s.cBlockMatch=matlab.System.saveObject(obj.cBlockMatch);
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.System(obj,s);
            if wasLocked
                obj.pMotionBetweenFrames=s.pMotionBetweenFrames;
                obj.pDelayBuffer=s.pDelayBuffer;
                obj.pMostRecentDFrameIdx=s.pMostRecentDFrameIdx;
                obj.cBlockMatch=matlab.System.loadObject(s.cBlockMatch);
            end
        end

    end

    methods(Static)
        function helpFixedPoint





            matlab.system.dispFixptHelp('vision.BlockMatcher',...
            vision.BlockMatcher.getDisplayFixedPointProperties);
        end
    end

    methods(Static,Hidden)

        function props=getDisplayFixedPointProperties()
            props={...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType',...
            'RoundingMethod','OverflowAction'};
        end

    end

    methods(Static,Hidden,Access=protected)
        function groups=getPropertyGroupsImpl
            props={'ReferenceFrameSource',...
            'ReferenceFrameDelay',...
            'SearchMethod',...
            'BlockSize',...
            'Overlap',...
            'MaximumDisplacement',...
            'MatchCriteria',...
            'OutputValue'};
            mainS=matlab.system.display.Section('Title','Parameters',...
            'PropertyList',props);
            mainSG=matlab.system.display.SectionGroup('TitleSource','Auto',...
            'Sections',mainS);
            dt=matlab.system.display.SectionGroup('Title','Data Types',...
            'PropertyList',...
            vision.BlockMatcher.getDisplayFixedPointProperties);
            groups=[mainSG,dt];
        end
    end


    methods(Access=private)
        function setupDelayBuffer(obj,in)
            inSize=size(in);

            numFrames=obj.ReferenceFrameDelay;
            if isa(in,'embedded.fi')
                fixptDataType=in.numerictype;
                obj.pDelayBuffer=fi(zeros([inSize,numFrames]),fixptDataType);
            elseif isa(in,'logical')
                obj.pDelayBuffer=false([inSize,numFrames]);
            else
                obj.pDelayBuffer=zeros([inSize,numFrames],class(in));
            end
            obj.pMostRecentDFrameIdx=uint32(1);
        end

        function resetDelayBuffer(obj)
            obj.pDelayBuffer(:)=0;
            obj.pMostRecentDFrameIdx(:)=1;
        end

        function updateDelayBuffer(obj,in)
            oldestFrameIdx=getOldestFrameIdx(obj);
            obj.pDelayBuffer(:,:,oldestFrameIdx)=in;
            obj.pMostRecentDFrameIdx(:)=oldestFrameIdx;
        end

        function idx=getOldestFrameIdx(obj)
            idx=obj.pMostRecentDFrameIdx-1;
            if(idx<1)
                idx=obj.ReferenceFrameDelay;
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionanalysis/Block Matching';
        end
    end
end


