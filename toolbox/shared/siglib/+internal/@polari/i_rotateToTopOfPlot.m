function i_rotateToTopOfPlot(p,pt)








    x_norm=pt(1,1);
    y_norm=pt(1,2);

    th_norm=atan2d(y_norm,x_norm);

    is_cw=strcmpi(p.AngleDirection,'cw');
    del_th=90-th_norm;
    if del_th>180,del_th=del_th-360;end
    if is_cw,del_th=-del_th;end


    S=p.pAngleLabelCoords;
    stepSize=min(15,abs(S.th(2)-S.th(1))*90/pi);
    if stepSize>0
        del_th=round(del_th/stepSize)*stepSize;





        t=p.AngleAtTop;
        tq=round(t/stepSize)*stepSize;
        if t~=tq
            del_th=del_th+t-tq;
        end
    end










    internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Init(p,'off');
    animStep=5;
    numSteps=floor(abs(del_th)/animStep);
    for i=1:numSteps
        p.AngleDrag_Delta=-i*del_th/numSteps;
        i_changeAngleAtTop(p);
        drawnow('expose');
    end




    p.AngleDrag_Delta=0;



    p.AngleAtTop=p.AngleAtTop-del_th;






    ev=p.pLatestMotionEv;
    internal.polariMBAngleTicks.wbmotion(p,ev);


    changeMouseBehavior(p,'general');

    internal.polariMBGeneral.wbmotion(p,ev);
