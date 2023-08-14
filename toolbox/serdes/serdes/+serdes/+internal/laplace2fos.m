function fos=laplace2fos(Poles,Zeros,Tau)








































%#codegen
    coder.allowpcode('plain')

    if isempty(Poles)

        fos=[1,0,0,0,0,1,0,0,0,0];
        return;
    end
    validateattributes(Poles,{'numeric'},{'column'});
    validateattributes(Tau,{'numeric'},{'scalar'});
    if~isempty(Zeros)
        validateattributes(Zeros,{'numeric'},{'column'});
    end
    np=size(Poles,1);
    nz=size(Zeros,1);
    if nz>np





        coder.internal.errorIf(nz>=np,...
        'serdes:utilities:NotLessZerosThanPoles',...
        nz,np);
    end
    nsections=ceil(np/2);
    psect=cell(nsections,1);
    zsect=cell(nsections,1);
    fos=zeros(nsections,10);




    psorted=cplxpair(-Poles,1e-8);
    for indx=1:nsections
        if 2*indx<=np

            if(imag(-psorted(2*indx-1))>=pi/Tau)





            end
            psect{indx}=[-psorted(2*indx-1);-psorted(2*indx)];
        else
            psect{indx}=-psorted(np);
        end
    end


    zsorted=cplxpair(-Zeros,1e-8);

    for indx=1:nsections
        if 2*indx<=nz

            if(imag(-zsorted(2*indx-1))>=pi/Tau)






            end
            zsect{indx}=[-zsorted(2*indx-1);-zsorted(2*indx)];
        elseif 2*indx-1==nz
            zsect{indx}=-zsorted(2*indx-1);
        else
            zsect{indx}=[];
        end
    end





    for indx=1:nsections
        yndx=indx;
        zndx=indx;
        nn=size(zsect{zndx},1);
        if nn==2
            diff=psect{indx}-zsect{zndx};
            rmin=abs(diff(1))*abs(diff(2));
        else
            rmin=inf;
        end
        zndx=zndx+1;
        while zndx<=nsections&&nn==2
            nn=size(zsect{zndx},1);
            if nn==2
                diff=psect{indx}-zsect{zndx};
                r=abs(diff(1))*abs(diff(2));
                if r<rmin
                    yndx=zndx;
                    rmin=r;
                end
            end
            zndx=zndx+1;
        end
        if rmin<inf&&yndx~=indx
            tmp=zsect{indx};
            zsect{indx}=zsect{yndx};
            zsect{yndx}=tmp;
        end
    end



    for indx=1:nsections
        fos(indx,:)=serdes.internal.map2qquad(...
        Tau,psect{indx},zsect{indx});
    end
end

