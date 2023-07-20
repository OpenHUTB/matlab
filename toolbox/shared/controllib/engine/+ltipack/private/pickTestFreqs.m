function ws=pickTestFreqs(heigs,w_acc,fBand,fpeak)









    JWTOL=10*sqrt(eps);
    ws=imag(heigs);
    aws=abs(ws);
    ws=sort(ws(abs(real(heigs))<JWTOL*aws&aws>fBand(1)&aws<fBand(2)));

    if isempty(ws)


        [~,imin]=min(abs(heigs-complex(0,fpeak)));

        ws=imag(heigs(imin));
    else

        ws=localCheckCrossovers(ws,w_acc,fBand);

        if ws(1)>0
            ws=sqrt(ws(1:end-1).*ws(2:end));
        elseif ws(end)<0
            ws=-sqrt(ws(1:end-1).*ws(2:end));
        else

            wsn=ws(ws<0);
            wsp=ws(ws>0);
            w0=[wsn(end);ws(ws==0,:);wsp(1)];
            ws=cat(1,...
            -sqrt(wsn(1:end-1,:).*wsn(2:end,:)),...
            (w0(1:end-1,:)+w0(2:end,:))/2,...
            sqrt(wsp(1:end-1,:).*wsp(2:end,:)));
        end
    end
    aws=abs(ws);
    ws=ws(aws>fBand(1)&aws<fBand(2),:);




    function ws=localCheckCrossovers(ws,w_acc,fBand)















        IP=(rem(numel(ws),2)>0);
        wxp=localSupplement(ws(ws>0),w_acc,fBand,IP);
        wxn=localSupplement(-ws(ws<0),w_acc,fBand,IP);
        if~(isempty(wxp)&&isempty(wxn))
            ws=unique([ws;wxp;-wxn]);
        end


        function wx=localSupplement(ws,w_acc,fBand,IP)

            wx=zeros(0,1);
            if~isempty(ws)
                fmin=fBand(1);fmax=fBand(2);
                LFA=(w_acc(1)>fmin&&w_acc(1)<fmax);
                HFA=(w_acc(2)>fmin&&w_acc(2)<fmax);
                if IP||LFA||HFA

                    if LFA
                        wx=[wx;w_acc(1)*[1e-4;4e-2;1]];
                    elseif IP
                        wx=[wx;max(sqrt(fmin*ws(1)),ws(1)/25);fmin(fmin>0,:)];
                    end

                    if HFA
                        wx=[wx;w_acc(2)*[1;25;1e4]];
                    elseif IP
                        wx=[wx;min(sqrt(fmax*ws(end)),25*ws(end));fmax(fmax<Inf,:)];
                    end


                    wx=wx(wx>=fBand(1)&wx<=fBand(2),:);
                end
            end