function cacheCoords_AngleTickLabels(p)






    Ncirc=numel(p.pMagnitudeCircleRadii);
    if(Ncirc>0)&&p.GridAutoRefinement

        Nskip=2;
        if p.DrawGridToOrigin
            Nc=2^(Ncirc-1);
            if Nc==1,Nskip=1;end
        else
            if Ncirc<2

                Nc=1;
                Nskip=1;
            else
                Nc=2^(Ncirc-2);
                if Nc==1,Nskip=1;end
            end
        end
    else

        Nskip=1;
        Nc=1;
    end









    Nth=360*Nc/p.AngleResolution;



    while Nth>p.MaxNumRefinementLines
        Nth=Nth/2;
    end
    th=(0:Nskip:Nth-1)./Nth.*360;
    th=getNormalizedAngle(p,th);








    Nmax=p.MaxNumAngleLabels;
    Nang=numel(th);
    if Nang>Nmax
        m=ceil(Nang/Nmax/2)*2;
        Nth=floor(Nth/m);
        th=th(1:m:end);
    end



    thTxt=(0:Nskip:Nth-1)./Nth.*360;
    if p.pAngleRange(2)==180
        sel=thTxt>180;
        thTxt(sel)=thTxt(sel)-360;
    end






    if p.UseDegreeSymbol
        fmt=['%g',char(176)];
    else
        fmt='%g';
    end

    N=numel(thTxt);
    cstr=cell(1,N);
    for i=1:N
        cstr{i}=sprintf(fmt,thTxt(i));
    end





    ang=getNormalizedAngle(p,p.pAngleLim);
    a1=ang(1);
    a2=ang(2);
    labelVis=cell(N,1);
    for i=1:N
        labelVis{i}=lower(internal.LogicalToOnOff(...
        internal.polariCommon.isBetweenAnglesRad(th(i),a2,a1)));
    end




    S=[];
    S.zeroIdx=find(thTxt==0);
    S.th=th;
    S.x=cos(th);
    S.y=sin(th);
    S.thetaStrs=cstr;
    S.labelVis=labelVis;
    p.pAngleLabelCoords=S;



    updateAngleTickLabel(p);
