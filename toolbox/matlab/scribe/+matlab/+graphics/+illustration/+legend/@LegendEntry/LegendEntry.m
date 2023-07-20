classdef(Sealed)LegendEntry<matlab.graphics.primitive.world.Group&matlab.graphics.mixin.Selectable




    properties(Transient=true)


        Dirty logical=false;


        Object{mustBe_matlab_graphics_mixin_Legendable};


        Icon matlab.graphics.illustration.legend.LegendIcon


        Label matlab.graphics.illustration.legend.Text


        Index=0;


        Legend matlab.graphics.illustration.Legend;


        LayoutInfo matlab.graphics.illustration.legend.ItemLayoutInfo;


        Overlay matlab.graphics.primitive.world.TriangleStrip;


        OverlayAlpha=.65;


        PeerVisible matlab.internal.datatype.matlab.graphics.datatype.on_off='on';


        LegendEntryDirtyListener event.listener;
        VisibleListener event.proplistener;
        LegendColorListener event.proplistener;


        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=9;
        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    methods
        function hObj=LegendEntry(varargin)
            doSetup(hObj);
            if nargin==3
                hObj.Legend=varargin{1};
                hObj.Object=varargin{2};
                hObj.Index=varargin{3};
            end
        end

        function set.Color(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.Color=newValue;
        end

        function set.FontAngle(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.FontAngle=newValue;
        end

        function set.FontName(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.FontName=newValue;
        end

        function set.FontSize(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.FontSize=newValue;
        end

        function set.FontWeight(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.FontWeight=newValue;
        end

        function set.Interpreter(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.Interpreter=newValue;
        end

        function set.LayoutInfo(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.LayoutInfo=newValue;
        end

        function set.PeerVisible(hObj,newValue)
            hObj.MarkDirty('all');
            hObj.PeerVisible=newValue;
        end

        function set.Legend(hObj,newValue)
            function safeMarkDirty(~,~)
                if ishandle(hObj)
                    hObj.MarkDirty('all')
                end
            end

            hObj.LegendColorListener=event.proplistener(newValue,findprop(newValue,'Color'),'PostSet',@safeMarkDirty);
            hObj.Legend=newValue;
        end

        function set.Object(hObj,newValue)
            hObj.LegendEntryDirtyListener=event.listener(newValue,'LegendEntryDirty',@(h,e)doMarkDirty(hObj));
            hObj.VisibleListener=event.proplistener(newValue,findprop(newValue,'Visible'),'PostSet',@(h,e)doMarkDirty(hObj));
            hObj.PeerVisible=newValue.Visible;
            hObj.Object=newValue;
        end

        function set.Icon(hObj,newValue)
            delete(hObj.Icon);
            if~isempty(newValue)
                hObj.addNode(newValue);
            end
            hObj.Icon=newValue;
        end

        function set.Label(hObj,newValue)
            delete(hObj.Label);
            if~isempty(newValue)
                hObj.addNode(newValue);
            end
            hObj.Label=newValue;
        end

        function set.Overlay(hObj,newValue)
            delete(hObj.Overlay);
            if~isempty(newValue)
                hObj.addNode(newValue);
            end
            hObj.Overlay=newValue;
        end

        function doMarkDirty(hObj)


            if ishandle(hObj)
                if ishandle(hObj.Legend)
                    doMethod(hObj.Legend,'doMarkDirty','all');
                end
                hObj.MarkDirty('all');
                hObj.Dirty=true;
            end
        end

        function addIcon(hObj,newIcon)
            hObj.Icon=newIcon;
        end

        function addLabel(hObj,newLabel)
            hObj.Label=newLabel;
        end

        function doUpdate(hObj,us)

            label=hObj.Label;
            label.Color=hObj.Color;
            label.FontAngle=hObj.FontAngle;
            label.FontName=hObj.FontName;
            label.FontSize=hObj.FontSize;
            label.FontWeight=hObj.FontWeight;
            label.Interpreter=hObj.Interpreter;


            if isvalid(hObj.Object)
                label.String=hObj.Object.getDisplayNameForInterpreter(hObj.Legend.Interpreter);
            end


            if strcmp(hObj.PeerVisible,'on')
                hObj.Overlay.Visible='off';
            else




                bc=getBackgroundColor(hObj.Legend);
                if isnumeric(bc)&&hObj.Legend.PrintAlphaSupported


                    hObj.Overlay.Visible='on';
                    hObj.Overlay.ColorData(1:3)=uint8(255*bc);
                    hObj.Overlay.ColorData(4)=uint8(255*hObj.OverlayAlpha);
                else




                    hObj.Overlay.Visible='off';




                    if~isnumeric(bc)
                        ax=hObj.Legend.Axes;
                        if isvalid(ax)
                            bc=hObj.Legend.Axes.getBackgroundColor();
                        end



                        if~isnumeric(bc)
                            bc=us.BackgroundColor;
                        end
                    end



                    alpha=hObj.OverlayAlpha;
                    overlay_rgb=bc;
                    current_text_rgb=hObj.Label.Color;
                    new_text_rgb=overlay_rgb*alpha+current_text_rgb*(1-alpha);
                    hObj.Label.Color=new_text_rgb;
                end
            end


            li=hObj.LayoutInfo;
            if~isempty(li)
                le=li.LeftEdge;
                ri=li.RightEdge;
                bo=li.BottomEdge;
                to=li.TopEdge;
                hObj.Overlay.VertexData=single([le,le,ri,ri;bo,to,bo,to;0,0,0,0]);
            end

        end
    end

    methods(Access=private)
        function doSetup(hObj)
            hObj.HitTest='off';
            hObj.Serializable='off';


            ic=matlab.graphics.illustration.legend.LegendIcon;
            hObj.Icon=ic;


            la=matlab.graphics.illustration.legend.Text;
            hObj.Label=la;


            ts=matlab.graphics.primitive.world.TriangleStrip;
            ts.VertexData=single([0,0,1,1;0,1,0,1;0,0,0,0]);
            ts.StripData=uint32([1,5]);
            ts.ColorData=uint8([255;255;255;0]);
            ts.ColorType='truecoloralpha';
            ts.ColorBinding='object';
            ts.Layer='front';
            hObj.Overlay=ts;
        end
    end
end

function mustBe_matlab_graphics_mixin_Legendable(input)
    if~isa(input,'matlab.graphics.mixin.Legendable')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.graphics.mixin.Legendable').getString));
    end
end
