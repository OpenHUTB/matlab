
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Line<matlab.graphics.shape.internal.OneDimensional





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        LineHandle matlab.graphics.primitive.world.LineStrip;
    end

    methods
        function valueToCaller=get.LineHandle(hObj)


            valueToCaller=hObj.LineHandle_I;

        end

        function set.LineHandle(hObj,newValue)



            hObj.LineHandleMode='manual';


            hObj.LineHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineHandleMode(hObj)
            storedValue=hObj.LineHandleMode;
        end

        function set.LineHandleMode(hObj,newValue)

            oldValue=hObj.LineHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        LineHandle_I;
    end

    methods
        function set.LineHandle_I(hObj,newValue)
            hObj.LineHandle_I=newValue;
            try
                hObj.setLineHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    methods
        function valueToCaller=get.LineStyle(hObj)


            valueToCaller=hObj.LineStyle_I;

        end

        function set.LineStyle(hObj,newValue)



            hObj.LineStyleMode='manual';


            hObj.LineStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineStyleMode(hObj)
            storedValue=hObj.LineStyleMode;
        end

        function set.LineStyleMode(hObj,newValue)

            oldValue=hObj.LineStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    methods
        function storedValue=get.LineStyle_I(hObj)
            storedValue=hObj.LineStyle_I;
        end

        function set.LineStyle_I(hObj,newValue)



            fanChild=hObj.LineHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.LineWidth(hObj)




            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.LineWidth;
        end

        function set.LineWidth(hObj,newValue)






            hObj.LineWidthMode='manual';
            hObj.LineWidth_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineWidthMode(hObj)
            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidthMode;
        end

        function set.LineWidthMode(hObj,newValue)


            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidthMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)


            passObj=hObj.LineHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.LineWidth_I=newValue;
        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'LineHandle')
                b=true;
                return;
            end
            if strcmp(name,'LineHandle_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.shape.internal.OneDimensional(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=Line(varargin)






            hObj.LineHandle_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.LineHandle,'Description_I','Line LineHandle');

            set(hObj.LineHandle,'Internal',true);


            hObj.LineWidth_I=get(0,'DefaultLineLineWidth');


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setLineHandle_IFanoutProps(hObj)

            hgfilter('LineStyleToPrimLineStyle',hObj.LineHandle,hObj.LineStyle_I);

        end
    end


    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='lineshape';




            hAf=hObj.Srect;
            hG=matlab.graphics.primitive.world.Group.empty;
            set(hAf,'Parent',hG);
            for k=1:numel(hAf)
                hObj.addNode(hAf(k));
            end


            hObj.LineWidth_I=get(0,'DefaultLineLineWidth');
            hObj.LineStyle_I=get(0,'DefaultLineLineStyle');

        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getScribeMenus(hObj)










            hFig=ancestor(hObj,'figure');
            res=matlab.ui.container.Menu.empty;

            if isempty(hFig)||~isvalid(hFig)
                varargout{1}=res;
                return;
            end

            hPlotEdit=plotedit(hFig,'getmode');
            hMode=hPlotEdit.ModeStateData.PlotSelectMode;
            hMenu=hMode.UIContextMenu;

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.Line.uicontextmenu*');
            if~isempty(res)
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end


            res=matlab.ui.container.Menu.empty;
            tempParent=matlab.ui.container.ContextMenu;

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));


            menuSpecificTags={'Color','LineWidth','LineStyle'};
            assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
            for i=1:length(res)
                set(res(i),'Tag',['matlab.graphics.shape.Line.uicontextmenu','.',menuSpecificTags{i}]);
            end


            set(res,'Visible','off','Parent',hMenu);
            delete(tempParent);
            varargout{1}=res;
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)



            updatePins(hObj,updateState);
            updateMarkers(hObj,updateState);


            hL=hObj.LineHandle;
            iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            iter.XData=hObj.NormX;
            iter.YData=hObj.NormY;
            iter.ZData=[0;0];
            vertexData=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,iter);
            hL.VertexData=vertexData;


            hgfilter('RGBAColorToGeometryPrimitive',hL,hObj.Color);

        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getPlotEditToolbarProp(hObj,toolbarProp)

            if strcmpi(toolbarProp,'edgecolor')
                varargout{1}={'Color'};
                varargout{2}='Color';
            else
                outargs=cell(1,nargout);
                [outargs{1:nargout}]=getPlotEditToolbarProp@matlab.graphics.shape.internal.OneDimensional(hObj,toolbarProp);
                varargout=outargs;
            end
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Color','LineStyle','LineWidth',...
            'Position','Units','X','Y'});

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getDescriptiveLabelForDisplay(hObj)

            varargout{1}=hObj.Tag;
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,code)
    end




end
