
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Hidden=true)TwoDimensional<matlab.graphics.shape.internal.ScribeObject&matlab.graphics.internal.GraphicsJavaVisible




    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            b=false;
        end
    end





    methods
        function hObj=TwoDimensional(varargin)








            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end



    methods(Access='protected',Hidden=true)
        function varargout=setPinImpl(hObj,newValue)

            if isempty(newValue)
                varargout{1}=newValue;
            else
                varargout{1}=newValue(end);
            end

        end
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)






            for i=1:9
                hAf(i)=matlab.graphics.primitive.world.Marker;
            end

            descriptions={'bottomleft','topright','bottomright','topleft','left',...
            'bottom','right','top','center'};
            for i=1:numel(hAf)
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



            hObj.PinAff=int8(1);
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

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.internal.TwoDimensional.pinuicontextmenu*');
            if~isempty(res)
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end



            res=matlab.ui.container.Menu.empty;

            res(end+1)=uimenu(hMenu,...
            'HandleVisibility','off',...
            'Label',getString(message('MATLAB:uistring:scribemenu:PinToAxes')),...
            'Visible','off','Tag','matlab.graphics.shape.internal.TwoDimensional.pinuicontextmenu.PinToAxes',...
            'Callback',{@localPinObject,hMode});

            res(end+1)=uimenu(hMenu,...
            'HandleVisibility','off',...
            'Label',getString(message('MATLAB:uistring:scribemenu:Unpin')),...
            'Visible','off','Tag','matlab.graphics.shape.internal.TwoDimensional.pinuicontextmenu.Unpin',...
            'Callback',{@localUnpinObject,hMode});

            varargout{1}=res;

            function localPinObject(~,~,hMode)


                hFig=hMode.FigureHandle;


                hObj=hMode.ModeStateData.SelectedObjects(1);


                pinnedAffordance=hObj.PinAff;
                hObj.pinAtAffordance(pinnedAffordance);


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

                hPin=hObj.Pin;

                if isempty(hPin)
                    return;
                end

                pinnedAffordance=hObj.PinAff;
                hObj.unpinAtAffordance(pinnedAffordance);


                proxyValue=hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles==hObj);




                cmd.Name='Unpin';
                cmd.Function=@localUnpinObjectUndo;
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




            hMarkers=hObj.Srect;

            isVisible='on';





            if strcmpi(hObj.Selected,'off')||strcmpi(hObj.SelectionHighlight,'off')
                isVisible='off';
            end

            vertexData=getSelectionMarkerPos(hObj,updateState);

            for i=1:length(hMarkers)
                set(hMarkers(i),'VertexData',vertexData(:,i));
            end

            set(hMarkers,'Visible',isVisible);

            set(hMarkers(9),'Visible','off');

            if(isprop(hObj,'Transform'))
                set(hMarkers,'Parent',[]);
                set(hMarkers,'Parent',hObj.Transform);
            end

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getAffordanceLocation(hObj,affNum,position)


            lx=position(1);rx=position(1)+position(3);cx=position(1)+position(3)/2;
            px=[lx,rx,rx,lx,lx,cx,rx,cx,cx];
            uy=position(2);ly=position(2)+position(4);cy=position(2)+position(4)/2;
            py=[uy,ly,uy,ly,cy,uy,cy,ly,cy];
            varargout{1}=[px(affNum),py(affNum)];
        end
    end
    methods(Access='public',Hidden=true)
        function resize(hObj,currPoint)

            [fig,container]=getContainers(hObj);
            if isempty(fig)||isempty(container)
                return;
            end





            pos=hgconvertunits(fig,hObj.Position,hObj.Units,'pixels',container);
            XL=pos(1);
            XR=pos(1)+pos(3);
            YU=pos(2)+pos(4);
            YL=pos(2);



            switch hObj.MoveStyle
            case 'topleft'
                if currPoint(1)>XR
                    if currPoint(2)<YL
                        hObj.MoveStyle='bottomright';
                        XL=XR;
                        YU=YL;
                    else
                        hObj.MoveStyle='topright';
                        XL=XR;
                    end
                elseif currPoint(2)<YL
                    hObj.MoveStyle='bottomleft';
                    YU=YL;
                end
            case 'topright'
                if currPoint(1)<XL
                    if currPoint(2)<YL
                        hObj.MoveStyle='bottomleft';
                        XR=XL;
                        YU=YL;
                    else
                        hObj.MoveStyle='topleft';
                        XR=XL;
                    end
                elseif currPoint(2)<YL
                    hObj.MoveStyle='bottomright';
                    YU=YL;
                end
            case 'bottomright'
                if currPoint(1)<XL
                    if currPoint(2)>YU
                        hObj.MoveStyle='topleft';
                        XR=XL;
                        YL=YU;
                    else
                        hObj.MoveStyle='bottomleft';
                        XR=XL;
                    end
                elseif currPoint(2)>YU
                    hObj.MoveStyle='topright';
                    YL=YU;
                end
            case 'bottomleft';
                if currPoint(1)>XR
                    if currPoint(2)>YU
                        hObj.MoveStyle='topright';
                        XL=XR;
                        YL=YU;
                    else
                        hObj.MoveStyle='bottomright';
                        XL=XR;
                    end
                elseif currPoint(2)>YU
                    hObj.MoveStyle='topleft';
                    YL=YU;
                end
            case 'left'
                if currPoint(1)>XR
                    hObj.MoveStyle='right';
                    XL=XR;
                end
            case 'top'
                if currPoint(2)<YL
                    hObj.MoveStyle='bottom';
                    YU=YL;
                end
            case 'right'
                if currPoint(1)<XL
                    hObj.MoveStyle='left';
                    XR=XL;
                end
            case 'bottom'
                if currPoint(2)>YU
                    hObj.MoveStyle='top';
                    YL=YU;
                end
            otherwise
            end


            switch hObj.MoveStyle
            case 'topleft'


                XL=currPoint(1);
                YU=currPoint(2);
            case 'topright'
                XR=currPoint(1);
                YU=currPoint(2);
            case 'bottomright'
                XR=currPoint(1);
                YL=currPoint(2);
            case 'bottomleft';
                XL=currPoint(1);
                YL=currPoint(2);
            case 'left'
                XL=currPoint(1);
            case 'top'
                YU=currPoint(2);
            case 'right'
                XR=currPoint(1);
            case 'bottom'
                YL=currPoint(2);
            otherwise
                return;
            end


            newPos=[XL,YL,XR-XL,YU-YL];

            hObj.Position=hgconvertunits(fig,newPos,'pixels',hObj.Units,container);
        end
    end
    methods(Access='protected',Hidden=true)
        function updatePositionFromPin(hObj,hPin,updateState)


            if isempty(hPin)||~isvalid(hPin)
                return;
            end

            affNum=hPin.UserData;
            [hFig,hContainer]=getContainers(hObj);
            pixPos=hPin.getPixelLocation(hContainer);


            hAff=hObj.Srect(affNum);

            posRect=updateState.convertUnits('camera','pixels',hObj.Units,hObj.Position);



            switch get(hAff,'Description')
            case 'topleft'
                posRect(1)=pixPos(1);
                posRect(2)=pixPos(2)-posRect(4);
            case 'topright'
                posRect(1)=pixPos(1)-posRect(3);
                posRect(2)=pixPos(2)-posRect(4);
            case 'bottomright'
                posRect(1)=pixPos(1)-posRect(3);
                posRect(2)=pixPos(2);
            case 'bottomleft'
                posRect(1)=pixPos(1);
                posRect(2)=pixPos(2);
            case 'left'
                posRect(1)=pixPos(1);
                posRect(2)=pixPos(2)-posRect(4)/2;
            case 'top'
                posRect(1)=pixPos(1)-posRect(3)/2;
                posRect(2)=pixPos(2)-posRect(4);
            case 'right'
                posRect(1)=pixPos(1)-posRect(3);
                posRect(2)=pixPos(2)-posRect(4)/2;
            case 'bottom'
                posRect(1)=pixPos(1)-posRect(3)/2;
                posRect(2)=pixPos(2);
            case 'center'
                posRect(1)=pixPos(1)-posRect(3)/2;
                posRect(2)=pixPos(2)-posRect(4)/2;
            end

            pos=updateState.convertUnits('camera',hObj.Units,'pixels',posRect);

            set(hObj,'Position',pos);

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getSelectionMarkerPos(hObj,updateState)


            normPos=hObj.NormalizedPosition;

            lx=normPos(1);rx=normPos(1)+normPos(3);cx=normPos(1)+normPos(3)/2;
            px=[lx,rx,rx,lx,lx,cx,rx,cx,cx];
            uy=normPos(2);ly=normPos(2)+normPos(4);cy=normPos(2)+normPos(4)/2;
            py=[uy,ly,uy,ly,cy,uy,cy,ly,cy];
            hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            hIter.XData=px;
            hIter.YData=py;
            varargout{1}=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,hIter);
        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getTransformationMatrix(hObj,updateState)


            pos=hObj.NormalizedPosition;


            tx=makehgtform('translate',[-pos(1),-pos(2),0]);




            ar=updateState.CameraAspectRatio;
            s=makehgtform('scale',[1,ar,1]);


            r=makehgtform('zrotate',deg2rad(hObj.Rotation));


            s_inverse=makehgtform('scale',[1,1/ar,1]);


            tx_inverse=makehgtform('translate',[pos(1),pos(2),0]);


            tform=tx_inverse*s_inverse*r*s*tx;

            varargout{1}=tform;

        end
    end
    methods(Access='public',Hidden=true)

        getMcodeConstructor(hObj,code,ShapeType)
    end




end
