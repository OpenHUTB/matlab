classdef polariMBAngleTicks<internal.polariMouseBehavior




    methods
        function obj=polariMBAngleTicks(isButtonDown)

            if nargin>0&&isButtonDown
                obj.InstallFcn=@showToolTipAndPtr_angleTicksDown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@wbup;
                obj.ScrollEvent=[];
            else
                obj.InstallFcn=@showToolTipAndPtr_angleTicks;
                obj.MotionEvent=@internal.polariMBAngleTicks.wbmotion;
                obj.DownEvent=@wbdown;
                obj.UpEvent=[];
                obj.ScrollEvent=[];
            end
        end
    end

    methods(Static)
        function hiliteAngleTickLabelDrag_Init(p,state)












            h=p.hAngleTickLabelHilite;
            isValid=~isempty(h)&&ishghandle(h.lr);

            is_on=~strcmpi(state,'off');
            p.pAngleTickLabelHilite=is_on;
            if~is_on

                if isValid
                    set([h.ud,h.lr],'Visible','off');
                end
                return
            end



            if~isValid
                x=[-1,0,+1,-1]*.5;
                y=[0,1,0,0]*.5;
                up=[x;y];
                y=[0,-1,0,0]*.5;
                dn=[x;y];
                x=[0,-1,0,0]*.5;
                y=[1,0,-1,1]*.5;
                lt=[x;y];
                x=[0,1,0,0]*.5;
                rt=[x;y];
                u={up,dn,lt,rt};

                h.ud=patch(...
                'Parent',p.hAxes,...
                'HandleVisibility','off',...
                'FaceColor','none',...
                'FaceAlpha',1.0,...
                'EdgeAlpha',1.0,...
                'Clipping','on',...
                'UserData',u,...
                'Visible','off');
                h.lr=patch(...
                'Parent',p.hAxes,...
                'HandleVisibility','off',...
                'FaceColor','none',...
                'FaceAlpha',1.0,...
                'EdgeAlpha',1.0,...
                'Clipping','on',...
                'UserData',u,...
                'Visible','off');








                set([h.ud,h.lr],'uicontextmenu',p.UIContextMenu_AngleTicks);

                p.hAngleTickLabelHilite=h;
            end


            set([h.ud,h.lr],...
            'FaceColor',p.GridBackgroundColor,...
            'EdgeColor',p.pAngleTickLabelColor);
...
...
...
...
...
...
...
...
...
...
...
...
...






            internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Update(p);

        end

        function hiliteAngleTickLabelDrag_Update(p,closestTextIdx)


            hpatch=p.hAngleTickLabelHilite;
            if strcmpi(p.pAngleTickLabelHilite,'off')||...
                isempty(hpatch)||~ishghandle(hpatch.lr)
                return
            end

            if p.EnableAngleDragRadialDir
                ud_vis_on='on';
            else
                ud_vis_on='off';
            end

            if p.AngleDrag_ChangedMag

                hpatch.ud.Visible=ud_vis_on;
                hpatch.lr.Visible='off';
            elseif p.AngleDrag_ChangedAngle

                hpatch.ud.Visible='off';
                hpatch.lr.Visible='on';
            elseif p.pAngleTickLabelHilite

                hpatch.ud.Visible=ud_vis_on;
                hpatch.lr.Visible='on';
            else
                hpatch.ud.Visible='off';
                hpatch.lr.Visible='off';
            end








            if nargin<2





                pt=get(p.hAxes,'CurrentPoint');
                closestTextIdx=findClosestAngleTextLabel(pt(1,1:2),p.hAngleText);

            elseif~isscalar(closestTextIdx)





                orig_pt=closestTextIdx;
                closestTextIdx=findClosestAngleTextLabel(orig_pt(1,1:2),p.hAngleText);



            end
            p.pClosestAngleTickLabel=closestTextIdx;
            hh=p.hAngleText(closestTextIdx);







            pos=hh.Position;
            ext=getappdata(hh,'Extent');


            if p.AngleTickLabelRotation

                th=hh.Rotation*pi/180;
            else
                th=atan2(pos(2),pos(1))-pi/2;
            end
            rotccw=[cos(th),-sin(th);sin(th),cos(th)];









            Nparts=4;
            x=NaN(4,Nparts);
            y=NaN(4,Nparts);





            rmin=min(0.10,min(ext));



            xe=ext(1)/2+max(0.02,0.05*ext(1));
            ye=ext(2)/2+max(0.01,0.03*ext(2));



            u=hpatch.lr.UserData;
            for i=1:Nparts

                u_i=u{i}*rmin;



                if i==1
                    u_i(2,:)=u_i(2,:)+ye;
                elseif i==2
                    u_i(2,:)=u_i(2,:)-ye;
                elseif i==3
                    u_i(1,:)=u_i(1,:)-xe;
                else
                    u_i(1,:)=u_i(1,:)+xe;
                end


                p_i=rotccw*u_i;
                x(:,i)=p_i(1,:)';
                y(:,i)=p_i(2,:)';
            end


            x=x+pos(1);
            y=y+pos(2);
            z=y;
            z(~isnan(z))=0.294;


            set(hpatch.ud,...
            'XData',x(:,1:2),...
            'YData',y(:,1:2),...
            'ZData',z(:,1:2));
            set(hpatch.lr,...
            'XData',x(:,3:4),...
            'YData',y(:,3:4),...
            'ZData',z(:,3:4));
        end

        function wbmotion(p,ev)




            p.hFigure.CurrentPoint=ev.Point;

            firstEntry=p.ChangedState;
            hOverrideContext=[p.Parent,p.hCircles{3}];
            if firstEntry

                p.ChangedState=false;



                set(hOverrideContext,'uicontextmenu',p.UIContextMenu_AngleTicks);

                if p.AngleHiliteOnHover


                    overrideAngleTickLabelVis(p,'on');



                    internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Init(p,'on');
                end

                showToolTipAndPtr_angleTicks(p);
            end





            s=computeHoverLocation(p,ev);
            if~s.inAxes...
                ||~s.overAngleTicks...
                ||s.overMagnitudeTicks...
                ||s.overMarker

                internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Init(p,'off');

                if strcmpi(p.AngleTickLabelColorMode,'auto')

                    updateAngleTickLabelColor(p);
                    set(p.hAngleText,'Color',p.pAngleTickLabelColor);
                end



                overrideAngleTickLabelVis(p,'default');



                set(hOverrideContext,'uicontextmenu',p.UIContextMenu_Master);

                autoChangeMouseBehavior(p,s);
            else


                if firstEntry&&strcmpi(p.AngleTickLabelColorMode,'auto')

                    c=internal.ColorConversion.getBWContrast(p.GridBackgroundColor);
                    p.pAngleTickLabelColor=c;
                    set(p.hAngleText,'Color',c);
                end


                if p.AngleHiliteOnHover
                    pt=p.hAxes.CurrentPoint;
                    idx=findClosestAngleTextLabel(pt(1,1:2),p.hAngleText);
                    if idx~=p.pClosestAngleTickLabel
                        internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Update(p,idx);
                    end
                end
            end
        end
    end
end








function wbdown(p,ev)

    p.hFigure.CurrentPoint=ev.Point;



    pt=p.hAxes.CurrentPoint(1,1:2);

    st=p.hFigure.SelectionType;
    if strcmpi(st,'open')
        datasetIndex=[];
        m=i_addCursor(p,pt,datasetIndex);
        if isempty(m)
            return
        end



        changeMouseBehavior(p,'anglemarker');
        internal.polariMBAngleMarker.wbmotion(p,ev,m);


        p.hFigure.SelectionType='normal';
        internal.polariMBAngleMarker.wbdown(p,ev);

        return
    elseif strcmpi(st,'alt')





        resetToolTip(p);
        return
    end

    p.AngleDrag_StartMagClicked=hypot(pt(2),pt(1));
    p.AngleDrag_StartAngleClicked=atan2(pt(2),pt(1))*180/pi;
    p.AngleDrag_StartShiftPressed=p.pShiftKeyPressed;
    p.AngleDrag_Delta=0;
    p.AngleDrag_ChangedAngle=false;
    p.AngleDrag_ChangedMag=false;




    if p.pShiftKeyPressed

        dth=0;
    else

        S=p.pAngleLabelCoords;
        dth=min(15,abs(S.th(2)-S.th(1))*90/pi);
    end
    p.pAngleRotationStepSize=dth;



    if~p.AngleHiliteOnHover
        overrideAngleTickLabelVis(p,'on');
    end

    internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Init(p,'down');

    changeMouseBehavior(p,'angleticks_buttondown');
end

function wbdrag(p,ev)













    p.hFigure.CurrentPoint=ev.Point;

    pt=get(p.hAxes,'CurrentPoint');
    shiftPressed=p.AngleDrag_StartShiftPressed;
    mag=hypot(pt(1,2),pt(1,1));
    del_mag=mag-p.AngleDrag_StartMagClicked;


    firstEntry=p.ChangedState;
    if firstEntry
        p.ChangedState=false;
        showToolTipAndPtr_angleTicksDrag(p);
    end

    if~shiftPressed&&~p.AngleDrag_ChangedAngle




        if p.EnableAngleDragRadialDir...
            &&~p.AngleDrag_ChangedMag...
            &&(abs(del_mag)>0.1)


            p.AngleDrag_ChangedMag=true;



            p.pClosestAngleTickLabel_origpt=pt;
        end
    end
    if p.AngleDrag_ChangedMag





























        return
    end



    th=atan2(pt(1,2),pt(1,1))*180/pi;
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





        t=p.AngleAtTop;
        tq=round(t/stepSize)*stepSize;
        if t~=tq
            del_th=del_th-t+tq;
        end
    end

    if abs(del_th)<1e-3
        del_th=0;
    end



    if del_th~=p.AngleDrag_Delta
        p.AngleDrag_Delta=del_th;
        p.AngleDrag_ChangedAngle=true;
        i_changeAngleAtTop(p);
    end
end

function wbup(p,ev)


    p.hFigure.CurrentPoint=ev.Point;

    internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Init(p,'off');


    if strcmpi(p.AngleTickLabelColorMode,'auto')
        updateAngleTickLabelColor(p);
        set(p.hAngleText,'Color',p.pAngleTickLabelColor);
    end

    if p.AngleDrag_ChangedAngle



        th=p.AngleAtTop+p.AngleDrag_Delta;
        if strcmpi(p.AngleRange,'180')

            th=th-floor((th+180)/360)*360;
            if th==-180
                th=180;
            end
        else

            th=th-floor(th/360)*360;
        end
    end


    p.AngleDrag_StartAngleClicked=[];
    p.AngleDrag_Delta=0;

    if p.AngleDrag_ChangedAngle

        p.AngleAtTop=th;
    end

    p.AngleDrag_ChangedAngle=false;
    p.AngleDrag_ChangedMag=false;




    s=computeHoverLocation(p,ev);
    if s.overAngleTicks


        changeMouseBehavior(p,'angleticks');





        if~p.AngleHiliteOnHover
            overrideAngleTickLabelVis(p,'on');
        end
    else

        autoChangeMouseBehavior(p,s);
    end
end

function showToolTipAndPtr_angleTicks(p)
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)

        str='';
...
...
...
...
...
...
...
        start(p.hToolTip,{...
        'Drag to rotate angle ticks',str});
    end
    setptr(p.hFigure,'hand');
end

function showToolTipAndPtr_angleTicksDown(p)
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)

        str='';
...
...
...
...
...
...
...
        start(p.hToolTip,{...
        'Drag to rotate angle ticks',str});
    end
    setptr(p.hFigure,'closedhand');
end

function showToolTipAndPtr_angleTicksDrag(p)
    resetToolTip(p);
end

function idx=findClosestAngleTextLabel(pt,ht)




    ht_pos=cat(1,ht.Position);
    dist=bsxfun(@minus,pt(1,1:2),ht_pos(:,1:2));
    [~,idx]=min(sum(dist.*dist,2));


end
