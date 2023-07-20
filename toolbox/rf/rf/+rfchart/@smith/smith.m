classdef(CaseInsensitiveProperties,TruncatedProperties)...
    smith<rfbase.rfbase

























    properties(Hidden)

        NeedReset=true;
    end
    methods
        function set.NeedReset(obj,value)
            if~isequal(obj.NeedReset,value)
                checkbool(obj,'NeedReset',value)
                obj.NeedReset=logical(value);
            end
        end
    end

    properties(AbortSet,SetObservable)


        Type='Z';
    end
    methods
        function set.Type(obj,value)
            enum_list={'Z','Y','ZY','YZ'};
            obj.Type=checkenumexact(obj,'Type',value,enum_list);
        end
    end

    properties(AbortSet,SetObservable)

        Values=[0.2,.5,1,2,5;1,2,5,5,30];
    end
    methods
        function set.Values(obj,value)
            checkposmatrix(obj,'Values',value);
            obj.Values=value;
        end
    end

    properties(AbortSet,SetObservable)

        Color=[.4,.4,.4];
    end
    methods
        function set.Color(obj,value)
            check3entryvec(obj,'Color',value);
            obj.Color=value;
        end
    end

    properties(AbortSet,SetObservable)

        LineWidth=.5;
    end
    methods
        function set.LineWidth(obj,value)
            obj.LineWidth=setpositive(obj,value,'LineWidth',...
            true,false,false,false);
        end
    end

    properties(AbortSet,SetObservable)

        LineType='-';
    end
    methods
        function set.LineType(obj,value)
            checklinetype(obj,'LineType',value)
            obj.LineType=value;
        end
    end

    properties(AbortSet,SetObservable)

        SubColor=[.8,.8,.8];
    end
    methods
        function set.SubColor(obj,value)
            check3entryvec(obj,'SubColor',value);
            obj.SubColor=value;
        end
    end

    properties(AbortSet,SetObservable)

        SubLineWidth=.5;
    end
    methods
        function set.SubLineWidth(obj,value)
            obj.SubLineWidth=setpositive(obj,value,'SubLineWidth',...
            true,false,false,false);
        end
    end

    properties(AbortSet,SetObservable)

        SubLineType=':';
    end
    methods
        function set.SubLineType(obj,value)
            checklinetype(obj,'SubLineType',value)
            obj.SubLineType=value;
        end
    end

    properties(AbortSet,SetObservable)


        LabelVisible='On';
    end
    methods
        function set.LabelVisible(obj,value)
            enum_list={'On','Off'}';
            obj.LabelVisible=checkenum(obj,'LabelVisible',value,...
            enum_list);
        end
    end

    properties(AbortSet,SetObservable)

        LabelSize=10;
    end
    methods
        function set.LabelSize(obj,value)
            obj.LabelSize=setpositive(obj,value,'LabelSize',...
            true,false,false,false);
        end
    end

    properties(AbortSet,SetObservable)

        LabelColor=[0,0,0];
    end
    methods
        function set.LabelColor(obj,value)
            check3entryvec(obj,'LabelColor',value);
            obj.LabelColor=value;
        end
    end

    properties(Access=protected)

        LabelHandles=[];
    end

    properties(Access=protected)

        XData=[];
    end

    properties(Access=protected)

        YData=[];
    end

    properties(SetAccess=protected,SetObservable,Hidden)

        Axes=[];
    end
    methods
        function set.Axes(obj,value)

            obj.Axes=localSetFunc(obj,value);
        end
    end

    properties(Access=protected)

        StaticGrid=[];
    end
    methods
        function set.StaticGrid(obj,value)

            obj.StaticGrid=localSetFunc(obj,value);
        end
    end

    properties(Access=protected)

        AdmittanceGrid=[];
    end
    methods
        function set.AdmittanceGrid(obj,value)

            obj.AdmittanceGrid=localSetFunc(obj,value);
        end
    end

    properties(Access=protected)

        ImpedanceGrid=[];
    end
    methods
        function set.ImpedanceGrid(obj,value)

            obj.ImpedanceGrid=localSetFunc(obj,value);
        end
    end


    methods
        function h=smith(varargin)









































            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end

            set(h,'Name','Smith chart');


            checkreadonlyproperty(h,varargin,'Name');

            if nargin
                set(h,varargin{:});
            end


            if h.NeedReset
                clf reset;
            end
            if isempty(h.Axes)
                h.Axes=gca;
            end
            reset(h.Axes);


            M=128;
            t=0:M;
            X=sin(t*2*pi/M);
            Y=cos(t*2*pi/M);
            hh=fill(X,Y,[1,1,1]);
            set(hh,'HandleVisibility','off','HitTest','off')


            set(h.Axes,'DataAspectRatio',[1,1,1],...
            'PlotBoxAspectRatio',[1,1,1],'XScale','linear',...
            'YScale','linear','XDir','normal','YDir','normal',...
            'XLim',[-1.015,1.015],'YLim',[-1.015,1.015],'XTick',[],...
            'YTick',[],'XGrid','off','YGrid','off','Box','on');


            h.AdmittanceGrid=line('Parent',h.Axes,'XData',0,'YData',0,...
            'Visible','off','Clipping','on','HandleVis','off',...
            'HitTest','off');
            h.ImpedanceGrid=line('Parent',h.Axes,'XData',0,'YData',0,...
            'Visible','off','Clipping','on','HandleVis','off',...
            'HitTest','off');


            t=0:M;
            h.StaticGrid=line('Parent',h.Axes,'Color',h.Color,...
            'LineWidth',h.LineWidth,'XData',[-1,1,NaN,sin(t*2*pi/M)],...
            'YData',[0,0,NaN,cos(t*2*pi/M)],'Visible','on',...
            'Clipping','on','HandleVis','off','HitTest','off');



            hBehavior=hggetbehavior(hh,'DataCursor');
            set(hBehavior,'Enable',false);
            hBehavior=hggetbehavior(h.AdmittanceGrid,'DataCursor');
            set(hBehavior,'Enable',false);
            hBehavior=hggetbehavior(h.ImpedanceGrid,'DataCursor');
            set(hBehavior,'Enable',false);
            hBehavior=hggetbehavior(h.StaticGrid,'DataCursor');
            set(hBehavior,'Enable',false);


            draw(h);

            drawList={'Values','Color','SubColor','LineWidth'...
            ,'SubLineWidth','LineType','SubLineType','Type'};
            labelList={'LabelVisible','LabelSize','LabelColor'};
            addlistener(h,drawList,'PostSet',@(src,evnt)draw(h,src,evnt));
            addlistener(h,labelList,'PostSet',@(src,evnt)label(h,src,evnt));
            addlistener(h.Axes,'ObjectBeingDestroyed',...
            @(h_axes,e)local_axes_destroy_callback(h_axes,e,h));


            SmithChart=getappdata(h.Axes,'SmithChart');
            if isa(SmithChart,'rfchart.smith')
                delete(SmithChart);
            end
            setappdata(h.Axes,'SmithChart',h);

            set(h.Axes,'ColorOrderIndex',1)

        end

    end

    methods
        checkposmatrix(h,prop_name,val)
        h=destroy(h,destroyData)
        h=draw(h,src,eventData)
        ts=label(h,src,eventData)

        function checkproperty(~)
        end
    end

end

function local_axes_destroy_callback(h,e,hsm)%#ok<INUSL>

    destroy(hsm);
end

function valStored=localSetFunc(h,valProposed)%#ok 
    valStored=valProposed;
end
