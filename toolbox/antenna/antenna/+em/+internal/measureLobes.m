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


        [hpAng,idx]=findHalfPowerAngles(L,angd,mag,fullCircle);
        L.HPBW=internal.polariCommon.angleDiff(hpAng*pi/180)*180/pi;
        L.HPBWAng=hpAng;
        L.HPBWIdx=idx;
    end

end

function[hpAng,closestIdx]=findHalfPowerAngles(L,angd,mag,fullCircle)






    hpAng=[];
    closestIdx=[];


    ext=L.mainLobe.extent;
    e1Idx=ext(1);
    e2Idx=ext(2);


    magPk=L.mainLobe.magnitude;
    mag3dB=magPk-3;
    pkIdx=L.mainLobe.index;





    if e1Idx>pkIdx
        if fullCircle
            m=mag([e1Idx:end,1:pkIdx]);
            a=angd([e1Idx:end,1:pkIdx]);
        else
            m=mag(e1Idx:end);
            a=angd(e1Idx:end);
        end
    else
        m=mag(e1Idx:pkIdx);
        a=angd(e1Idx:pkIdx);
    end



    [a1,i1]=interpLargelyIncrX(m,a,mag3dB);
    if isempty(a1)
        return
    end



    Nd=numel(mag);
    i1=i1+e1Idx-1;
    if i1>Nd
        i1=i1-Nd+1;
    end





    if pkIdx>e2Idx
        if fullCircle
            m=flip(mag([pkIdx:end,1:e2Idx]));
            a=flip(angd([pkIdx:end,1:e2Idx]));
        else
            m=flip(mag(pkIdx:end));
            a=flip(angd(pkIdx:end));
        end
    else
        m=flip(mag(pkIdx:e2Idx));
        a=flip(angd(pkIdx:e2Idx));
    end
    [a2,i2]=interpLargelyIncrX(m,a,mag3dB);
    if isempty(a2)
        return
    end



    Nm=numel(m);
    i2=(Nm-i2+1)+pkIdx-1;
    if i2>Nd
        i2=i2-Nd+1;
    end

    hpAng=[a1,a2];
    closestIdx=[i1,i2];

end

function[av,idx]=interpLargelyIncrX(m,a,mv)











    i1=find(m<=mv);
    i1(i1==numel(m))=[];
    if isempty(i1)
        av=[];
        idx=[];
        return
    end
    i1=i1(end);


    m1=m(i1);
    m2=m(i1+1);
    frac=(mv-m1)/(m2-m1);
    idx=i1+frac;
    av=a(i1)+frac*...
    internal.polariCommon.angleDiffRel(a(i1:i1+1)*pi/180)*180/pi;

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

end


