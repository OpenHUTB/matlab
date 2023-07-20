classdef polariReadout<handle


    properties

        Parent=[]


        TagName='polariReadout'

ContextMenuFcn







        ReadoutPositionPriority=1





        FontRelSize=0


        FontName=''
    end

    properties(Dependent)



Text

Visible
    end

    properties(Access=?internal.polari)
hText
    end

    properties
        NormalBackgroundColor='w'
NormalForegroundColor
    end

    properties(Access=private)
PolariObj
Listeners
hAnchor

pLastFigSize







pCurrentQuadrant

HiliteBackgroundColor
HiliteForegroundColor



        pAnchorOffset=1



pExtentDuringDrag
    end

    properties(Access=private,Constant)

        FontSizeLimits=[6,14]

        ReadoutPositionValues={'first','second','third'}















        ViewTable={...
        'right','top-left','bottom-left','bottom-right';
        'top-right','top-left','top','right';
        'full','top-left','top-right','bottom-right';
        'top','top-left','top-right','top';
        'left','top-left','left','bottom-left';
        'top-left','top-left','top','left';
        'bottom-left','left','bottom','bottom-left';
        'bottom','bottom-left','bottom','bottom-right';
        'bottom-right','right','bottom','bottom-right'}
    end

    methods
        function t=polariReadout(p)
            if nargin>0
                t.PolariObj=p;
            end
        end

        function delete(t)
            t.Listeners=internal.polariCommon.deleteListenerStruct(t.Listeners);



            delete(t.hText);
            delete(t.hAnchor);
        end

        function set.PolariObj(t,p)
            t.PolariObj=p;
            initFromAxes(t);
        end

        function set.Text(t,str)
            updateText(t,str);
        end

        function str=get.Text(t)
            str=t.hText.String;
        end

        function set.FontRelSize(t,val)
            t.FontRelSize=val;
            updateFont(t);
        end

        function set.Visible(t,vis)
            t.hText.Visible=vis;


            if strcmpi(vis,'off')
                t.hAnchor.Visible=vis;
            end
        end

        function val=get.Visible(t)
            val=t.hText.Visible;
        end

        function set.NormalBackgroundColor(t,val)
            internal.ColorConversion.validatecolorspec(val,...
            'polariReadout','NormalBackgroundColor');
            t.NormalBackgroundColor=val;


            h=t.hText;%#ok<MCSUP>
            if~isempty(h)
                h.BackgroundColor=val;
            end
        end

        function set.NormalForegroundColor(t,val)
            internal.ColorConversion.validatecolorspec(val,...
            'polariReadout','NormalForegroundColor');
            t.NormalForegroundColor=val;
        end

        function set.TagName(t,val)
            t.TagName=val;
            updateTagName(t);
        end

        function set.ReadoutPositionPriority(t,val)
            if~isscalar(val)||~isnumeric(val)||...
                val~=fix(val)||val<1||val>3
                error('ReadoutPositionPriority must be 1, 2 or 3.');
            end
            t.ReadoutPositionPriority=val;


            resetPositionBasedOnView(t);
        end

        function updatePosition(t,pos)


            t.hText.Position(1:2)=pos;
            constrainReadoutPosition(t);
        end

        function hoverOverReadoutChange(t,action)





            isStart=strcmpi(action,'start');
            hiliteReadout(t,isStart);
            if isStart

                t.pExtentDuringDrag=t.hText.Extent;
            else

                t.pExtentDuringDrag=[];
            end
        end
    end

    methods(Access=private)
        function position=getTextSize(self,uiobj)
            persistent axval;
            persistent txtObjval;
            if isempty(axval)||isempty(txtObjval)
                axval=uiaxes('Parent',[],'Units','pixels','Visible','off','Internal',true);
                txtObjval=text(axval,1,1,'','Units','pixels','FontUnits','pixels','Internal',true);
            end

            p=uiobj.Parent;
            axval.Parent=p;
            if~matlab.ui.internal.isUIFigure(p)
                txtObjval.String=uiobj.String;
            else
                txtObjval.String=uiobj.Text;
            end

            props=["FontName","FontSize","FontAngle","FontWeight"];
            for propi=1:length(props)
                txtObjval.(props(propi))=uiobj.(props(propi));
            end

            position=txtObjval.Extent;
            axval.Parent=[];

        end
        function initFromAxes(t)



            hax=t.PolariObj.hAxes;
            t.Parent=ancestor(hax,'figure');


            t.pLastFigSize=t.Parent.Position;

            initListeners(t);
            updateText(t);
            updateColorProps(t);
        end

        function updateTagName(t)





            tagStr=sprintf('%s%d',t.TagName,t.PolariObj.pAxesIndex);
            t.hAnchor.Tag=tagStr;
            t.hText.Tag=tagStr;
        end

        function updateColorProps(t)



            p=t.PolariObj;

            t.HiliteBackgroundColor=p.GridBackgroundColor;
            t.HiliteForegroundColor=p.MagnitudeTickLabelColor;
            t.NormalForegroundColor=p.MagnitudeTickLabelColor;





            h=t.hText;
            if~isempty(h)
                if~matlab.ui.internal.isUIFigure(t.Parent)
                    h.ForegroundColor=t.NormalForegroundColor;
                end
                h.BackgroundColor=t.NormalBackgroundColor;
            end
        end

        function initListeners(t)

            p=t.PolariObj;

            lis.ViewChanged=addlistener(p,...
            'ViewChanged',@(~,~)resetPositionBasedOnView(t));
            lis.FontChanged=addlistener(p,...
            'FontChanged',@(~,~)updateFont(t));
            lis.WindowResize=addlistener(t.Parent,...
            'SizeChanged',@(~,~)figureSizeChange(t));

            t.Listeners=lis;
        end

        function hiliteReadout(t,show)





            ht=t.hText;
            if show

                if~matlab.ui.internal.isUIFigure(t.Parent)
                    ht.ForegroundColor=t.HiliteForegroundColor;
                    t.hAnchor.Visible='on';
                end
                ht.BackgroundColor=t.HiliteBackgroundColor;

                updateAnchorPatchPos(t);

            else


                if~matlab.ui.internal.isUIFigure(t.Parent)
                    ht.ForegroundColor=t.HiliteForegroundColor;
                    t.hAnchor.Visible='off';
                end
                ht.BackgroundColor=t.NormalBackgroundColor;

            end
        end

        function callbackContextMenu(t,h,ev)






            cmFcn=t.ContextMenuFcn;
            if~isempty(cmFcn)
                cmFcn(h,ev);
            end
        end

        function createReadoutWidgets(t)



            p=t.PolariObj;
            hc=uicontextmenu(...
            'Parent',t.Parent,...
            'Callback',@(h,ev)callbackContextMenu(t,h,ev),...
            'HandleVisibility','off');




            gr=[1,1,1]*0;
            if~matlab.ui.internal.isUIFigure(t.Parent)
                ht=uicontrol(...
                'Parent',p.Parent,...
                'Style','frame',...
                'ForegroundColor',gr,...
                'BackgroundColor',gr,...
                'Enable','inactive',...
                'Units','pixels',...
                'Visible','off');
                t.hAnchor=ht;

                ht=uicontrol(...
                'Parent',p.Parent,...
                'Style','text',...
                'Enable','inactive',...
                'HorizontalAlignment','left',...
                'Units','pixels',...
                'UIContextMenu',hc,...
                'Visible','off');
                t.hText=ht;
            else
                ht=annotation(p.Parent,...
                'textbox','FitBoxToText','on','Visible','off');

                ht.BackgroundColor=gr;
                ht.Visible='off';
                ht.Units='pixels';
                t.hAnchor=ht;

                t.hText=ht;
            end

            updateTagName(t);
            resetPositionBasedOnView(t);
        end

        function resetPositionBasedOnView(t)







            ht=t.hText;
            if isempty(ht)
                return
            end


            p=t.PolariObj;
            hax=p.hAxes;
            o=hax.Units;
            hax.Units='pixels';
            axRef=hax.Position;
            hax.Units=o;


            pb=hax.PlotBoxAspectRatio;
            pbAR=pb(1)/pb(2);
            axAR=axRef(3)/axRef(4);
            axPos=axRef;
            if pbAR>axAR
                axPos(4)=axRef(3)/pbAR;
                axPos(2)=axRef(2)+(axRef(4)-axPos(4))/2;
            else
                axPos(3)=axRef(4)*pbAR;
                axPos(1)=axRef(1)+(axRef(3)-axPos(3))/2;
            end


            offX=10;
            offY=5;


            ht=t.hText;
            if strcmpi(ht.Type,'uilabel')
                txt=ht.Text;
            else
                txt=ht.String;
            end
            if isempty(txt)

                tdx=50;
                tdy=40;
            else
                if~matlab.ui.internal.isUIFigure(t.Parent)
                    ext=ht.Extent;
                else
                    ext=[10,10,75,75];
                end
                tdx=ext(3);
                tdy=ext(4);
            end





            theLoc=getDefaultReadoutPosition(t);
            theView=t.PolariObj.View;
            switch theLoc
            case 'top-left'
                pos=[axPos(1)+offX,axPos(2)+axPos(4)-offY-tdy];
                quad=2;

            case 'top'
                pos=[axPos(1)+axPos(3)/2-tdx/2,axPos(2)+axPos(4)-offY-tdy];
                quad=1;

            case 'top-right'
                pos=[axPos(1)+axPos(3)-offX-tdx,axPos(2)+axPos(4)-offY-tdy];
                quad=1;

            case 'left'
                pos=[axPos(1)+offX,axPos(2)+axPos(4)/2-tdy/2];
                quad=2;

            case 'right'
                pos=[axPos(1)+axPos(3)-offX-tdx,axPos(2)+axPos(4)/2-tdy/2];
                quad=1;

            case 'bottom-left'
                pos=[axPos(1)+offX,axPos(2)+offY];
                quad=3;

            case 'bottom'
                pos=[axPos(1)+axPos(3)/2,axPos(2)+offY];
                quad=3;

            case 'bottom-right'
                pos=[axPos(1)+axPos(3)-tdx+90,axPos(2)+offY];
                quad=4;

            otherwise
                error('unhandled readout position: %s',theView);
            end
            t.pCurrentQuadrant=quad;




            ht.Position(1:2)=pos;

            fn=t.FontName;
            if isempty(fn)
                fn=p.FontName;
            end
            ht.FontName=fn;

            lim=t.FontSizeLimits;
            ht.FontSize=min(lim(2),max(lim(1),p.FontSize+t.FontRelSize));

            updateTextBackgroundSize(t);
            constrainReadoutPosition(t);
        end

        function readoutLoc=getDefaultReadoutPosition(t)











            row=find(strcmpi(t.PolariObj.View,t.ViewTable(:,1)));
            assert(~isempty(row));


            col=1+t.ReadoutPositionPriority;

            readoutLoc=t.ViewTable{row,col};
        end

        function figureSizeChange(t)


            opos=t.pLastFigSize;
            pos=t.Parent.Position;
            t.pLastFigSize=pos;
            ht=t.hText;

            switch t.pCurrentQuadrant
            case 1


                ht.Position(1)=ht.Position(1)+pos(3)-opos(3);
                ht.Position(2)=ht.Position(2)+pos(4)-opos(4);

            case 2










                ht.Position(2)=ht.Position(2)+pos(4)-opos(4);

            case 3





            otherwise



                ht.Position(1)=ht.Position(1)+pos(3)-opos(3);
            end



        end

        function constrainReadoutPosition(t)


            fig=t.Parent;


            o=fig.Units;
            fig.Units='pixels';
            fpos=fig.Position;
            fig.Units=o;
            fig_xmax=fpos(3);
            fig_ymax=fpos(4);


            ht=t.hText;
            tpos=ht.Position;





            ext=t.pExtentDuringDrag;
            if isempty(ext)
                if~matlab.ui.internal.isUIFigure(t.Parent)
                    ext=ht.Extent;
                else
                    ext=[10,10,75,75];
                end
            end
            tx=tpos(1);
            ty=tpos(2);
            tdx=ext(3);
            tdy=ext(4);


            dx=0;
            if tx<1
                dx=1-tx;
            elseif tx+tdx>fig_xmax
                dx=fig_xmax-tx-tdx;
            end
            if dx~=0
                ht.Position(1)=ht.Position(1)+dx;
            end


            dy=0;
            if ty<1
                dy=1-ty;
            elseif ty+tdy>fig_ymax
                dy=fig_ymax-ty-tdy;
            end
            if dy~=0
                ht.Position(2)=ht.Position(2)+dy;
            end

            updateReadoutQuadrant(t);
            updateAnchorPatchPos(t);
        end

        function updateReadoutQuadrant(t)



            p=t.PolariObj;
            hax=p.hAxes;

            u=hax.Units;
            hax.Units='pixels';
            axpos=hax.Position;
            hax.Units=u;

            ax_origin=[axpos(1)+axpos(3)/2,axpos(2)+axpos(4)/2];


            tpos=t.hText.Position;
            tpos=[tpos(1)+tpos(3)/2,tpos(2)+tpos(4)/2];

            if tpos(1)>=ax_origin(1)
                if tpos(2)>=ax_origin(2)
                    quad=1;
                else
                    quad=4;
                end
            else
                if tpos(2)>=ax_origin(2)
                    quad=2;
                else
                    quad=3;
                end
            end

            if quad~=t.pCurrentQuadrant
                t.pCurrentQuadrant=quad;
                updateTextBackgroundSize(t);
            end
        end

        function updateTextBackgroundSize(t)









            ht=t.hText;
            if~matlab.ui.internal.isUIFigure(t.Parent)
                ht.Position(3:4)=ht.Extent(3:4);
            else

            end
...
...
...
...
...
...
...
            updateAnchorPatchPos(t);
        end

        function updateAnchorPatchPos(t)


            o=t.pAnchorOffset;
            pos=t.hText.Position;
            if~matlab.ui.internal.isUIFigure(t.Parent)
                t.hAnchor.Position=[pos(1)-o,pos(2)-o,pos(3)+2*o,pos(4)+2*o];
            end
        end
        function updateFont(t)




            p=t.PolariObj;
            ht=t.hText;

            if strcmpi(ht.Visible,'off')
                oext=zeros(1,4);
            else
                oext=[0,0,40,40];
            end


            fn=t.FontName;
            if isempty(fn)
                fn=p.FontName;
            end
            ht.FontName=fn;

            lim=t.FontSizeLimits;
            ht.FontSize=min(lim(2),max(lim(1),p.FontSize+t.FontRelSize));





            updateTextPositionBasedOnOrigExtent(t,oext);
        end

        function updateText(t,str)


            ht=t.hText;
            if isempty(ht)
                createReadoutWidgets(t);
                updateFont(t);
                ht=t.hText;


                if nargin<2
                    return
                end
            end




            if~matlab.ui.internal.isUIFigure(t.Parent)
                oext=ht.Extent;
            else
                oext=[10,10,75,75];
            end
            ht.String=str;
            updateTextPositionBasedOnOrigExtent(t,oext);
        end

        function updateTextPositionBasedOnOrigExtent(t,origExt)




            ht=t.hText;
            if~matlab.ui.internal.isUIFigure(t.Parent)
                ext=ht.Extent;
            else
                ext=[10,10,75,75];
            end

            if~matlab.ui.internal.isUIFigure(t.Parent)
                switch t.pCurrentQuadrant
                case 1


                    ht.Position=[...
                    max(1,ht.Position(1)+origExt(3)-ext(3))...
                    ,max(1,ht.Position(2)+origExt(4)-ext(4))...
                    ,ext(3:4)];
                case 2


                    ht.Position=[...
                    ht.Position(1)...
                    ,max(1,ht.Position(2)+origExt(4)-ext(4))...
                    ,ext(3:4)];
                case 3





                    ht.Position(3:4)=ext(3:4);
                otherwise


                    ht.Position=[...
                    max(1,ht.Position(1)+origExt(3)-ext(3))...
                    ,ht.Position(2)...
                    ,ext(3:4)];
                end
            else
                switch t.pCurrentQuadrant
                case 1


                    ht.Position(1:2)=[...
                    max(1,ht.Position(1)+origExt(3)-ext(3))...
                    ,max(1,ht.Position(2)+origExt(4)-ext(4))...
                    ];
                case 2


                    ht.Position(1:2)=[...
                    ht.Position(1)...
                    ,max(1,ht.Position(2)+origExt(4)-ext(4))...
                    ];
                case 3






                otherwise


                    ht.Position(1:2)=[...
                    max(1,ht.Position(1)+origExt(3)-ext(3))...
                    ,ht.Position(2)...
                    ];
                end
            end

            updateAnchorPatchPos(t);



        end
    end
end
