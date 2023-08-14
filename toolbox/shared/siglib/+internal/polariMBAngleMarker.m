classdef polariMBAngleMarker<internal.polariMouseBehavior


    methods
        function obj=polariMBAngleMarker(isButtonDown)













            if nargin>0&&isButtonDown

                obj.InstallFcn=@showToolTipAndPtr_angleMarkerDown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@wbup;
                obj.ScrollEvent=[];
            else

                obj.InstallFcn=@showToolTipAndPtr_angleMarker;
                obj.MotionEvent=@internal.polariMBAngleMarker.wbmotion;
                obj.DownEvent=@internal.polariMBAngleMarker.wbdown;
                obj.UpEvent=[];
                obj.ScrollEvent=[];
            end
        end
    end




    methods(Static)
        function wbmotion(p,ev,newlyAddedMarker)




            s=computeHoverLocation(p,ev);
















            if strcmpi(ev.EventName,'WindowMousePress')




                p.ChangedState=true;
                p.pAngleMarkerHoverID='';
                s.overMarker=true;
                s.overMarkerID=newlyAddedMarker.ID;
            end

            justEntered=p.ChangedState;
            if justEntered

                p.ChangedState=false;

                if~isempty(s.overMarkerID)






                    angleMarkerHilite(p,s.overMarkerID);



                    if getNumDatasets(p)>1
                        m=findAngleMarkerByID(p,s.overMarkerID);
                        plot_glow(p,true,...
                        getDataSetIndex(m));
                    end
                    showToolTipAndPtr_angleMarker(p,s.overMarkerID)
                end
            end

            if s.overMarker



                if~justEntered&&~strcmpi(p.pAngleMarkerHoverID,s.overMarkerID)

                    angleMarkerHilite(p,s.overMarkerID);

                    if getNumDatasets(p)>1
                        plot_glow(p,true,...
                        getDataSetIndex(...
                        findAngleMarkerByID(p,s.overMarkerID)));
                    end
                end

            else




                plot_glow(p,false);
                angleMarkerHilite(p,[]);
                autoChangeMouseBehavior(p,s);
            end
        end

        function wbdown(p,ev)


            p.hFigure.CurrentPoint=ev.Point;
            selType=p.hFigure.SelectionType;
            if strcmpi(selType,'open')

                p.pAngleMarker_MouseOpenEvent=true;
                angleMarkerDetail(p,'cycle');

            elseif strcmpi(selType,'alt')





                resetToolTip(p);
                return
            end





            ID=p.pAngleMarkerHoverID;
            if isempty(ID)

                return
            end
            m=findAngleMarkerByID(p,ID);

            switch lower(ID(1))
            case 'p'

                s.Draggable=false;
                s.Marker=[];
                s.isDataCursor=true;


                if~m.Visible








                    s.Marker=m;
                    m.Visible=true;
                end

            case 'c'

                s.Draggable=true;
                s.Marker=m;
                s.isDataCursor=true;
            otherwise

                s.Draggable=true;
                s.Marker=m;
                s.isDataCursor=false;
            end

            angleMarkerOriginLine(p,true);




            t.lastMotion=2;


            t.nextMotion=[];

            t.inertiaCount=0;
            m.pMotionGuidance=t;

            p.MarkerDrag_Info=s;
            changeMouseBehavior(p,'anglemarker_buttondown');








            reorderRelatedAngleMarkers(p,ID,+1);



            span=p.hAngleSpan;
            if~isempty(span)
                updateAngleMarkersList(span);
            end
        end
    end
end

function wbup(p,ev)


    p.hFigure.CurrentPoint=ev.Point;



    if p.pAngleMarker_MouseOpenEvent



        p.pAngleMarker_MouseOpenEvent=false;
    else


    end
    angleMarkerOriginLine(p,false);
    angleMarkerHilite(p,[]);

    s=computeHoverLocation(p,ev);
    if~s.overMarker

        plot_glow(p,false);
    else
        showToolTipAndPtr_angleMarker(p,s.overMarkerID);
    end

    m=p.MarkerDrag_Info.Marker;


    if~isempty(m)&&~p.MarkerDrag_Info.Draggable




        m.Visible=false;
    end

    p.MarkerDrag_Info=[];

    isTempMarker=p.pDeleteCurrentMarkerOnButtonRelease;
    if isTempMarker



        p.pDeleteCurrentMarkerOnButtonRelease=false;

        datasetIndex=getDataSetIndex(m);


        removeCursors(p,m.Index);









        h=getDataWidgetHandles(p);
        h=h(datasetIndex);
        ev2.Point=ev.Point;
        ev2.HitObject=h;
        internal.polariMBDataset.wbup(p,ev2);



        internal.polariMBGrid.showToolTipAndPtr(p);
    else

        autoChangeMouseBehavior(p,s);
    end
end

function wbdrag(p,ev)


    p.hFigure.CurrentPoint=ev.Point;
    s=p.MarkerDrag_Info;
    if s.Draggable
        if s.isDataCursor&&~s.Marker.Floating


            wbdrag_constr2(p,s);
        else



            wbdrag_unconstr(p,s);
        end
    end
end

function wbdrag_constr1(p,s)












    m=s.Marker;
    m.DataIndex=getDataIndexFromPoint(p,...
    p.hAxes.CurrentPoint,getDataSetIndex(m));
end

function wbdrag_constr2(p,s)








    m=s.Marker;
    datasetIndex=getDataSetIndex(m);
    d_i=getDataset(p,datasetIndex);
    Nd=numel(d_i.mag);


    ptr=p.hAxes.CurrentPoint(1,1:2);
    ang_ptr=atan2(ptr(2),ptr(1));






    currIdx=m.DataIndex;
    if isempty(currIdx)||currIdx<1||currIdx>Nd
        currIdx=1;
    end



    continuousAtEndpoints=~d_i.angGapAtEnd;
    ce=p.ConnectEndpoints||continuousAtEndpoints;
    angJumpThresh=pi/2;

    g=m.pMotionGuidance;




    cont=true;
    while cont

        nIdx=1+mod(currIdx-1+[-1,0,+1],Nd);
        ang_d123=getNormalizedAngle(p,d_i.ang(nIdx));




        dCW=internal.polariCommon.isCWangle(ang_d123(2),ang_d123([1,3]));
        ptr_at_cusp=all(dCW)||~any(dCW);


        delta_ptr=internal.polariCommon.angleAbsDiff(ang_ptr,ang_d123);


















        at_end=~ce&&(currIdx==1||currIdx==Nd);
        if at_end
            if currIdx==1

                delta_ptr(1)=inf;
            elseif currIdx==Nd

                delta_ptr(3)=inf;
            end
            ptr_at_cusp=false;
            g.inertiaCount=0;
            g.nextMotion=[];
            g.lastMotion=2;
        end


        if any(abs(delta_ptr)>angJumpThresh)










            ptr_at_cusp=false;
            g.inertiaCount=0;
            g.nextMotion=[];
            g.lastMotion=2;
        end

        [~,newGuidance]=min(delta_ptr);


        if ptr_at_cusp






            g.inertiaCount=2;

        elseif g.inertiaCount>0


            g.inertiaCount=g.inertiaCount-1;
            ptr_at_cusp=true;
        end

        if ptr_at_cusp



            newGuidance=g.lastMotion;
            if newGuidance==2




                newGuidance=3;
                g.lastMotion=newGuidance;
            end







            if g.inertiaCount==0
                if g.lastMotion==1
                    g.nextMotion=1;
                else
                    g.nextMotion=3;
                end
            end


            currIdx=nIdx(newGuidance);






            cont=false;
        else






            if~isempty(g.nextMotion)



                if newGuidance~=g.nextMotion



                    cont=false;
                else




                    g.nextMotion=[];


                    g.lastMotion=newGuidance;

                    currIdx=nIdx(newGuidance);
                end
            else




                if newGuidance~=2

                    g.lastMotion=newGuidance;

                    currIdx=nIdx(newGuidance);
                else

                    cont=false;
                end
            end
        end
    end


    m.pMotionGuidance=g;


    m.DataIndex=currIdx;
end

function wbdrag_unconstr(p,s)



    pt=p.hAxes.CurrentPoint(1,1:2);
    normRad=atan2(pt(2),pt(1));
    userDeg=transformNormRadToUserDeg(p,normRad);
    m=s.Marker;

    if s.isDataCursor


        m.LocalAngle=userDeg;
    else



        userDeg=round(userDeg);

        idx=m.Index;
        val=adjustAngleLimForFullCircle(p,userDeg,idx);





        m.LocalAngle=val(idx);


        i_changeAngleLim(p);
    end
end

function showToolTipAndPtr_angleMarker(p,markerID)

    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        if nargin<2
            markerID=p.pAngleMarkerHoverID;
        end
        if isempty(markerID)
            markerID='?';
        end
        switch lower(markerID(1))
        case 'c'
            m=findAngleMarkerByID(p,markerID);
            if m.Floating
                floatStr=' (Floating)';
            else
                floatStr='';
            end
            str={['CURSOR ',markerID(2),floatStr],'Drag to reposition'};
            if isIntensityData(p)
                str=[str,'Maximum intensity shown'];
            end
            ptr='hand';
        case 'p'
            str={['PEAK ',markerID(2)],'Right-click for options'};
            ptr='arrow';
        case 'a'
            str={'ANGLE LIMIT','Drag to change limits','Right-click for options'};
            ptr='hand';
        otherwise
            str={'ANGLE MARKER','Rotate to reposition','Right-click for options'};
            ptr='arrow';
        end
        start(p.hToolTip,str);
        setptr(p.hFigure,ptr);
    end
end

function showToolTipAndPtr_angleMarkerDown(p)
    resetToolTip(p);



    id=p.pAngleMarkerHoverID;
    if~isempty(id)&&~strcmpi(id(1),'p')
        setptr(p.hFigure,'closedhand');
    else
        setptr(p.hFigure,'arrow');
    end
end
