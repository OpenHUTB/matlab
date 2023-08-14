
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Hidden=true)OneDimensional<matlab.graphics.shape.internal.ScribeObject&matlab.graphics.internal.GraphicsJavaVisible





    properties(SetObservable=true,SetAccess='private',GetAccess='protected',Dependent=true,Hidden=false)

        NormX matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods
        function valueToCaller=get.NormX(hObj)



            valueToCaller=hObj.getNormXImpl(hObj.NormX_I);


        end

        function set.NormX(hObj,newValue)



            hObj.NormXMode='manual';



            reallyDoCopy=~isequal(hObj.NormX_I,newValue);

            if reallyDoCopy
                hObj.NormX_I=hObj.setNormXImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        NormXMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.NormXMode(hObj)
            storedValue=hObj.NormXMode;
        end

        function set.NormXMode(hObj,newValue)

            oldValue=hObj.NormXMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.NormXMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='protected',Dependent=false,Hidden=true,AffectsLegend)

        NormX_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='private',GetAccess='protected',Dependent=true,Hidden=false)

        NormY matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods
        function valueToCaller=get.NormY(hObj)



            valueToCaller=hObj.getNormYImpl(hObj.NormY_I);


        end

        function set.NormY(hObj,newValue)



            hObj.NormYMode='manual';



            reallyDoCopy=~isequal(hObj.NormY_I,newValue);

            if reallyDoCopy
                hObj.NormY_I=hObj.setNormYImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        NormYMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.NormYMode(hObj)
            storedValue=hObj.NormYMode;
        end

        function set.NormYMode(hObj,newValue)

            oldValue=hObj.NormYMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.NormYMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='protected',Dependent=false,Hidden=true,AffectsLegend)

        NormY_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        X matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods
        function valueToCaller=get.X(hObj)



            valueToCaller=hObj.getXImpl(hObj.X_I);


        end

        function set.X(hObj,newValue)



            hObj.XMode='manual';



            reallyDoCopy=~isequal(hObj.X_I,newValue);

            if reallyDoCopy
                hObj.X_I=hObj.setXImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XMode(hObj)
            storedValue=hObj.XMode;
        end

        function set.XMode(hObj,newValue)

            oldValue=hObj.XMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        X_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Y matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods
        function valueToCaller=get.Y(hObj)



            valueToCaller=hObj.getYImpl(hObj.Y_I);


        end

        function set.Y(hObj,newValue)



            hObj.YMode='manual';



            reallyDoCopy=~isequal(hObj.Y_I,newValue);

            if reallyDoCopy
                hObj.Y_I=hObj.setYImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YMode(hObj)
            storedValue=hObj.YMode;
        end

        function set.YMode(hObj,newValue)

            oldValue=hObj.YMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Y_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=[0.3,0.4];
    end

    methods





    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            b=false;
        end
    end





    methods
        function hObj=OneDimensional(varargin)








            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end



    methods(Access='protected',Hidden=true)
        function varargout=getAffordanceLocation(hObj,affNum,position)

            locations=[position(1),position(2);...
            position(1)+position(3),position(2)+position(4)];
            varargout{1}=locations(affNum,:);
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getNormXImpl(hObj,storedValue)



            pos=hObj.NormalizedPosition;
            varargout{1}=[pos(1),pos(1)+pos(3)];


        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setNormXImpl(hObj,newValue)

            varargout{1}=newValue;

        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getNormYImpl(hObj,storedValue)



            pos=hObj.NormalizedPosition;
            varargout{1}=[pos(2),pos(2)+pos(4)];


        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setNormYImpl(hObj,newValue)

            varargout{1}=newValue;

        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getXImpl(hObj,storedValue)



            pos=hObj.Position;
            varargout{1}=[pos(1),pos(1)+pos(3)];


        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setXImpl(hObj,newValue)



            varargout{1}=newValue;

            pos=hObj.Position;
            pos(1)=newValue(1);
            pos(3)=newValue(2)-newValue(1);
            hObj.Position=pos;


        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getYImpl(hObj,storedValue)



            pos=hObj.Position;
            varargout{1}=[pos(2),pos(2)+pos(4)];


        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setYImpl(hObj,newValue)



            varargout{1}=newValue;

            pos=hObj.Position;
            pos(2)=newValue(1);
            pos(4)=newValue(2)-newValue(1);
            hObj.Position=pos;


        end
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)








            hAf(1)=matlab.graphics.primitive.world.Marker;
            hAf(2)=matlab.graphics.primitive.world.Marker;
            descriptions={'bottomleft','topright'};


            for i=1:2
                set(hAf(i),'FaceColorData',uint8([192;231;255;178]),...
                'FaceColorBinding','object',...
                'EdgeColorData',uint8([0;86;150;255]),...
                'EdgeColorBinding','object',...
                'HandleVisibility','off',...
                'LineWidth',0.5,...
                'Style','square',...
                'Size',hObj.Afsize,...
                'Description',descriptions{i},...
                'Serializable','off',...
                'Internal',true);
                hObj.addNode(hAf(i));
            end
            hObj.Srect=hAf;


            hObj.PinAff=int8([1;2]);
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getPinMenus(hObj)



            hFig=ancestor(hObj,'figure');
            res=matlab.ui.container.Menu.empty;

            if isempty(hFig)||~isvalid(hFig)
                varargout{1}=res;
                return;
            end

            hPlotEdit=plotedit(hFig,'getmode');
            hMode=hPlotEdit.ModeStateData.PlotSelectMode;
            hMenu=hMode.UIContextMenu;

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.internal.OneDimensional.pinuicontextmenu*');
            if~isempty(res)
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end



            res=matlab.ui.container.Menu.empty;

            res(end+1)=uimenu(hMenu,...
            'HandleVisibility','off',...
            'Label',getString(message('MATLAB:uistring:scribemenu:PinToAxes')),...
            'Visible','off','Tag','matlab.graphics.shape.internal.OneDimensional.pinuicontextmenu.PinToAxes',...
            'Callback',{@localPinObject,hMode});

            res(end+1)=uimenu(hMenu,...
            'HandleVisibility','off',...
            'Label',getString(message('MATLAB:uistring:scribemenu:Unpin')),...
            'Visible','off','Tag','matlab.graphics.shape.internal.OneDimensional.pinuicontextmenu.Unpin',...
            'Callback',{@localUnpinObject,hMode});


            varargout{1}=res;

            function localPinObject(~,~,hMode)


                hFig=hMode.FigureHandle;


                hObj=hMode.ModeStateData.SelectedObjects(1);




                point=get(hFig,'CurrentPoint');
                point=hgconvertunits(hFig,[point,0,0],get(hFig,'Units'),'Normalized',hFig);
                point=point(1:2);
                endPoint1=[hObj.X(1),hObj.Y(1)];
                endPoint1=hgconvertunits(hFig,[endPoint1,0,0],get(hObj,'Units'),'Normalized',hFig);
                endPoint1=endPoint1(1:2);
                endPoint2=[hObj.X(2),hObj.Y(2)];
                endPoint2=hgconvertunits(hFig,[endPoint2,0,0],get(hObj,'Units'),'Normalized',hFig);
                endPoint2=endPoint2(1:2);


                d1=sqrt((point(1)-endPoint1(1))^2+(point(2)-endPoint1(2))^2)+1e-5;
                d2=sqrt((point(1)-endPoint2(1))^2+(point(2)-endPoint2(2))^2)+1e-5;

                if abs(d1/d2)>4
                    hObj.pinAtAffordance(2);
                    pinnedAffordance=2;
                elseif abs(d2/d1)>4
                    hObj.pinAtAffordance(1);
                    pinnedAffordance=1;
                else
                    hObj.pinAtAffordance(1);
                    hObj.pinAtAffordance(2);
                    pinnedAffordance=[1,2];
                end


                proxyValue=hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles==hObj);




                cmd.Name='Pin to Axes';
                cmd.Function=@localPinObjectUndo;
                cmd.Varargin={hMode,proxyValue,pinnedAffordance};
                cmd.InverseFunction=@localUnpinObjectUndo;
                cmd.InverseVarargin={hMode,proxyValue,pinnedAffordance};


                uiundo(hFig,'function',cmd);
            end

            function localPinObjectUndo(hMode,proxyValue,pinnedAffordance)


                hObj=hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy==proxyValue);
                for i=1:length(pinnedAffordance)
                    hObj.pinAtAffordance(pinnedAffordance(i));
                end
            end

            function localUnpinObject(~,~,hMode)


                hFig=hMode.FigureHandle;


                hObj=hMode.ModeStateData.SelectedObjects(1);




                point=get(hFig,'CurrentPoint');
                point=hgconvertunits(hFig,[point,0,0],get(hFig,'Units'),'Normalized',hFig);
                point=point(1:2);
                endPoint1=[hObj.X(1),hObj.Y(1)];
                endPoint1=hgconvertunits(hFig,[endPoint1,0,0],get(hObj,'Units'),'Normalized',hFig);
                endPoint1=endPoint1(1:2);
                endPoint2=[hObj.X(2),hObj.Y(2)];
                endPoint2=hgconvertunits(hFig,[endPoint2,0,0],get(hObj,'Units'),'Normalized',hFig);
                endPoint2=endPoint2(1:2);


                d1=sqrt((point(1)-endPoint1(1))^2+(point(2)-endPoint1(2))^2)+1e-5;
                d2=sqrt((point(1)-endPoint2(1))^2+(point(2)-endPoint2(2))^2)+1e-5;

                if abs(d1/d2)>4
                    hObj.unpinAtAffordance(2);
                    pinnedAffordance=2;
                elseif abs(d2/d1)>4
                    hObj.unpinAtAffordance(1);
                    pinnedAffordance=1;
                else
                    hObj.unpinAtAffordance(1);
                    hObj.unpinAtAffordance(2);
                    pinnedAffordance=[1,2];
                end


                proxyValue=hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles==hObj);




                cmd.Name='Unpin';
                cmd.Function=@localUninObjectUndo;
                cmd.Varargin={hMode,proxyValue,pinnedAffordance};
                cmd.InverseFunction=@localPinObjectUndo;
                cmd.InverseVarargin={hMode,proxyValue,pinnedAffordance};


                uiundo(hFig,'function',cmd);
            end

            function localUnpinObjectUndo(hMode,proxyValue,pinnedAffordance)


                hObj=hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy==proxyValue);
                for i=1:length(pinnedAffordance)
                    hObj.unpinAtAffordance(pinnedAffordance(i));
                end
            end
        end
    end
    methods(Access='protected',Hidden=true)
        function updateMarkers(hObj,updateState)



            vertexData=getSelectionMarkerPos(hObj,updateState);

            hMarkers=hObj.Srect;

            set(hMarkers(1),'VertexData',vertexData(:,1));

            set(hMarkers(2),'VertexData',vertexData(:,2));

            isVisible='on';
            if strcmpi(hObj.Selected,'off')||strcmpi(hObj.SelectionHighlight,'off')
                isVisible='off';
            end
            set(hMarkers,'Visible',isVisible);


        end
    end
    methods(Access='public',Hidden=true)
        function resize(hObj,currPoint)

            [fig,container]=getContainers(hObj);
            if isempty(fig)||isempty(container)
                return;
            end


            currPoint=hgconvertunits(fig,[currPoint,0,0],'pixels',hObj.Units,container);
            currPoint=currPoint(1:2);


            switch hObj.MoveStyle
            case 'bottomleft'
                hObj.X=[currPoint(1),hObj.X(2)];
                hObj.Y=[currPoint(2),hObj.Y(2)];
            case 'topright'
                hObj.X=[hObj.X(1),currPoint(1)];
                hObj.Y=[hObj.Y(1),currPoint(2)];
            otherwise
                return;
            end

        end
    end
    methods(Access='protected',Hidden=true)
        function updatePositionFromPin(hObj,hPin,updateState)
            if isempty(hPin)||~isvalid(hPin)
                return;
            end

            affNum=hPin.UserData;


            [fig,container]=getContainers(hObj);
            pixPos=hPin.getPixelLocation(container);


            newPos=updateState.convertUnits('camera',hObj.Units,'pixels',pixPos);


            newX=hObj.X;
            newX(affNum)=newPos(1);
            hObj.X=newX;

            newY=hObj.Y;
            newY(affNum)=newPos(2);
            hObj.Y=newY;

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getSelectionMarkerPos(hObj,updateState)

            iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            iter.XData=hObj.NormX;
            iter.YData=hObj.NormY;
            iter.ZData=[0;0];
            varargout{1}=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,iter);
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,code)
    end
    methods(Access='public',Hidden=true)

        getMcodeConstructor(hObj,code,ShapeType)
    end




end
