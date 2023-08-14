function spurdata=addmixerimtspur(h,spurdata,~,~,~,cktindex)





    narginchk(6,6);



    psignal=spurdata.Pin;
    frf=spurdata.Freq{cktindex+1-1}(1);
    flo=h.LO;
    table=h.IMT;
    [N,M]=size(h.IMT);
    nfreq=length(spurdata.Freq{cktindex+1});
    nspur=0;
    if spurdata.TotalNMixers==1
        for n1=1:N
            n=n1-1;
            for m1=1:M
                m=m1-1;
                if((n+m)<=min(N,M))&&(table(n1,m1)<99)
                    pspur=psignal-table(n1,m1);
                    if(n==1)&&(m==1)
                        if strcmpi(h.ConverterType,'Down')
                            fspur=frf+flo;
                            idxspur='Spur: F_{RF}+F_{LO}';
                        else
                            fspur=abs(frf-flo);
                            idxspur='Spur: |F_{RF}-F_{LO}|';
                        end
                        nspur=nspur+1;
                        spurdata.Pout{cktindex+1}(nfreq+nspur,1)=pspur;
                        spurdata.Freq{cktindex+1}(nfreq+nspur,1)=fspur;
                        spurdata.Indexes{cktindex+1}{nfreq+nspur,1}=idxspur;
                        spurdata.Pin(nspur,1)=pspur;
                        spurdata.Fin(nspur,1)=fspur;
                        spurdata.Idxin{nspur,1}=idxspur;
                    else
                        fspur=abs(n*frf-m*flo);
                        if m==0
                            if n==1
                                idxspur='Spur: F_{RF}';
                            else
                                idxspur=sprintf('Spur: %d*F_{RF}',n);
                            end
                        elseif n==0
                            if m==1
                                idxspur='Spur: F_{LO}';
                            else
                                idxspur=sprintf('Spur: %d*F_{LO}',m);
                            end
                        elseif m==1
                            if n==1
                                idxspur='Spur: |F_{RF}-F_{LO}|';
                            else
                                idxspur=sprintf('Spur: |%d*F_{RF}-F_{LO}|',n);
                            end
                        elseif n==1
                            idxspur=sprintf('Spur: |F_{RF}-%d*F_{LO}|',m);
                        else
                            idxspur=sprintf('Spur: |%d*F_{RF}-%d*F_{LO}|',n,m);
                        end
                        nspur=nspur+1;
                        spurdata.Pout{cktindex+1}(nfreq+nspur,1)=pspur;
                        spurdata.Freq{cktindex+1}(nfreq+nspur,1)=fspur;
                        spurdata.Indexes{cktindex+1}{nfreq+nspur,1}=idxspur;
                        spurdata.Pin(nspur,1)=pspur;
                        spurdata.Fin(nspur,1)=fspur;
                        spurdata.Idxin{nspur,1}=idxspur;
                        if~(n==0)&&~(m==0)
                            fspur=n*frf+m*flo;
                            if m==1
                                if n==1
                                    idxspur='Spur: F_{RF}+F_{LO}';
                                else
                                    idxspur=sprintf('Spur: %d*F_{RF}+F_{LO}',n);
                                end
                            elseif n==1
                                if m==1
                                    idxspur='Spur: F_{RF}+F_{LO}';
                                else
                                    idxspur=sprintf('Spur: F_{RF}+%d*F_{LO}',m);
                                end
                            else
                                idxspur=sprintf('Spur: %d*F_{RF}+%d*F_{LO}',n,m);
                            end
                            nspur=nspur+1;
                            spurdata.Pout{cktindex+1}(nfreq+nspur,1)=pspur;
                            spurdata.Freq{cktindex+1}(nfreq+nspur,1)=fspur;
                            spurdata.Indexes{cktindex+1}{nfreq+nspur,1}=idxspur;
                            spurdata.Pin(nspur,1)=pspur;
                            spurdata.Fin(nspur,1)=fspur;
                            spurdata.Idxin{nspur,1}=idxspur;
                        end
                    end
                end
            end
        end
    else
        for n1=1:N
            n=n1-1;
            for m1=1:M
                m=m1-1;
                if((n+m)<=min(N,M))&&(table(n1,m1)<99)
                    pspur=psignal-table(n1,m1);
                    if(n==1)&&(m==1)
                        if strcmpi(h.ConverterType,'Down')
                            fspur=frf+flo;
                            idxspur=sprintf('Spur by mixer_%d: F_{RF}+F_{LO}',...
                            spurdata.NMixers);
                        else
                            fspur=abs(frf-flo);
                            idxspur=sprintf('Spur by mixer_%d: |F_{RF}-F_{LO}|',...
                            spurdata.NMixers);
                        end
                        nspur=nspur+1;
                        spurdata.Pout{cktindex+1}(nfreq+nspur,1)=pspur;
                        spurdata.Freq{cktindex+1}(nfreq+nspur,1)=fspur;
                        spurdata.Indexes{cktindex+1}{nfreq+nspur,1}=idxspur;
                        spurdata.Pin(nspur,1)=pspur;
                        spurdata.Fin(nspur,1)=fspur;
                        spurdata.Idxin{nspur,1}=idxspur;
                    else
                        fspur=abs(n*frf-m*flo);
                        if m==0
                            idxspur=sprintf('Spur by mixer_%d: %d*F_{RF}',...
                            spurdata.NMixers,n);
                        elseif n==0
                            idxspur=sprintf('Spur by mixer_%d: %d*F_{LO}',...
                            spurdata.NMixers,m);
                        elseif m==1
                            idxspur=sprintf('Spur by mixer_%d: |%d*F_{RF}-F_{LO}|',...
                            spurdata.NMixers,n);
                        elseif n==1
                            idxspur=sprintf('Spur by mixer_%d: |F_{RF}-%d*F_{LO}|',...
                            spurdata.NMixers,m);
                        else
                            idxspur=sprintf(...
                            'Spur by mixer_%d: |%d*F_{RF}-%d*F_{LO}|',...
                            spurdata.NMixers,n,m);
                        end
                        nspur=nspur+1;
                        spurdata.Pout{cktindex+1}(nfreq+nspur,1)=pspur;
                        spurdata.Freq{cktindex+1}(nfreq+nspur,1)=fspur;
                        spurdata.Indexes{cktindex+1}{nfreq+nspur,1}=idxspur;
                        spurdata.Pin(nspur,1)=pspur;
                        spurdata.Fin(nspur,1)=fspur;
                        spurdata.Idxin{nspur,1}=idxspur;
                        if~(n==0)&&~(m==0)
                            fspur=n*frf+m*flo;
                            if m==1
                                idxspur=sprintf('Spur by mixer_%d: %d*F_{RF}+F_{LO}',...
                                spurdata.NMixers,n);
                            elseif n==1
                                idxspur=sprintf('Spur by mixer_%d: F_{RF}+%d*F_{LO}',...
                                spurdata.NMixers,m);
                            else
                                idxspur=sprintf(...
                                'Spur by mixer_%d: %d*F_{RF}+%d*F_{LO}',...
                                spurdata.NMixers,n,m);
                            end
                            nspur=nspur+1;
                            spurdata.Pout{cktindex+1}(nfreq+nspur,1)=pspur;
                            spurdata.Freq{cktindex+1}(nfreq+nspur,1)=fspur;
                            spurdata.Indexes{cktindex+1}{nfreq+nspur,1}=idxspur;
                            spurdata.Pin(nspur,1)=pspur;
                            spurdata.Fin(nspur,1)=fspur;
                            spurdata.Idxin{nspur,1}=idxspur;
                        end
                    end
                end
            end
        end
    end
end