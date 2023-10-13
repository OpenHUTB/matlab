classdef wire<em.wire.WirePart

    properties
        Length=em.wire.wire.DefaultLength
    end

    properties(Dependent)
EndPoint
    end

    properties(Hidden)
        Tag=[]
        Seg=[]
    end

    properties(Access=protected,Constant)
        DefaultLength=0.1
        DefaultEndPoint=[0,0,0.1]
    end

    properties(Hidden)
        Color=[223,185,58]/255
    end

    methods(Access=protected)
        function p=makeInputParser(obj)
            p=makeInputParser@em.wire.WirePart(obj);
            p.CaseSensitive=false;
            addParameter(p,'Length',obj.DefaultLength);
            addParameter(p,'EndPoint',obj.DefaultEndPoint);
        end

        function setParsedProperties(obj,p)
            setParsedProperties@em.wire.WirePart(obj,p);
            if any(strcmpi('EndPoint',p.UsingDefaults))
                obj.Length=p.Results.Length;
            else
                obj.EndPoint=p.Results.EndPoint;
            end
        end
    end

    methods
        function obj=wire(varargin)
            obj@em.wire.WirePart(varargin{:});
        end

        function set.Length(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','nonnegative'})
            obj.Length=val;
        end

        function val=get.EndPoint(obj)
            val=transform(obj.Transform,[0,0,obj.Length]);
        end

        function set.EndPoint(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','vector','finite','real','nonnan','numel',3})
            vec=val-obj.StartPoint;
            [az,el,obj.Length]=cart2sph(vec(1),vec(2),vec(3));
            obj.Azimuth=radtodeg(az);
            obj.Elevation=radtodeg(el);
        end
    end

    methods(Hidden)
        function out=localClone(obj)

            out=em.wire.wire;
            out.Length=obj.Length;
            copyProperties(obj,out)
        end

        function[vol,objs]=makeMesh(obj,freq)



            narginchk(1,2)
            if nargin==1
                n=1;
            else
                validateattributes(freq,{'numeric'},...
                {'nonempty','scalar','real','finite','nonnegative'},...
                '','freq')


                nmin=obj.Length*18*freq/obj.LightSpeed;
...
...
...
...
...
...
                n=ceil(max(nmin,1));
                if mod(n,2)==0
                    n=n+1;
                end
            end
            if~isempty(obj.FeedOffset)
                seg=find(obj.FeedOffset<=(1:n)/n,1);
            end


            T=em.wire.AffineTransform;
            translate(T,[0,0,obj.Length/n]);

            curv=em.wire.Curve([0,0,0]);
            vol=extruder(curv,T,n,obj.Color);
            if~isempty(obj.FeedOffset)
                vol.Colors(seg,:)=[176,0,27]/255;
            end
            vol=transform(vol,obj.Transform);
            objs=obj(ones(n,1));
        end

        function val=getFeedLocation(obj)
            val=transform(obj.Transform,[0,0,obj.FeedOffset*obj.Length]);
        end

        function[feedtag,feedseg]=addGW(obj,sw,freq)
            vol=makeMesh(obj,freq);
            n=numel(vol.Surfaces);
            if~isempty(obj.FeedOffset)
                feedtag=lines(sw);
                feedseg=find(obj.FeedOffset<(1:n)/n,1);
            else
                feedtag=[];
                feedseg=[];
            end
            if isempty(obj.Tag)
                tag=min(999,lines(sw));
                seg=n;
                if isempty(obj.PrivateEndDiameter)
                    addcr(sw,'GW%3d %4d %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f',...
                    tag,seg,obj.StartPoint,obj.EndPoint,obj.WireDiameter/2)
                else
                    addcr(sw,'GW%3d %4d %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f',...
                    tag,seg,obj.StartPoint,obj.EndPoint,0)
                    addcr(sw,'GC %2d %4d %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f',...
                    0,0,1,obj.WireDiameter/2,obj.EndDiameter/2,0,0,0,0)
                end
            else
                delta=(obj.EndPoint-obj.StartPoint)/obj.Seg;
                for i=1:obj.Seg
                    startpt=obj.StartPoint+(i-1)*delta;
                    if i<obj.Seg
                        endpt=obj.StartPoint+i*delta;
                    else
                        endpt=obj.EndPoint;
                    end
                    if isempty(obj.PrivateEndDiameter)
                        addcr(sw,'GW%3d %4d %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f',...
                        obj.Tag,1,startpt,endpt,obj.WireDiameter/2)
                    else
                        addcr(sw,'GW%3d %4d %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f',...
                        obj.Tag,1,startpt,endpt,0)
                        addcr(sw,'GC %2d %4d %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f',...
                        0,0,1,obj.WireDiameter/2,obj.EndDiameter/2,0,0,0,0)
                    end
                end
            end
        end
    end
end
