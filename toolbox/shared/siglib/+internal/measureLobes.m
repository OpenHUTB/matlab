function L=measureLobes(angd,mag,units)






































































    L.mainLobe.index=[];
    L.mainLobe.magnitude=[];
    L.mainLobe.angle=[];
    L.mainLobe.extent=[];





    L.backLobe.magnitude=[];
    L.backLobe.angle=[];
    L.backLobe.extent=[];



    L.sideLobes.index=[];
    L.sideLobes.magnitude=[];
    L.sideLobes.angle=[];
    L.sideLobes.extent=[];

    L.FB=[];
    L.SLL=[];
    L.HPBW=[];
    L.FNBW=[];
    L.FBIdx=[];
    L.SLLIdx=[];
    L.HPBWIdx=[];
    L.HPBWAng=[];
    L.FNBWIdx=[];
    dbdown=3;
    interp_HPBW=0;



    [angleSpan,fullCircle]=internal.polariCommon.findAngleSpan(...
    angd*pi/180);





    peaksIdx=internal.polariCommon.findPolarPeaks(mag,true,inf);


    valleysIdx=internal.polariCommon.findPolarValleys(mag,peaksIdx,fullCircle,units);




    [L.mainLobe.magnitude,i]=max(mag(peaksIdx));
    mainLobePeakIdx=peaksIdx(i);
    peaksIdx(i)=[];
    L.mainLobe.index=mainLobePeakIdx;
    L.mainLobe.angle=angd(mainLobePeakIdx);
    Nv=numel(valleysIdx);
    if Nv<2



        L.mainLobe.extent=[1,numel(mag)];
        flag=~any(isnan(mag))&&~fullCircle;


        if flag
            [L.HPBW,L.HPBWAng,L.HPBWIdx]=internal.calc_bw([NaN,mag',NaN],0,...
            [NaN,angd',NaN],dbdown,interp_HPBW,1,fullCircle);
            L.HPBWIdx(1)=find(angd==L.HPBWAng(1));
            L.HPBWIdx(2)=find(angd==L.HPBWAng(2));
        else
            [L.HPBW,L.HPBWAng,L.HPBWIdx]=internal.calc_bw(mag,0,...
            angd,dbdown,interp_HPBW,1,fullCircle);
        end
        return
    end









    valleysIdx=sort(valleysIdx);
    i=find(valleysIdx<mainLobePeakIdx,1,'last');
    if isempty(i)
        iLo=valleysIdx(end);
    else
        iLo=valleysIdx(i);
    end
    i=find(valleysIdx>mainLobePeakIdx,1,'first');
    if isempty(i)
        iHi=valleysIdx(1);
    else
        iHi=valleysIdx(i);
    end

    L.mainLobe.extent=[iLo,iHi];














    idx=(1:Nv)';
    sideLobeExtents=valleysIdx([idx,circshift(idx,-1)]);







    idx=find(sideLobeExtents(:,1)-L.mainLobe.extent(1)==0);
    assert(~isempty(idx));

    sideLobeExtents(idx,:)=[];











    mainAng=L.mainLobe.angle;
    backRefAng=mainAng-180;






    if fullCircle||...
        internal.polariCommon.anglesWithinSpan(backRefAng,angleSpan)













        tempLobeAng=angd(sideLobeExtents);
        if isvector(tempLobeAng)
            tempLobeAng=tempLobeAng(:).';
        end
        idx=internal.polariCommon.spanContainingAngle(...
        tempLobeAng*pi/180,backRefAng*pi/180);
        if isempty(idx)

            backLobeExtent=[];
        else

            assert(isscalar(idx))
            backLobeExtent=sideLobeExtents(idx,:);

            L.backLobe.extent=backLobeExtent;

            sideLobeExtents(idx,:)=[];
        end
    else


        backLobeExtent=[];
    end








    if~isempty(backLobeExtent)





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
...
...
...
...




        L.backLobe.angle=backRefAng;
        [L.backLobe.magnitude,L.backLobe.index]=...
        internal.polariCommon.polarInterp(backRefAng,angd,mag);
    end




    L.sideLobes.extent=sideLobeExtents;




    [val,idx]=max(mag(peaksIdx));
    L.sideLobes.index=peaksIdx(idx);
    L.sideLobes.angle=angd(peaksIdx(idx));
    L.sideLobes.magnitude=val;



    m1=L.mainLobe.magnitude;
    if~isempty(m1)




        m2=L.backLobe.magnitude;
        if~isempty(m2)
            L.FB=m1-m2;
            L.FBIdx=[L.mainLobe.index,L.backLobe.index];
        end




        m2=L.sideLobes.magnitude;
        if~isempty(m2)
            L.SLL=m1-m2;



            L.SLLIdx=[L.mainLobe.index,L.sideLobes.index];
        end


        ext=L.mainLobe.extent;
        L.FNBW=internal.polariCommon.angleDiff(angd(ext)*pi/180)*180/pi;
        L.FNBWIdx=ext;


        [L.HPBW,L.HPBWAng,L.HPBWIdx]=internal.calc_bw(mag,0,angd,...
        dbdown,interp_HPBW,1,fullCircle);
    end

end

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
...
...

