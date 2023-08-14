classdef TappedDelayLine<handle






    properties(Constant)
        Name(1,1)string="TapWeights"
    end
    properties(Access=public)
        MainTapIndex(1,1)uint32=1
        TapWeights(1,:)double{mustBeReal,mustBeFinite,mustBeNonNan,...
        mustBeGreaterThanOrEqual(TapWeights,-2),...
        mustBeLessThanOrEqual(TapWeights,2)...
        }=1
        Usage(1,1)string="In"
    end
    properties(SetAccess=private)


        Taps serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter
    end
    properties(Dependent)
        NumPrecursorTaps uint32
        NumPostcursorTaps uint32
    end
    methods
        function obj=TappedDelayLine(varargin)




            parser=inputParser;
            parser.addParameter('name',"Taps")
            parser.addParameter('mainTapIndex',1)
            parser.addParameter('tapWeights',0)
            parser.addParameter('usage',"In")
            parser.parse(varargin{:})
            args=parser.Results;




            obj.MainTapIndex=args.mainTapIndex;
            obj.TapWeights=args.tapWeights;
            obj.Usage=args.usage;
            obj.createTaps;
        end
    end
    methods

        function set.MainTapIndex(obj,mti)
            obj.MainTapIndex=mti;
            obj.createTaps;
        end
        function set.TapWeights(obj,weights)
            obj.TapWeights=weights;
            obj.createTaps;
        end
        function set.Usage(obj,usage)
            obj.Usage=usage;
            obj.createTaps;
        end
        function nPostT=get.NumPostcursorTaps(obj)
            nPostT=length(obj.TapWeights)-obj.MainTapIndex;
        end
        function nPreT=get.NumPrecursorTaps(obj)
            nPreT=max([obj.MainTapIndex-1,0]);
        end
    end
    methods
        function tap=getTap(obj,tapNum)

            tapIdx=tapNum+obj.MainTapIndex;
            if tapIdx<1||tapIdx>length(obj.Taps)
                error(message('serdes:ibis:TapIndexOutOfRange'))
            end
            tap=obj.Taps(tapIdx);
        end
    end
    methods(Access=private)
        function createTaps(obj)
            numTaps=length(obj.TapWeights);
            obj.Taps(1,numTaps)=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter;
            for weightIdx=1:numTaps
                tapNum=num2str(weightIdx-double(obj.MainTapIndex));
                weight=num2str(obj.TapWeights(weightIdx));
                obj.Taps(weightIdx)=obj.DefaultTapParameter(tapNum,weight,obj.Usage);
            end
        end
    end
    methods(Static)
        function defaultTapParameter=DefaultTapParameter(name,weight,usage)
            description=strcat("tap ",name);
            formatString=strcat("Range ",weight," -2 2");
            defaultTapParameter=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter(...
            'Name',name,...
            'Description',description,...
            'Usage',usage,...
            'Type','Tap',...
            'Format',formatString,...
            'CurrentValue',weight);
        end
    end
end

