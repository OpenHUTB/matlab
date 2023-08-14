classdef partAntenna<em.wire.Part








    properties
Parts
    end

    properties(Access=protected,Constant)
        DefaultParts=em.wire.Part.empty
    end

    properties(Dependent)
Length
EndPoint
FeedOffset
FeedLocation
    end

    properties(Access=private)
        PrivateFeedOffset=[]
        FeedIdx=[]
    end

    properties(Hidden)
        Color=[223,185,58]/255
    end

    methods(Access=protected)
        function p=makeInputParser(obj)
            p=makeInputParser@em.wire.Part(obj);
            addParameter(p,'Parts',obj.DefaultParts);
        end

        function setParsedProperties(obj,p)
            setParsedProperties@em.wire.Part(obj,p);
            obj.Parts=p.Results.Parts;
        end
    end

    methods
        function obj=partAntenna(varargin)
            narginchk(0,inf)
            if nargin>0&&isa(varargin{1},'em.wire.Part')
                obj.Parts=[varargin{:}];
            elseif nargin==1&&ischar(varargin{1})
                obj=em.wire.Part.nec2ml(varargin{1});
            else
                p=makeInputParser(obj);
                parse(p,varargin{:});
                setParsedProperties(obj,p);
            end
        end

        function set.Parts(obj,val)
            if~isempty(val)
                validateattributes(val,{'em.wire.Part'},{'vector'})
            end
            obj.Parts=val(:)';
        end

        function val=get.Length(obj)
            val=0;
            flat=flatten(obj);
            for i=1:numel(flat.Parts)
                len=flat.Parts(i).Length;
                val=val+len;
            end
        end

        function val=get.EndPoint(obj)
            if isempty(obj.Parts)
                val=[];
            else
                val=obj.Parts(end).EndPoint;
                val=transform(obj.Transform,val);
            end
        end

        function val=get.FeedOffset(obj)
            val=obj.PrivateFeedOffset;
        end

        function set.FeedOffset(obj,val)
            if isequal(val,obj.FeedOffset)
                return
            end
            if isempty(val)
                obj.PrivateFeedOffset=[];
                return
            end
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','nonnegative','<=',1})


            for i=1:numel(obj.Parts)
                if~isa(obj.Parts(i),'em.wire.WirePart')&&...
                    ~isa(obj.Parts(i),'em.wire.partAntenna')
                    continue
                end
                obj.Parts(i).FeedOffset=[];
            end

            feedLen=val*obj.Length;
            startLen=0;
            for i=1:numel(obj.Parts)
                if~isa(obj.Parts(i),'em.wire.WirePart')&&...
                    ~isa(obj.Parts(i),'em.wire.partAntenna')
                    continue
                end
                pLen=obj.Parts(i).Length;
                nextLen=startLen+pLen;
                if feedLen<=nextLen
                    obj.FeedIdx=i;
                    obj.Parts(i).FeedOffset=(feedLen-startLen)/pLen;
                    break;
                end
                startLen=nextLen;
            end
            obj.PrivateFeedOffset=val;
        end

        function val=get.FeedLocation(obj)
            if isempty(obj.Parts)||isempty(obj.FeedOffset)
                val=[];
            else
                val=obj.Parts(obj.FeedIdx).FeedLocation;
                val=transform(obj.Transform,val);
            end
        end
    end

    methods(Hidden)
        function out=localClone(obj)

            p=em.wire.Part.empty;
            for i=1:numel(obj.Parts)
                p(i)=clone(obj.Parts(i));
            end
            out=em.wire.partAntenna('Parts',p);
            copyProperties(obj,out)
        end

        function[vol,objs]=makeMesh(obj,varargin)
            narginchk(1,2)
            vol=em.wire.Volume;
            objs=[];
            for i=1:numel(obj.Parts)
                if~isa(obj.Parts(i),'em.wire.WirePart')&&...
                    ~isa(obj.Parts(i),'em.wire.partAntenna')
                    continue
                end
                [voli,objsi]=makeMesh(obj.Parts(i),varargin{:});
                voli=transform(voli,obj.Transform);
                add(vol,voli,obj.Parts(i).Color);
                objs=[objs;objsi];%#ok<AGROW>
            end
        end

        function[feedtag,feedseg]=addGW(obj,sw,freq)
            feedtag=[];
            feedseg=[];
            for i=1:numel(obj.Parts)
                if~isa(obj.Parts(i),'em.wire.WirePart')&&...
                    ~isa(obj.Parts(i),'em.wire.partAntenna')
                    continue
                end
                [t,s]=addGW(obj.Parts(i),sw,freq);
                if~isempty(t)
                    feedtag=t;
                    feedseg=s;
                end
            end
            if isempty(feedtag)
                error('no FeedPoint')
            end
        end

        function out=flatten(obj,inPlace)
            if nargin==1
                inPlace=false;
            end
            p=obj.Parts;
            i=find(arrayfun(@(x)isa(x,'em.wire.partAntenna'),p),1);
            while~isempty(i)
                p=[p(1:i-1),p(i).Parts,p(i+1:end)];
                i=find(arrayfun(@(x)isa(x,'em.wire.partAntenna'),p),1);
            end
            if inPlace
                out=obj;
            else
                out=clone(obj);
            end
            if~isequal(p,obj.Parts)
                out.Parts=p;
            end
        end
    end
end
