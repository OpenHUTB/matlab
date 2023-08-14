classdef polariMBMagTicks<internal.polariMouseBehavior

    methods
        function obj=polariMBMagTicks(isButtonDown)

            if nargin>0&&isButtonDown
                obj.InstallFcn=@showToolTipAndPtr_buttondown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@wbup;
                obj.ScrollEvent=[];
            else
                obj.InstallFcn=@showToolTipAndPtr;
                obj.MotionEvent=@internal.polariMBMagTicks.wbmotion;
                obj.DownEvent=@wbdown;
                obj.UpEvent=[];
                obj.ScrollEvent=@internal.polariMBMagTicks.wbscroll;
            end
        end
    end










    methods(Static)
        function wbscroll(p,ev,action)



            s=computeHoverLocation(p,[]);
            if~s.inAxes
                return;
            end
            if nargin<3
                action='max';
            end
            if~strcmpi(p.MagnitudeLimMode,'manual')
                enableListeners(p,false);
                p.MagnitudeLimMode='manual';
                enableListeners(p,true);
            end



            wheelScale=ev.VerticalScrollCount/16;

            newLim=p.pMagnitudeLim;
            del=(newLim(2)-newLim(1))*wheelScale/2;
            if strcmpi(action,'max')
                del=[0,del];
            else
                del=[del,0];
            end
            newLim=newLim+del;








            plot_glow(p,false);

            updateMagnitudeLim(p,newLim,'default');


            updateMarkers(p);
        end

        function wbmotion(p,ev)

            firstEntry=p.ChangedState;
            shiftChanged=firstEntry||...
            p.pLastShiftKeyPressed~=p.pShiftKeyPressed;

            s=computeHoverLocation(p,ev);
            if firstEntry
                p.ChangedState=false;



                if p.MagHiliteOnHover
                    hiliteMagAxisDrag_Init(p,'on');
                end
            end

            if s.overMarker



                hiliteMagAxisDrag_Init(p,'off');



                overrideMagnitudeTickLabelVis(p,'default');

                autoChangeMouseBehavior(p,s);

            elseif s.overMagnitudeTicks




                if firstEntry&&strcmpi(p.MagnitudeTickLabelColorMode,'auto')


                    c=internal.ColorConversion.getBWContrast(p.GridBackgroundColor);
                    p.pMagnitudeTickLabelColor=c;
                    set(p.hMagText,'Color',c);
                end

                if shiftChanged&&p.pShiftKeyPressed






                    if p.MagHiliteOnHover

                        hiliteMagAxisDrag_Init(p,'update','upperlower');
                    end
                end

                if~p.pShiftKeyPressed



                    o=p.MagDrag_OrigRadius;
                    p.MagDrag_OrigRadius=s.radius;
                    brkpt=getMagTickHoverBrkpt(p);
                    if firstEntry||...
                        (s.radius>brkpt&&o<=brkpt)||...
                        (s.radius<=brkpt&&o>brkpt)


                        showToolTipAndPtr(p,s.radius,brkpt);



                        if p.MagHiliteOnHover
                            hiliteMagAxisDrag_Init(p,'update');
                        end


                    elseif shiftChanged




                        if p.MagHiliteOnHover
                            hiliteMagAxisDrag_Init(p,'update');
                        end
                    end
                end
            else


                hiliteMagAxisDrag_Init(p,'off');



                overrideMagnitudeTickLabelVis(p,'default');

                if strcmpi(p.MagnitudeTickLabelColorMode,'auto')

                    updateMagnitudeTickLabelColor(p);
                    set(p.hMagText,'Color',p.pMagnitudeTickLabelColor);
                end
                autoChangeMouseBehavior(p,s);






            end


            if p.pShiftKeyPressed~=p.pLastShiftKeyPressed
                p.pLastShiftKeyPressed=p.pShiftKeyPressed;
            end
        end

        function openPropertyEditor(p)








            p1=internal.polariCommon.sprintfNumTotalDigitsAsVector(p.MagnitudeLim,4);
            p2=internal.polariCommon.sprintfNumTotalDigitsAsVector(p.MagnitudeTick,4);
            p3=sprintf('%g',p.MagnitudeFontSizeMultiplier);



            prompt={...
            'Magnitude Limits:',...
            'Magnitude Ticks:',...
            'Font Size Multiplier:'};
            name='Magnitude Axis';
            numlines=1;
            defaults={p1,p2,p3};
            options.Resize='on';
            options.WindowStyle='modal';
            options.Interpreter='tex';
            a=inputdlg(prompt,name,numlines,defaults,options);




            if~isempty(a)

                try













                    if~isequal(a{1},p1)
                        p.MagnitudeLim=str2num(a{1});%#ok<*ST2NM>
                    end
                    if~isequal(a{2},p2)
                        p.MagnitudeTick=str2num(a{2});
                    end
                    if~isequal(a{3},p3)
                        p.MagnitudeFontSizeMultiplier=str2num(a{3});
                    end
                catch me
                    warndlg(me.message,'Invalid Input','modal');
                end
            end
        end
    end
end

function wbdown(p,ev)








    p.hFigure.CurrentPoint=ev.Point;


    pt=get(p.hAxes,'CurrentPoint');

    st=p.hFigure.SelectionType;
    if strcmpi(st,'open')

        internal.polariMBMagTicks.openPropertyEditor(p);
        return
    elseif strcmpi(st,'alt')





        resetToolTip(p);
        return
    end



    pt=pt(1,1:2);
    r=norm(pt);
    p.AngleDrag_StartAngleClicked=atan2d(pt(2),pt(1));
    p.AngleDrag_StartShiftPressed=p.pShiftKeyPressed;
    p.MagDrag_OrigMagnitudeLim=p.pMagnitudeLim;
    p.MagDrag_ChangedMagnitudeLim=false;















    lineAng=p.pMagnitudeAxisAngle;
    if strcmpi(p.AngleDirection,'ccw')
        lineAngNorm=lineAng-(p.AngleAtTop-90);
    else
        lineAngNorm=(p.AngleAtTop+90)-lineAng;
    end
    lineAngNorm=lineAngNorm*pi/180;

    hoverBrkpt=getMagTickHoverBrkpt(p);
    s.InitialPointClicked=pt;
    s.LineUnitVecCol=[cos(lineAngNorm);sin(lineAngNorm)];
    s.ChangingLowerLim=r<=hoverBrkpt;
    p.MagDrag_MouseDown=s;

    p.MagDrag_ChangedAngle=false;
    p.MagDrag_AngleDelta=0;




    if p.pShiftKeyPressed


        dth=0;
    else

        S=p.pAngleLabelCoords;
        dth=min(15,abs(S.th(2)-S.th(1))*90/pi);
    end
    p.pAngleRotationStepSize=dth;

    hideAngleMarkerDataDots(p,true);
    if~p.MagHiliteOnHover
        hiliteMagAxisDrag_Init(p,'on');
    end




    changeMouseBehavior(p,'magticks_buttondown');
end

function wbdrag(p,ev)















    p.hFigure.CurrentPoint=ev.Point;

    pt=p.hAxes.CurrentPoint(1,1:2);



    shiftPressed=p.pShiftKeyPressed;
    shiftChanged=shiftPressed~=p.AngleDrag_StartShiftPressed;
    if shiftChanged



        p.AngleDrag_StartShiftPressed=shiftPressed;







        c1=p.MagDrag_ChangedMagnitudeLim;
        c2=p.MagDrag_ChangedAngle;

        wbup(p,ev);
        wbdown(p,ev);

        p.MagDrag_ChangedMagnitudeLim=c1;
        p.MagDrag_ChangedAngle=c2;

        wbdrag(p,ev);
        return
    end



    s=p.MagDrag_MouseDown;
    if~p.MagDrag_ChangedAngle








        ptLocalRow=pt-s.InitialPointClicked;
        normdist=ptLocalRow*s.LineUnitVecCol;






        radialMotionDetect=p.MagDrag_ChangedMagnitudeLim;
        if~radialMotionDetect









            raw_dist=hypot(pt(1),pt(2));
            th=p.MagLimChangeDetect_MinNormDist;
            adapt_th=th(1)*(1-raw_dist)+th(2)*raw_dist;
            radialMotionDetect=abs(normdist)>adapt_th;
        end

        if radialMotionDetect


            origLim=p.MagDrag_OrigMagnitudeLim;
            origLimDiff=origLim(2)-origLim(1);
            limChange=normdist*origLimDiff;






            newLim=origLim;

            if shiftPressed


                newLim=newLim-limChange;

                hiliteMagAxisDrag_Init(p,'update','upperlower');
            else



                if s.ChangingLowerLim
                    action='lower';
                else
                    action='upper';
                end
                hiliteMagAxisDrag_Init(p,'update',action);

                guard=0.01*origLimDiff;
                if s.ChangingLowerLim
                    newLim(1)=newLim(1)-limChange;
                    if newLim(1)>=newLim(2)-guard
                        newLim(1)=newLim(2)-guard;
                    end
                else
                    newLim(2)=newLim(2)-limChange;
                    if newLim(2)<=newLim(1)+guard
                        newLim(2)=newLim(1)+guard;
                    end
                end
            end

            if~isequal(newLim,p.pMagnitudeLim)

                if~p.MagDrag_ChangedMagnitudeLim
                    p.MagDrag_ChangedMagnitudeLim=true;

                    enableListeners(p,false);
                    p.MagnitudeLimMode='manual';
                    enableListeners(p,true);

                    resetToolTip(p);
                end
                updateMagnitudeLim(p,newLim);

                return
            end
        end
    end

    if p.MagDrag_ChangedMagnitudeLim


        return
    end




    if s.ChangingLowerLim
        return
    end



    th=atan2(pt(2),pt(1))*180/pi;
    del_th=th-p.AngleDrag_StartAngleClicked;
    if strcmpi(p.AngleDirection,'ccw')
        del_th=-del_th;
    end


    if shiftPressed~=p.pShiftKeyPressed

        if p.pShiftKeyPressed

            dth=0;
        else

            S=p.pAngleLabelCoords;
            dth=min(15,abs(S.th(2)-S.th(1))*90/pi);
        end
        p.pAngleRotationStepSize=dth;


        p.AngleDrag_StartShiftPressed=p.pShiftKeyPressed;
    end


    stepSize=p.pAngleRotationStepSize;
    if stepSize>0

        del_th=round(del_th/stepSize)*stepSize;



        t=p.pMagnitudeAxisAngle;
        tq=round(t/stepSize)*stepSize;
        del_th=del_th+t-tq;
    else

        if abs(del_th)<1e-3
            del_th=0;
        end
    end




    angularMotionDetect=(del_th~=p.MagDrag_AngleDelta);
    if angularMotionDetect
        angularMotionDetect=p.MagDrag_ChangedAngle;
        if~angularMotionDetect
            raw_dist=hypot(pt(1),pt(2));
            th=p.MagAngleChangeDetect_MinTheta;
            adapt_th=th(1)*(1-raw_dist)+th(2)*raw_dist;
            angularMotionDetect=abs(del_th)>adapt_th;
        end
    end
    if angularMotionDetect
        p.MagDrag_AngleDelta=del_th;
        p.MagDrag_ChangedAngle=true;

        if p.ChangedState
            p.ChangedState=false;
            resetToolTip(p);
        end


        th=p.pMagnitudeAxisAngle-p.MagDrag_AngleDelta;
        if strcmpi(p.AngleRange,'180')

            th=th-floor((th+180)/360)*360;
            if th==-180
                th=180;
            end
        else

            th=th-floor(th/360)*360;
        end

        i_updateAngleOfLabelMagnitudes(p,th);
    end
end

function wbup(p,ev)


    p.hFigure.CurrentPoint=ev.Point;

    hiliteMagAxisDrag_Init(p,'off');


    if strcmpi(p.MagnitudeTickLabelColorMode,'auto')
        updateMagnitudeTickLabelColor(p);
        set(p.hMagText,'Color',p.pMagnitudeTickLabelColor);
    end

    del=p.MagDrag_AngleDelta;
    if del~=0



        th=p.pMagnitudeAxisAngle-p.MagDrag_AngleDelta;
        if strcmpi(p.AngleRange,'180')

            th=th-floor((th+180)/360)*360;
            if th==-180
                th=180;
            end
        else

            th=th-floor(th/360)*360;
        end


        p.AngleDrag_StartAngleClicked=[];
        p.MagDrag_AngleDelta=0;


        p.MagnitudeAxisAngle=th;

    end



    p.MagDrag_ChangedMagnitudeLim=false;
    p.MagDrag_ChangedAngle=false;

    hideAngleMarkerDataDots(p,false);

    s=computeHoverLocation(p,ev);
    if s.overMagnitudeTicks
        changeMouseBehavior(p,'magticks');
        internal.polariMBMagTicks.wbmotion(p,ev);
    else

        autoChangeMouseBehavior(p,s);
    end
end

function showToolTipAndPtr(p,r,brkpt)



    setptr(p.hFigure,'hand');

    if nargin<3
        brkpt=getMagTickHoverBrkpt(p);
    end
    if nargin<2
        pt=p.hAxes.CurrentPoint;
        r=norm(pt(1,1:2));
    end
    lowerLim=r<brkpt;
    showToolTip(p,lowerLim);
end

function showToolTip(p,changingLowerLim)
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)

        if changingLowerLim
            str='Drag to change LOWER magnitude limit';
        else
            str={'Drag to change UPPER magnitude limit',...
            'Drag along circle to change axis angle'};
        end
        start(p.hToolTip,str);
    end
end

function showToolTipAndPtr_buttondown(p)

    brkpt=getMagTickHoverBrkpt(p);
    pt=p.hAxes.CurrentPoint;
    r=norm(pt(1,1:2));
    lowerLim=r<brkpt;
    if lowerLim
        str='Drag radially to change LOWER limit';
    else
        str={...
        'Drag radially to change UPPER limit',...
        'Drag to rotate axis angle'};
    end
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        start(p.hToolTip,str);
    end
    ptr='closedhand';
    setptr(p.hFigure,ptr);
end
