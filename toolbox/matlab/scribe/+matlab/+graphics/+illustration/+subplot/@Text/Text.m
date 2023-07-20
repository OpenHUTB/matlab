classdef(ConstructOnLoad,Sealed)Text<matlab.graphics.primitive.world.Group...
    &matlab.graphics.mixin.UIParentable...
    &matlab.graphics.mixin.Selectable...
    &matlab.graphics.internal.Legacy...
    &matlab.graphics.internal.GraphicsJavaVisible





    properties(Hidden,NonCopyable,Transient,Access={?tSubplotText})
        Camera matlab.graphics.axis.camera.Camera2D;
        SelectionHandle matlab.graphics.interactor.ListOfPointsHighlight;
    end


    properties(Hidden,DeepCopy,Access='private')
        TextComp matlab.graphics.primitive.Text;
    end


    properties(Hidden,NonCopyable,Transient,Access={?tSubplotText})
        Initialized=false;
    end


    properties(Hidden,Dependent)
        SubplotAdjustment matlab.internal.datatype.matlab.graphics.datatype.Inset;
    end


    properties(Hidden,Access={?tSubplotText})
        FontSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=13;
        SubplotAdjustment_I;
        SubplotBounds matlab.internal.datatype.matlab.graphics.datatype.Position=[0.13,0.11,0.775,0.815];
        Padding matlab.internal.datatype.matlab.graphics.datatype.Positive=5;
    end


    properties(AffectsObject,Dependent)
        BackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=13;
        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
        FontUnits matlab.internal.datatype.matlab.graphics.datatype.FontUnits='points';
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        Margin matlab.internal.datatype.matlab.graphics.datatype.Positive=3;
        String matlab.internal.datatype.matlab.graphics.datatype.NumericOrString='';
    end

    properties(AffectsObject,NeverAmbiguous)
        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(AffectsObject)
        HorizontalAlignment matlab.internal.datatype.matlab.graphics.datatype.HorizontalAlignment='center';
    end


    methods(Hidden,Access={?tSubplotText})
        function pos=getTextCompPosition(hObj)
            pos=hObj.TextComp.Position(1:2);
            pos=pos.*0.5+0.5;
        end
    end


    methods(Access='public',Hidden)

        function actualValue=setParentImpl(hObj,proposedValue)

            actualValue=hObj.setParentImpl@matlab.graphics.mixin.UIParentable(proposedValue);

            if(isa(proposedValue,'matlab.ui.Figure')||...
                isa(proposedValue,'matlab.ui.container.Panel')||...
                isa(proposedValue,'matlab.ui.container.Tab'))


                if~isempty(hObj.Parent)
                    if isappdata(hObj.Parent,'SubplotGridTitle')
                        rmappdata(hObj.Parent,'SubplotGridTitle');
                        subplotlayoutInvalid(hObj,[],hObj.Parent);
                    end
                end

                hObj.setupAppData(proposedValue);
            end
        end

        function setupAppData(hObj,appDataObject)



            if~isempty(appDataObject)&&isvalid(appDataObject)

                setappdata(appDataObject,'SubplotGridTitle',hObj);

                if~isappdata(appDataObject,'SubplotListenersManager')
                    lm=matlab.graphics.internal.SubplotListenersManager(0);

                    setappdata(appDataObject,'SubplotListeners',[]);
                else
                    lm=getappdata(appDataObject,'SubplotListenersManager');
                end


                lm.addTitle(hObj);
                setappdata(appDataObject,'SubplotListenersManager',lm);
            end
        end

        function delete(hObj)
            if~isempty(hObj.Parent)&&isvalid(hObj.Parent)
                if isappdata(hObj.Parent,'SubplotGridTitle')
                    rmappdata(hObj.Parent,'SubplotGridTitle')
                end

                if isappdata(hObj.Parent,'SubplotListenersManager')
                    lm=getappdata(hObj.Parent,'SubplotListenersManager');
                    lm.removeTitle(hObj);


                    if isempty(lm.ContainerListeners)&&...
                        isempty(lm.AxesListeners)&&...
                        isempty(lm.AxesPropertyListeners)&&...
                        isempty(lm.TitleListener)

                        rmappdata(hObj.Parent,'SubplotListenersManager')
                    end
                end
            end

            subplotlayoutInvalid(handle(hObj),[],hObj.Parent);
        end


        function doUpdate(hObj,updateState)

            if(~hObj.Initialized)
                hObj.init();
            end





            pointToNorm=updateState.convertUnits(...
            'canvas','normalized','points',[1.0,1.0,1.0,1.0]);

            layoutValues=matlab.graphics.internal.getSuggestedLayoutValues(updateState);

            if strcmp(hObj.FontSizeMode,'auto')&&strcmp(hObj.FontUnits,'points')
                hObj.FontSize_I=layoutValues.CanvasTitleFontSize;
            end

            hObj.Padding=layoutValues.CanvasDecorationPadding(2);

            subplotBoundsYMax=hObj.SubplotBounds(2)+hObj.SubplotBounds(4);
            textPosNorm=subplotBoundsYMax+pointToNorm(4)*hObj.Padding;

            font=matlab.graphics.general.Font(...
            'Name',hObj.TextComp.FontName,...
            'Size',hObj.TextComp.FontSize,...
            'Weight',hObj.TextComp.FontWeight);

            try
                stringBounds=updateState.getStringBounds(...
                hObj.TextComp.String,font,hObj.Interpreter,'on');
            catch
                stringBounds=updateState.getStringBounds(...
                hObj.TextComp.String,font,'none','on');
            end

            stringSizeNorm=updateState.convertUnits(...
            'canvas','normalized','pixels',...
            [0,0,stringBounds.*updateState.PixelsPerPoint]);

            diff=(textPosNorm+stringSizeNorm(4))-(1.0-(pointToNorm(4)*hObj.Padding));

            if(diff>0)
                textPosNorm=textPosNorm-diff;
            end

            hObj.SubplotAdjustment_I(4)=1.0-(textPosNorm-(pointToNorm(4)*hObj.Padding));
            hObj.TextComp.Position_I(2)=(textPosNorm-0.5)*2.0;


            if strcmp(hObj.HorizontalAlignment,'center')
                p1x=hObj.TextComp.Position_I(1)+stringSizeNorm(3);
                p2x=hObj.TextComp.Position_I(1)-stringSizeNorm(3);
            elseif strcmp(hObj.HorizontalAlignment,'right')
                p1x=hObj.TextComp.Position_I(1);
                p2x=hObj.TextComp.Position_I(1)-stringSizeNorm(3)*2.0;
            else
                p1x=hObj.TextComp.Position_I(1);
                p2x=hObj.TextComp.Position_I(1)+stringSizeNorm(3)*2.0;
            end

            p1y=hObj.TextComp.Position_I(2);
            p2y=hObj.TextComp.Position_I(2)+stringSizeNorm(4)*2.0;

            hObj.SelectionHandle.VertexData=single([p1x,p1x,p2x,p2x;...
            p1y,p2y,p2y,p1y;...
            0,0,0,0]);

            if strcmp(hObj.Visible,'on')&&...
                strcmp(hObj.Selected,'on')&&...
                strcmp(hObj.SelectionHighlight,'on')
                hObj.SelectionHandle.Visible='on';
            else
                hObj.SelectionHandle.Visible='off';
            end
        end
    end


    methods

        function val=get.BackgroundColor(hObj)
            val=hObj.TextComp.BackgroundColor;
        end


        function set.BackgroundColor(hObj,val)
            hObj.TextComp.BackgroundColor=val;
        end


        function val=get.Color(hObj)
            val=hObj.TextComp.Color;
        end


        function set.Color(hObj,val)
            hObj.TextComp.Color=val;
        end


        function val=get.EdgeColor(hObj)
            val=hObj.TextComp.EdgeColor;
        end


        function set.EdgeColor(hObj,val)
            hObj.TextComp.EdgeColor=val;
        end


        function val=get.FontAngle(hObj)
            val=hObj.TextComp.FontAngle;
        end


        function set.FontAngle(hObj,val)
            hObj.TextComp.FontAngle=val;
        end


        function val=get.FontName(hObj)
            val=hObj.TextComp.FontName;
        end


        function set.FontName(hObj,val)
            hObj.TextComp.FontName=val;
        end


        function val=get.FontSize(hObj)
            val=hObj.TextComp.FontSize;
        end


        function set.FontSize(hObj,val)
            hObj.FontSize_I=val;
            hObj.FontSizeMode='manual';
        end


        function val=get.FontSize_I(hObj)
            val=hObj.FontSize_I;
        end

        function set.FontSize_I(hObj,val)
            hObj.FontSize_I=val;
            hObj.TextComp.FontSize=val;%#ok<INUSD>
        end


        function val=get.FontUnits(hObj)
            val=hObj.TextComp.FontUnits;
        end


        function set.FontUnits(hObj,val)
            hObj.TextComp.FontUnits=val;
        end


        function val=get.FontWeight(hObj)
            val=hObj.TextComp.FontWeight;
        end


        function set.FontWeight(hObj,val)
            hObj.TextComp.FontWeight=val;
        end


        function set.HorizontalAlignment(hObj,val)
            hObj.HorizontalAlignment=val;
            hObj.updatePositionAndAlignment();
        end


        function val=get.Interpreter(hObj)
            val=hObj.TextComp.Interpreter;
        end


        function set.Interpreter(hObj,val)
            hObj.TextComp.Interpreter=val;
        end


        function val=get.LineStyle(hObj)
            val=hObj.TextComp.LineStyle;
        end


        function set.LineStyle(hObj,val)
            hObj.TextComp.LineStyle=val;
        end


        function val=get.LineWidth(hObj)
            val=hObj.TextComp.LineWidth;
        end


        function set.LineWidth(hObj,val)
            hObj.TextComp.LineWidth=val;
        end


        function val=get.Margin(hObj)
            val=hObj.TextComp.Margin;
        end


        function set.Margin(hObj,val)
            hObj.TextComp.Margin=val;
        end


        function val=get.String(hObj)
            val=hObj.TextComp.String;
        end


        function set.String(hObj,val)
            hObj.TextComp.String=val;
        end


        function val=get.SubplotAdjustment(hObj)
            forceFullUpdate(hObj,'all','SubplotAdjustment');
            val=hObj.SubplotAdjustment_I;
        end


        function set.SubplotAdjustment(hObj,val)
            hObj.SubplotAdjustment_I=val;
        end

        function mcodeConstructor(hObj,code)

            setConstructorName(code,'sgtitle')


            arg=codegen.codeargument('Name','parent','Value',hObj.Parent,...
            'IsParameter',true,'Comment','Parent container');
            addConstructorArgin(code,arg);
            ignoreProperty(code,'Parent');


            arg=codegen.codeargument('Name','string','Value',hObj.String,...
            'IsParameter',false,'Comment','Title string');
            addConstructorArgin(code,arg);
            ignoreProperty(code,'String');

            generateDefaultPropValueSyntax(code);
        end

        function hObj=Text()
            hObj.Camera=matlab.graphics.axis.camera.Camera2D;
            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight;
            hObj.TextComp=matlab.graphics.primitive.Text;
            doSetup(hObj)
        end
    end


    methods(Access='protected',Hidden=true)
        function pg=getPropertyGroups(~)
            pg=matlab.mixin.util.PropertyGroup(...
            {'String','FontSize','FontWeight','FontName','Color','Interpreter'});
        end

        function str=getDescriptiveLabelForDisplay(hObj)
            str=hObj.String;
        end
    end

    methods(Access='private',Hidden=true)

        function dirtySubplotLayout(hObj,e)
            subplotlayoutInvalid(hObj,e,hObj.Parent);
        end

        function updatePositionAndAlignment(hObj)

            alignment=hObj.HorizontalAlignment;
            bounds=hObj.SubplotBounds;

            if strcmp(alignment,'left')
                hObj.TextComp.HorizontalAlignment='left';
                hObj.TextComp.Position_I(1)=(bounds(1)-0.5)*2.0;
            elseif strcmp(alignment,'right')
                hObj.TextComp.HorizontalAlignment='right';
                hObj.TextComp.Position_I(1)=(bounds(1)+bounds(3)-0.5)*2.0;
            else
                hObj.TextComp.HorizontalAlignment='center';
                hObj.TextComp.Position_I(1)=0.0;
            end
        end

        function init(hObj)





            if isempty(hObj.Parent)||~isvalid(hObj.Parent)
                return;
            end


            hObj.TextComp.Parent=hObj.Camera;
            hObj.SelectionHandle.Parent=hObj.Camera;

            addlistener(hObj,'MarkedDirty',@(~,e)hObj.dirtySubplotLayout(e));

            hObj.addDependencyConsumed({'view','ref_frame'});





            if~isappdata(hObj.Parent,'SubplotDefaultAxesLocation')
                if~strcmp(get(hObj.Parent,'DefaultAxesUnits'),'normalized')
                    tmp=axes;
                    tmp.Units='normalized';
                    hObj.SubplotBounds=tmp.InnerPosition;
                    delete(tmp)
                else
                    hObj.SubplotBounds=get(hObj.Parent,'DefaultAxesPosition');
                end
                setappdata(hObj.Parent,'SubplotDefaultAxesLocation',hObj.SubplotBounds);
            else
                hObj.SubplotBounds=getappdata(hObj.Parent,'SubplotDefaultAxesLocation');
            end

            hObj.updatePositionAndAlignment();

            hObj.Initialized=true;

            subplotlayoutInvalid(hObj,[],hObj.Parent);
        end

        function doSetup(hObj)

            hObj.Camera.Internal=true;
            hObj.addNode(hObj.Camera);

            hObj.Type='subplottext';
            hObj.TextComp.HorizontalAlignment='center';
            hObj.TextComp.VerticalAlignment='bottom';
            hObj.TextComp.HitTest='off';
            hObj.TextComp.FontSize=13;
            hObj.SelectionHandle.VertexData=single(0.5*[-1,-1,1,1;...
            -1,1,1,-1;...
            0,0,0,0]);
            hObj.SelectionHandle.Visible='off';
        end

    end
end


