classdef(Abstract,Hidden,AllowedSubclasses={...
    ?matlab.graphics.chartcontainer.ChartContainer,...
    ?matlab.graphics.chart.CartesianChartContainer,...
    ?matlab.graphics.chart.PolarChartContainer,...
    ?matlab.graphics.chart.GeographicChartContainer,...
    ?matlab.graphics.chartcontainer.PolarChartContainer...
    })ChartBaseProxy<matlab.graphics.chart.internal.PositionableChartWithAxes&...
    matlab.graphics.chartcontainer.mixin.internal.GeneratedCallbackSaveLoadMixin




    properties(Transient,Hidden,GetAccess=public,SetAccess=protected)
Type
    end

    properties(Transient,Hidden,GetAccess=protected,SetAccess=protected)
        Type_I matlab.internal.datatype.matlab.graphics.datatype.TypeName
    end

    properties(NonCopyable,Transient,Access=private)


        Axes(1,:)matlab.graphics.axis.AbstractAxes
    end

    methods(Abstract,Access={?matlab.graphics.chart.Chart,?matlab.graphics.chart.internal.PositionalbleChartWithAxes})
        getLayout(obj)
    end

    methods(Hidden,Sealed,Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.Chart,...
        ?matlab.graphics.mixin.Mixin})
        function hAx=getAxes(obj)



            if isa(obj.NodeChildren,'matlab.graphics.layout.TiledChartLayout')
                layout=obj.getLayout;
                hAx=findobj(layout.Children,'-isa','matlab.graphics.axis.AbstractAxes');
            else

                hAx=obj.Axes;
            end


            valid=isvalid(hAx);
            if any(~valid)
                hAx=hAx(valid);
                obj.Axes=hAx;
            end


            if isempty(hAx)
                hAx=createAxes(obj);
                obj.Axes=hAx;
            end

        end
    end

    methods
        function set.Type(obj,val)
            obj.Type_I=val;
        end

        function t=get.Type(obj)
            t=getTypeName(obj);
        end
    end

    methods(Hidden,Access=protected)

        function t=getTypeName(obj)
            t=obj.Type_I;
        end
    end

    methods(Abstract,Access=protected)
        doSetupInternal(obj)
    end

    methods(Static,Hidden)
        function out=doloadobj(in)
            out=in;
            m=metaclass(out);
            if~m.ConstructOnLoad
                out=out.doSetupInternal;
            end
        end
    end

    properties(Hidden,Access=protected,Transient)
        UpdateGuard=true;
        UseTwoArgUpdate=false;
    end

    methods(Static,Access=protected)
        function tf=chartObjectBeingCopied(val)






            persistent value;
            if nargin
                value=val;
            elseif isempty(value)
                value=false;
            end
            tf=value;
        end
    end

    methods(Hidden,Access=protected)


        function tf=useGcaBehavior(obj)
            gcfTrue=obj.useGcfBehavior;

            tf=gcfTrue&&isvalid(obj)&&length(obj.Axes)<=1;
        end

        function tf=useGcfBehavior(~)
            tf=true;
        end
    end

    properties(Access=protected,Transient,Hidden)
        SetupUpdateBlock(1,1)logical=false;
        InUpdateFlag(1,1)logical=false;
    end

    methods(Abstract,Access=protected,Hidden)
        update(obj,us)
        setup(obj)
        ax=createAxes(obj)
    end



    methods(Hidden)



        function doUpdate(obj,us)
            obj.update(us);
        end


        function doUpdateChart(obj,us)
            if isvalid(obj)
                obj.doUpdateInternal(us)
            end
        end

        function doUpdateInternal(obj,us)
            if obj.SetupUpdateBlock==false



                currentFig=ancestor(obj,'figure');
                currentax=[];
                if obj.useGcaBehavior&&~isempty(currentFig)
                    currentax=currentFig.CurrentAxes;
                end

                obj.InUpdateFlag=true;
                try
                    if obj.UseTwoArgUpdate
                        obj.update(us);
                    else
                        obj.update;
                    end
                    if~isvalid(obj)
                        msgid='CAF:ChartDestroyed';
                        errmsg='Chart object destroyed or corrupted in update.';
                        me=MException(msgid,errmsg);
                        rethrow(me);
                    end
                catch ex

                    if~isempty(currentax)&&isvalid(currentax)
                        currentFig.CurrentAxes=currentax;
                    end
                    rethrow(ex);
                end
                obj.InUpdateFlag=false;


                if~isempty(currentax)&&isvalid(currentax)
                    currentFig.CurrentAxes=currentax;
                end
            end
        end
    end

    properties(Access=protected,Transient,NonCopyable,Hidden)
CtorArgs
    end

    methods(Access=protected,Hidden)







        function[parent,args]=parseCustomArgs(obj,varargin)
            [parent,args]=parseChartInputs(varargin,class(obj));
            if~isempty(parent)
                validateChartParent(parent,class(obj));
            end
        end

    end

    methods(Access=protected)


        function obj=setObjectValues(obj,varargin)
            obj.SetupUpdateBlock=true;

            if~isempty(varargin)
                matlab.graphics.chart.internal.ctorHelper(obj,varargin);
            end
            obj.SetupUpdateBlock=false;
        end

        function obj=ChartBaseProxy(varargin)
            m=metaclass(obj);

            obj.Type_I=lower(m.Name);


            mi=findobj(m.MethodList,'Name','update');
            obj.UseTwoArgUpdate=length(mi.InputNames)>1;

            try

                [parent,args]=obj.parseCustomArgs(varargin{:});

                if~obj.chartObjectBeingCopied&&obj.useGcaBehavior
                    posArgs=["OuterPosition","InnerPosition","Position"];
                    posArgsPresent=any(startsWith(posArgs,string(args(1:2:end)),'IgnoreCase',1));







                    if~posArgsPresent
                        setter=@(varargin)obj.setObjectValues(varargin{:});
                        matlab.graphics.internal.prepareCoordinateSystem(...
                        class(obj),parent,setter);




                        parent=gobjects(0);
                    else
                        if isempty(parent)

                            parent=gcf;
                        end
                    end
                end



                if~isempty(parent)
                    args=[{'Parent'},{parent},args(:)'];
                end


                obj.CtorArgs=args;

            catch e

                obj.Parent=[];
                throwAsCaller(e);
            end

            obj.UpdateGuard=false;
        end
    end


    methods(Access='protected',Hidden=true)
        function groups=getPropertyGroups(obj)
            mc=metaclass(obj);
            clsprops=findobj(mc.PropertyList,'DefiningClass',mc,...
            '-and','Hidden',false,...
            '-and','GetAccess','public');
            groups(1)=matlab.mixin.util.PropertyGroup(...
            {clsprops.Name,'Position','Units'});
        end
    end
end



function validateChartParent(parent,className)

    if~isa(parent,'matlab.graphics.Graphics')||~isscalar(parent)

        throwAsCaller(MException(message('MATLAB:graphics:chartauthoring:InvalidParent')));
    elseif~isvalid(parent)

        throwAsCaller(MException(message('MATLAB:graphics:chartauthoring:DeletedParent')));
    elseif isa(parent,'matlab.graphics.axis.AbstractAxes')

        throwAsCaller(MException(message('MATLAB:hg:InvalidParent',...
        className,class(parent))));
    end

end
