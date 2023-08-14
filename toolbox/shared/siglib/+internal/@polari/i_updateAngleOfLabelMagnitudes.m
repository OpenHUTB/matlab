function i_updateAngleOfLabelMagnitudes(p,th)






    if nargin>1

        [ang,txtAng]=computeManualMagTickLabelAngle(p,th);
        costh=cos(ang);
        sinth=sin(ang);
        ang=ang*180/pi;
    else
        S=p.pMagnitudeLabelCoords;
        ang=S.ang;
        txtAng=S.textAngle;
        costh=S.costh;
        sinth=S.sinth;
    end









    thresh=p.MagnitudeTickAngleOrientationThreshold;
    if(abs(ang)<thresh)||(abs(ang+180)<thresh)||(abs(ang-180)<thresh)
        txtAng=0;
    end


    slim=p.pMagnitudeLim_Scaled;
    magNorm=(p.pMagnitudeTick_Scaled-slim(1))./(slim(2)-slim(1));
    if~isempty(magNorm)
        ht=p.hMagText;
        txtH=0.04;
        magNorm=magNorm-0.01;
        magNorm(magNorm>(1-txtH))=1-txtH;
        for i=1:numel(ht)
            set(ht(i),...
            'Position',[costh*magNorm(i),sinth*magNorm(i),0.25],...
            'Rotation',txtAng);
        end
    end



    updateMagAxisLocator(p);





    ht=p.hMagScale;
    cstr=ht.String;
    lineInTopHalf=(ang>=0&&ang<=180)||(ang==-180);
    if lineInTopHalf

        if isempty(cstr{3})
            ht.String=cstr([2,3,1]);
        end
    else

        if isempty(cstr{1})
            ht.String=cstr([3,1,2]);
        end
    end


    hiliteMagAxisDrag_Update(p,ang);


