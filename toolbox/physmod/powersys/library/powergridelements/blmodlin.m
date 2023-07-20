function[Zc,rmode,v,Ti]=blmodlin(nphase,f,r,l,c,BlockName)








































    if nphase==1

        r=r(1);
        l=l(1);
        c=c(1);


    end

    j=sqrt(-1);
    w=2*pi*f;

    [nline,ncol]=size(r);



    if nline==1&&ncol==1,


        y=j*c*w;
        z=r+j*l*w;
    elseif nline==1&&(ncol==2||ncol==3),





        if nphase==2,
            zself=(r(2)+r(1))/2+j*(l(2)+l(1))/2*w;
            zmut=(r(2)-r(1))/2+j*(l(2)-l(1))/2*w;
            yself=j*(c(2)+c(1))/2*w;
            ymut=j*(c(2)-c(1))/2*w;

            z=zmut*ones(2,2);z(1,1)=zself;z(2,2)=zself;
            y=ymut*ones(2,2);y(1,1)=yself;y(2,2)=yself;



        elseif nphase==3,

            zself=(r(2)+2*r(1))/3+j*(l(2)+2*l(1))/3*w;
            zmut=(r(2)-r(1))/3+j*(l(2)-l(1))/3*w;
            yself=j*(c(2)+2*c(1))/3*w;
            ymut=j*(c(2)-c(1))/3*w;

            z=zmut*ones(3,3);z(1,1)=zself;z(2,2)=zself;z(3,3)=zself;
            y=ymut*ones(3,3);y(1,1)=yself;y(2,2)=yself;y(3,3)=yself;



        elseif nphase==6,
            zself=(r(2)+2*r(1))/3+j*(l(2)+2*l(1))/3*w;
            zmut=(r(2)-r(1))/3+j*(l(2)-l(1))/3*w;
            zmut12=r(3)/3+j*l(3)/3*w;
            yself=j*(c(2)+2*c(1))/3*w;
            ymut=j*(c(2)-c(1))/3*w;
            ymut12=j*c(3)/3*w;

            z=zmut*ones(6,6);
            z(1,1)=zself;z(2,2)=zself;z(3,3)=zself;
            z(4,4)=zself;z(5,5)=zself;z(6,6)=zself;
            z(1:3,4:6)=zmut12*ones(3,3);
            z(4:6,1:3)=zmut12*ones(3,3);
            y=ymut*ones(6,6);
            y(1,1)=yself;y(2,2)=yself;y(3,3)=yself;
            y(4,4)=yself;y(5,5)=yself;y(6,6)=yself;
            y(1:3,4:6)=ymut12*ones(3,3);
            y(4:6,1:3)=ymut12*ones(3,3);
        end
    else
        y=j*c*w;
        z=r+j*l*w;
    end






    transpose=1;
    for i=1:nphase
        for k=1:nphase,
            if i==k,

                if~(z(i,i)==z(1,1)&&y(i,i)==y(1,1)),
                    transpose=0;
                end
            else

                if~(z(i,k)==z(1,2)&&y(i,k)==y(1,2)),
                    transpose=0;
                end
            end
        end
    end



    twocir_sym=0;
    if nphase==6&&~transpose,
        if...
            all(all(diag(z)==z(1,1)))&&...
            all(all(diag(y)==y(1,1)))&&...
            all(all(z(1:3,1:3)==z(4:6,4:6)))&&...
            all(all(y(1:3,1:3)==y(4:6,4:6)))&&...
            all(all(z(1:3,4:6)==z(1,4)))&&...
            all(all(z(4:6,1:3)==z(1,4)))&&...
            all(all(y(1:3,4:6)==y(1,4)))&&...
            all(all(y(4:6,1:3)==y(1,4)))
            twocir_sym=1;
        end
    end



    if transpose,







        Ti=zeros(nphase,nphase);
        Ti(1:nphase,1)=1/sqrt(nphase)*ones(nphase,1);
        for i=2:nphase
            Ti(i,i)=-(i-1)/sqrt(i*(i-1));
            for k=2:nphase,
                Ti(1:k-1,k)=1/sqrt(k*(k-1))*ones(k-1,1);
            end
        end
        Tv=Ti;

    elseif twocir_sym,


        Ti=1/sqrt(6)*[1,1,sqrt(3),1,0,0
        1,1,-sqrt(3),1,0,0
        1,1,0,-2,0,0
        1,-1,0,0,sqrt(3),1
        1,-1,0,0,-sqrt(3),1
        1,-1,0,0,0,-2];
        Tv=Ti;

    else




        [Ti,vp]=eig(y*z);%#ok

        Ti=real(Ti);
        Tv=inv(Ti');
    end



    zmode=inv(Tv)*z*Ti;
    ymode=inv(Ti)*y*Tv;

    rmode=real(diag(zmode))';
    Zc=sqrt(imag(diag(zmode))./imag(diag(ymode)))';
    v=w./sqrt(imag(diag(zmode)).*imag(diag(ymode)))';



    n=find(v>=300000);
    if~isempty(n)
        if exist('BlockName','var')
            message=sprintf('A propagation speed of %g km/s has been found for mode %d in block ''%s''; Propagation speeds must be < 300000 km/s!',v(n(1)),n(1),BlockName);
            warndlg(message,'parameter error','replace');
            warning('SpecializedPowerSystems:InvalidParameters',message);%#ok
        else
            message=sprintf('A propagation speed of %g km/s has been found for mode %d; Propagation speeds must be < 300000 km/s!',v(n(1)),n(1));
            warndlg(message,'parameter error','replace');
            warning('SpecializedPowerSystems:InvalidParameters',message);%#ok
        end
    end