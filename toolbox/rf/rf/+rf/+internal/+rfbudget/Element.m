classdef(Abstract)Element<rf.internal.circuit.Element




    properties(Hidden)
        Budget=[]
    end

    properties(Hidden,Transient)
        Listener=[]
    end


    methods(Sealed=true)
        function ckt=circuit(obj,name)
            checkChain(obj)
            if nargin==2
                ckt=circuit(name);
            else
                ckt=circuit;
            end

            for i=1:numel(obj)
                add(ckt,[i,i+1],obj(i))
            end
            setports(ckt,[1,0],[i+1,0])
        end
    end

    methods(Hidden,Sealed=true)
        function checkChain(obj)
            validateattributes(obj,{'rf.internal.rfbudget.Element'},...
            {'nonempty','vector'},'','')
            for i=1:numel(obj)
                if isa(obj(i),'nport')
                    if obj(i).NumPorts~=2
                        error(message('rf:rfbudget:NportNumPortsNot2',i))
                    end
                end
            end
        end
    end

    methods(Hidden)
        function Sobj=sparameters(obj,varargin)

            narginchk(1,3)
            Sobj=obj.NetworkData;

            if nargin>=2
                freq=varargin{1};
                if~isequal(freq,Sobj.Frequencies)
                    Sobj=rfinterp1(Sobj,freq,'extrap');
                end
            end

            if nargin==3
                z0=varargin{2};
                if~isequal(z0,Sobj.Impedance)
                    Sobj=sparameters(Sobj,z0);
                end
            end
        end

        function gd=groupdelay(obj,varargin)



            if~isempty(obj.Parent)

                error(message('rf:shared:GroupDelayCircuitNotTop'))
            end

            Sobj=obj.NetworkData;
            gd=groupdelay(Sobj,varargin{:});
        end
    end

    methods(Abstract,Hidden)
        Ca=getCa(obj,freq,stageS)
        gain=getGain(obj,stageS)
        NF=getNF(obj,Ca)
        OIP3=getOIP3(obj)
    end

    methods(Access=protected)
        function h=add_block(obj,src,sys,x,y)
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y);
            name=obj.Name;
            h=add_block(src,[sys,'/',name],...
            'MakeNameUnique','on',...
            'BackgroundColor','lightBlue',...
            'Position',pos);
        end
    end

    methods(Abstract,Access=protected)
        h=rbBlock(obj,sys,x,y,rconn,freq)
    end

    methods(Hidden)
        function[x,rconnOut]=rbBlocks(obj,sys,x,y,dx,dy,rconn,freq,varargin)


            iq=(numel(rconn)==2);
            h=rbBlock(obj,sys,x,y-iq*dy/2,rconn(1),freq);
            ph=get(h,'PortHandles');
            if isa(obj,'rfantenna')
                if strcmpi(obj.Type,'Transmitter')
                    rconnOut=ph.Outport;
                else
                    rconnOut=ph.LConn;
                end
            else
                rconnOut=ph.RConn;
            end

            if isa(obj,'mixerIMT')
                set(h,'FrequencyRF',sprintf('%.15g',freq))
            end

            if iq
                h=rbBlock(obj,sys,x,y+dy/2,rconn(2),freq);
                ph=get(h,'PortHandles');
                if isa(obj,'rfantenna')
                    if strcmpi(obj.Type,'Transmitter')
                        rconnOut(2)=ph.Outport;
                    else
                        rconnOut(2)=ph.LConn;
                    end
                else
                    rconnOut(2)=ph.RConn;
                end
            end
            pos=get(h,'Position');
            x=pos(3)+dx;
        end
    end

    methods(Static,Hidden)
        function pos=newPos(p,x,y)

            ht=p(4)-p(2);
            wd=p(3)-p(1);
            pos=[x,y-ht/2,x+wd,y+ht/2];
        end
    end
end
