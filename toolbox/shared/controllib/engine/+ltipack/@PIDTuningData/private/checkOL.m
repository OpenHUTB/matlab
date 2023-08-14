function PM=checkOL(w,mag,ph,w0,ph0,mu0)





















    TWOPI=2*pi;
    inBW=(mag>1);
    wph0=mod(ph0+pi,TWOPI)-pi;

    if inBW(end)||round((ph0-wph0)/TWOPI)~=mu0||~all(inBW(w<0.999*w0))


        PM=0;
    else

        PM=pi-abs(wph0);

        inBW=inBW&w>1.001*w0;
        idxc=find(xor(inBW(1:end-1),inBW(2:end)));
        if~isempty(idxc)

            t=-log(mag(idxc))./log(mag(idxc+1)./mag(idxc));

            phc=(1-t).*ph(idxc)+t.*ph(idxc+1);
            wphc=mod(phc+pi,TWOPI)-pi;
            muc=phc-wphc;
            if abs(sum(muc(2:2:end))-sum(muc(1:2:end)))>1
                PM=0;
            else
                PM=min([PM;pi-abs(wphc)]);
            end
        end
    end
