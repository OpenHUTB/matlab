function[mag_i,mag_scaled_i,nonRadial]=getInterpMagFromPoint(p,pt,datasetIndex)








    nonRadial=false;
    mag_i=[];
    mag_scaled_i=[];
    pdata=getDataset(p,datasetIndex);
    if isempty(pdata)
        return
    end
    th_all=pdata.ang;
    if isempty(th_all)
        return
    end



    th_pt=atan2(pt(2),pt(1));
    cplx_pt=complex(cos(th_pt),sin(th_pt));


    th_all=getNormalizedAngle(p,th_all);
    cplx_all=complex(cos(th_all),sin(th_all));





    [~,idx1]=min(abs(bsxfun(@minus,cplx_all,cplx_pt)));











    Nc=numel(cplx_all);
    idx1_m1=idx1-1;
    if idx1_m1<1
        idx1_m1=Nc;
    end
    idx1_p1=idx1+1;
    if idx1_p1>Nc
        idx1_p1=1;
    end


    idx_all=[idx1_m1,idx1,idx1_p1];
    cplx_adj=cplx_all(idx_all);

    [ad_ccw,ad_cw]=internal.polariCommon.cangleDiff(cplx_pt,cplx_adj);
    [~,i1]=min(ad_ccw);idx1=idx_all(i1);
    [~,i2]=min(ad_cw);idx2=idx_all(i2);

    mag=pdata.mag;

    if idx1==1&&idx2==Nc||idx2==1&&idx1==Nc



        nonRadial=true;
        mag_i=NaN;
    else




        th1=th_all(idx1);
        th2=th_all(idx2);
        r1=getNormalizedMag(p,mag(idx1));
        r2=getNormalizedMag(p,mag(idx2));
        c1=r1*complex(cos(th1),sin(th1));
        c2=r2*complex(cos(th2),sin(th2));







        x1=real(c1);
        y1=imag(c1);
        x2=real(c2);
        y2=imag(c2);
        x3=pt(1,1);
        y3=pt(1,2);





        denom=(x1-x2)*y3-(y1-y2)*x3;
        if denom==0

            xp=0;
            yp=0;
        else




            xp=(x1*y2-y1*x2)*x3./denom;
            yp=(x1*y2-y1*x2)*y3./denom;
        end
        mag_i=norm([xp,yp]);
    end
    mag_scaled_i=transformNormMagToUserMag(p,mag_i);
