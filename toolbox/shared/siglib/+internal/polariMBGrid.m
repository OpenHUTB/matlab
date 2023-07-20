classdef polariMBGrid<internal.polariMouseBehavior

    methods
        function obj=polariMBGrid(isButtonDown)

            if nargin>0&&isButtonDown
                obj.InstallFcn=@showToolTipAndPtr_buttondown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@wbup;
                obj.ScrollEvent=[];
            else
                obj.InstallFcn=@internal.polariMBGrid.showToolTipAndPtr;
                obj.MotionEvent=@wbmotion;
                obj.DownEvent=@internal.polariMBGrid.wbdown;
                obj.UpEvent=[];
                obj.ScrollEvent=@internal.polariMBMagTicks.wbscroll;
            end
        end
    end

    methods(Static)
        function wbdown(p,ev)




            st=p.hFigure.SelectionType;
            p.hFigure.CurrentPoint=ev.Point;


            if strcmpi(st,'open')




                thisFig=ev.Source;
                thisAxes=thisFig.CurrentAxes;
                if p.pAxesIndex==getappdata(thisAxes,'PolariAxesIndex')




                    m_addCursor(p);





                    s=computeHoverLocation(p,ev);
                    if s.overGrid









                        pt=p.hAxes.CurrentPoint(1,1:2);
                        ch=norm(pt)<=getMagTickHoverBrkpt(p);
                        internal.polariMBGrid.showToolTipAndPtr(p,ch);
                    else
                        autoChangeMouseBehavior(p,s);
                    end
                end
                return
            elseif strcmpi(st,'alt')





                resetToolTip(p);
                return
            end






            ax=p.hAxes;
            ax.Units='normalized';
            pt=ax.CurrentPoint;



            pt=pt(1,1:2);
            r=norm(pt);

            ci.ChangedMagnitudeLim=false;



            p.MagDrag_ChangedMagnitudeLim=true;
            p.MagDrag_OrigMagnitudeLim=p.pMagnitudeLim;



            [ci.OtherPolariInstances,ci.OtherPolariPrevEna]=...
            enableMouseInOtherInstances(p,false);



            p.SpanReadout_CacheInfo=ci;














            lineAngNorm=atan2(pt(2),pt(1));
            s.InitialPointClicked=pt;
            s.LineUnitVecCol=[cos(lineAngNorm);sin(lineAngNorm)];
            s.ChangingLowerLim=r<=getMagTickHoverBrkpt(p);
            p.MagDrag_MouseDown=s;

            hideAngleMarkerDataDots(p,true);


            if p.MagnitudeTickLabelVisible
                hiliteMagAxisDrag_Init(p,'on');
            end

            if s.ChangingLowerLim
                action='lower';
            else
                action='upper';
            end

            if p.MagnitudeTickLabelVisible
                hiliteMagAxisDrag_Init(p,'update',action);
            end

            changeMouseBehavior(p,'grid_buttondown');
        end

        function showToolTipAndPtr(p,changingLowerLim)
            if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)

                setptr(p.hFigure,'arrow');

                if nargin<2

                    str='Drag to change magnitude limits';

                elseif changingLowerLim
                    str='Drag to change LOWER magnitude limit';


                else
                    str='Drag to change UPPER magnitude limit';


                end


                N=numel(p.hPeakAngleMarkers)+...
                numel(p.hCursorAngleMarkers);
                if N~=1||~p.Span



                    str={str,'Double-click to add cursor'};
                else
                    str={str,'Double-click to show span'};
                end
                start(p.hToolTip,str);
            end
        end
    end
end

function wbdrag(p,ev)



    p.hFigure.CurrentPoint=ev.Point;
    pt=p.hAxes.CurrentPoint(1,1:2);







    s=p.MagDrag_MouseDown;
    ptLocalRow=pt-s.InitialPointClicked;
    normdist=ptLocalRow*s.LineUnitVecCol;


    origLim=p.MagDrag_OrigMagnitudeLim;
    origLimDiff=origLim(2)-origLim(1);
    limChange=normdist*origLimDiff;

    newLim=origLim;

    if s.ChangingLowerLim
        newLim(1)=newLim(1)-limChange;
    else
        newLim(2)=newLim(2)-limChange;
    end

    if~isequal(newLim,p.pMagnitudeLim)

        ci=p.SpanReadout_CacheInfo;
        if~ci.ChangedMagnitudeLim
            ci.ChangedMagnitudeLim=true;
            p.SpanReadout_CacheInfo=ci;

            enableListeners(p,false);
            p.MagnitudeLimMode='manual';
            enableListeners(p,true);
        end
        mvis=internal.LogicalToOnOff(p.MagnitudeTickLabelVisible);
        updateMagnitudeLim(p,newLim,mvis);


        return
    end
    wbup(p,ev);
end

function wbup(p,ev)

    hiliteMagAxisDrag_Init(p,'off');


    p.hFigure.CurrentPoint=ev.Point;








    ci=p.SpanReadout_CacheInfo;
    enableMouseInOtherInstances(p,true,...
    ci.OtherPolariInstances,...
    ci.OtherPolariPrevEna);


    p.SpanReadout_CacheInfo=[];
    p.MagDrag_ChangedMagnitudeLim=false;

    hideAngleMarkerDataDots(p,false);





    s=computeHoverLocation(p,ev);
    if s.overGrid||s.overLobes


        changeMouseBehavior(p,'grid');

        if s.overLobes
            if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
                start(p.hToolTip,...
                {upper([s.overLobesType,' Lobe']),...
                'Right-click for options'});
            end
        else


            pt=p.hAxes.CurrentPoint(1,1:2);
            ch=norm(pt)<=getMagTickHoverBrkpt(p);
            internal.polariMBGrid.showToolTipAndPtr(p,ch);
        end
    else

        autoChangeMouseBehavior(p,s);
    end
end

function wbmotion(p,ev)

    s=computeHoverLocation(p,ev);
    firstTime=p.ChangedState;

    if firstTime||s.overGrid
        pt=p.hAxes.CurrentPoint(1,1:2);
        ch=norm(pt)<=getMagTickHoverBrkpt(p);
    end

    if firstTime
        p.ChangedState=false;
        p.pGridMotion_ChangingLowerLim=-1;
        internal.polariMBGrid.showToolTipAndPtr(p,ch);
    end

    if firstTime||s.overGrid


        if p.pGridMotion_ChangingLowerLim~=ch
            p.pGridMotion_ChangingLowerLim=ch;
            internal.polariMBGrid.showToolTipAndPtr(p,ch);
        end

    else




        overrideMagnitudeTickLabelVis(p,'default');


        internal.polariMBGeneral.wbmotion(p,ev);

        p.pGridMotion_ChangingLowerLim=-1;
    end
end

function showToolTipAndPtr_buttondown(p)
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        s=p.MagDrag_MouseDown;
        if s.ChangingLowerLim
            str='Drag to change LOWER magnitude limit';
        else
            str='Drag to change UPPER magnitude limit';
        end
        start(p.hToolTip,str);
        setptr(p.hFigure,'closedhand');
    end
end
