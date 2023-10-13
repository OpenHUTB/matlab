classdef(Abstract)WirePart<em.wire.Part

    properties
        WireDiameter=em.wire.WirePart.DefaultWireDiameter
        FeedOffset=em.wire.WirePart.DefaultFeedOffset
    end

    properties(Access=protected)
        StripHorizontal=em.wire.WirePart.DefaultStripHorizontal
    end

    properties(Access=private,Constant)
        DefaultWireDiameter=em.wire.convertawg(14)
        DefaultEndDiameter=[]
        DefaultFeedOffset=[]
        DefaultStripHorizontal=true
    end

    properties(Dependent)
EndDiameter
    end

    properties(SetAccess=private,GetAccess=protected)
        PrivateEndDiameter=[]
    end

    properties(Hidden,Constant)
        NumPoints=32
    end

    properties(Hidden)
PhantomNextParts


    end

    properties(Dependent)
FeedLocation
    end

    methods(Access=protected)
        function p=makeInputParser(obj)
            p=makeInputParser@em.wire.Part(obj);
            p.CaseSensitive=false;
            addParameter(p,'WireDiameter',obj.DefaultWireDiameter);
            addParameter(p,'FeedOffset',obj.DefaultFeedOffset);
            addParameter(p,'StripHorizontal',obj.DefaultStripHorizontal);
            addParameter(p,'EndDiameter',obj.DefaultEndDiameter);
        end

        function setParsedProperties(obj,p)
            setParsedProperties@em.wire.Part(obj,p);
            obj.WireDiameter=p.Results.WireDiameter;
            obj.FeedOffset=p.Results.FeedOffset;
            obj.StripHorizontal=p.Results.StripHorizontal;
            obj.EndDiameter=p.Results.EndDiameter;
        end
    end

    methods
        function obj=WirePart(varargin)
            obj@em.wire.Part(varargin{:});
        end

        function set.WireDiameter(obj,diameter)
            validateattributes(diameter,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'})
            obj.WireDiameter=diameter;
        end

        function set.EndDiameter(obj,diameter)
            if~isempty(diameter)
                validateattributes(diameter,{'numeric'},...
                {'nonempty','scalar','finite','real','positive'})
            end
            obj.PrivateEndDiameter=diameter;
        end

        function val=get.EndDiameter(obj)
            if isempty(obj.PrivateEndDiameter)
                val=obj.WireDiameter;
            else
                val=obj.PrivateEndDiameter;
            end
        end

        function set.FeedOffset(obj,val)
            if isequal(val,obj.FeedOffset)
                return
            end
            if isempty(val)
                obj.FeedOffset=[];
                return
            end
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','nonnegative',...
            '<=',1})
            obj.FeedOffset=val;
        end

        function val=get.FeedLocation(obj)
            if isempty(obj.FeedOffset)
                val=[];
            else
                val=getFeedLocation(obj);
            end
        end

        function set.StripHorizontal(obj,val)
            validateattributes(val,{'logical','numeric'},...
            {'nonempty','scalar'})
            obj.StripHorizontal=logical(val);
        end
    end

    methods(Access=protected)
        function copyProperties(in,out)

            out.WireDiameter=in.WireDiameter;
            out.EndDiameter=in.EndDiameter;
            out.FeedOffset=in.FeedOffset;
            out.StripHorizontal=in.StripHorizontal;
            out.PhantomNextParts=in.PhantomNextParts;
            copyProperties@em.wire.Part(in,out)
        end
    end

    methods(Abstract,Hidden)
        [vol,objs]=makeMesh(obj,freq)
        val=getFeedLocation(obj)
    end
end
