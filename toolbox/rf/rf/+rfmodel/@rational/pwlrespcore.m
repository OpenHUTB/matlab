function[tran,t]=pwlrespcore(h,signaltime,signalvalue,tsim,varargin)

























































    narginchk(4,6);


    if~isequal(size(signaltime),size(signalvalue))
        error(message('rf:rfmodel:rational:pwlresp:UnpairedInputSignal',...
        num2str(size(signaltime)),num2str(size(signalvalue))));
    else
        tin=signaltime;
        datain=signalvalue;
    end

    validateattributes(datain,{'numeric'},...
    {'nonempty','vector','real','finite','nonnan'},'','SIGNALVALUE')
    datain=datain(:);

    validateattributes(tin,{'numeric'},{'nonempty','vector','real',...
    'nonnegative','finite','nonnan','increasing'},'','SIGNALTIME')
    tin=tin(:);

    validateattributes(tsim,{'numeric'},{'nonempty','vector','real',...
    'nonnegative','finite','nonnan','nondecreasing'},'','TSIM')
    tsim=tsim(:);

    tmax=max(tsim);

    Tper=-1;
    mode='Normal';
    if nargin>=5
        Tper=varargin{1};
        validateattributes(Tper,{'numeric'},...
        {'nonempty','scalar','real','finite','nonnan','nonnegative'},...
        '','TPER')
        if tin(end)-Tper>eps(Tper)
            error(message(...
            'rf:rfmodel:rational:pwlresp:IncorrectSignalPeriod',...
            num2str(Tper),num2str(max(tin))));
        end
    end

    if Tper~=-1&&tmax<=Tper


        Tper=-1;
    end

    if nargin==6
        flag=varargin{2};
        if isstring(flag)
            flag=convertStringsToChars(flag);
        end
        validateattributes(flag,{'char'},{'scalartext'})
        mode=validatestring(flag,{'Rapid'},'pwlresp',flag,6);
        if tsim(1)~=0.0
            error(message(...
            'rf:rfmodel:rational:pwlresp:IncorrectRapidSimTime',...
            num2str(min(tsim))));
        end
        if Tper==-1
            mode='Normal';
        end
    end

    if tin(1)~=0.0
        tin=[0;tin];
        datain=[datain(1);datain];
    end

    if Tper==-1
        if max(tin)<tmax
            intime=[tin;tmax];
            insig=[datain;datain(length(datain))];
        else
            insig=datain;
            intime=tin;
        end
    else
        if max(tin)<Tper
            intime=[tin;Tper];
            insig=[datain;datain(length(datain))];
        else
            insig=datain;
            intime=tin;
        end
    end

    [tran,t]=waveform(h,intime,insig,tsim,Tper,mode);
end

function[twaveout,toutpts]=waveform(h,intime,insig,tout,Tper,mode)

    [numRows,numCols]=size(h);
    if numRows*numCols==1

        checkproperty(h);
        poles=h.A;
        c=h.C;
        d=h.D;
        delay=h.Delay;

        switch Tper
        case(-1)
            twaveout=zeros(size(tout));
            for ip=1:length(tout)
                ttp=tout(ip);
                if ttp>delay
                    [inpvalueTTP,isec]=preeval(delay,intime,insig,ttp);
                    [resp,~]=resp4ttp(poles,c,d,delay,intime,...
                    insig,-1,ttp,inpvalueTTP,isec,false);
                    twaveout(ip)=resp;
                else
                    twaveout(ip)=0.0;
                end
            end
            toutpts=tout;
        otherwise

            switch(mode)
            case('Normal')
                tout_rem=tout(tout>delay);
                twaveout=zeros(size(tout));
                it=length(tout(tout<=delay));
                k=0;
                while~isempty(tout_rem)
                    xj=(k+1)*Tper+delay;
                    idx=tout_rem<=xj;
                    tnt=tout_rem(idx);
                    tout_next=tout_rem(~idx);
                    tout_rem=tout_next;
                    for ip=1:length(tnt)
                        ttp=tnt(ip);
                        tprev=k*Tper+delay;
                        [inpvalueTTP,isecTTP]=preeval(tprev,...
                        intime,insig,ttp);
                        resp=resp4ttp(poles,c,d,tprev,intime,...
                        insig,-1,ttp,inpvalueTTP,isecTTP,false);
                        if k>=1
                            resp_epT=resp4ttp(poles,c,d,delay,...
                            intime,insig,Tper,ttp,[],...
                            length(intime)-1,false);
                        else
                            resp_epT=0.0;
                        end
                        if k<=1
                            resp_epD=0.0;
                        else
                            r=0.0;
                            for m=1:k-1
                                r=r+...
                                resp4ttp(poles,c,d,delay,...
                                intime,insig,Tper,ttp-m*Tper,...
                                [],length(intime)-1,false);
                            end
                            resp_epD=r;
                        end
                        twaveout(ip+it)=resp+resp_epD+resp_epT;
                    end
                    it=it+length(tnt);
                    k=k+1;
                end
                twaveout(tout<=delay)=0.0;
                toutpts=tout;
            case('Rapid')
                idx=tout<=Tper+delay;
                t_1st=tout(idx);
                idx2=t_1st>delay;
                t1st_rem=t_1st(idx2);
                len_t1strem=length(t1st_rem);
                kp=0;
                tsecmax=max(t1st_rem);
                while tsecmax<tout(end)
                    kp=kp+1;
                    tsecmax=Tper+tsecmax;
                end
                treshape=zeros(kp*len_t1strem,1);
                for mkp=1:kp
                    treshape(...
                    (1+(mkp-1)*len_t1strem):mkp*len_t1strem,1)=...
                    t1st_rem+mkp*Tper;
                end
                idxall=treshape<=tout(end);
                treshape=treshape(idxall);

                treshape=[t1st_rem;treshape];
                t_1stled=t_1st(t_1st<=delay);
                it=length(t_1stled);
                t4fast=[t_1stled;treshape];
                resp_tn=zeros(len_t1strem,1);
                twaveoutf=zeros(size(t4fast));
                [~,YT]=resp4ttp(poles,c,d,delay,intime,insig,...
                Tper,Tper,[],length(intime)-1,true);
                for k=0:kp
                    xj=(k+1)*Tper+delay;
                    idx=treshape<=xj;
                    tnt=treshape(idx);
                    if xj<treshape(end)
                        if length(tnt)<len_t1strem
                            nxt_offnum=len_t1strem-length(tnt);
                        else
                            nxt_offnum=0;
                        end
                        tpt4next=treshape(~idx);

                        treshape=tpt4next(1+nxt_offnum:end);
                    end
                    for ip=1:length(tnt)
                        ttp=tnt(ip);
                        if k==0
                            tprev=delay;
                            [inpvalueTTP,isecTTP]=preeval(tprev,...
                            intime,insig,ttp);
                            [resp,~]=resp4ttp(poles,c,d,tprev,...
                            intime,insig,-1,ttp,inpvalueTTP,...
                            isecTTP,false);
                            resp_tn(ip)=resp;
                            twaveoutf(ip+it)=resp;
                        else
                            tn=ttp-k*Tper;
                            r=0.0;
                            for nt=1:k
                                exptnT=exp(poles.*(tn+(nt-1)*Tper));
                                r=r+sum(exptnT.*YT);
                            end
                            twaveoutf(ip+it)=r+resp_tn(ip);
                        end
                        t4fast(ip+it)=ttp;
                    end
                    it=it+ip;
                end
                toutpts=t4fast(1:it);
                twaveoutf(t4fast<=delay)=0.0;
                twaveout=twaveoutf(1:it);
            end
        end
    else
        twaveout=cell(numRows,numCols);
        toutpts=twaveout;
        for iRow=1:numRows
            for iCol=1:numCols
                [twaveout{iRow,iCol},toutpts{iRow,iCol}]=...
                waveform(h(iRow,iCol),intime,insig,tout,Tper,mode);
            end
        end
    end
end

function[ynt,yt]=resp4ttp(poles,c,d,delay,intime,insig,Tper,ttp,...
    yvalue,isection,getYT)


    td=ttp-delay;
    tsig=[intime(1:isection);td];
    if~isempty(yvalue)
        yy=yvalue;
    else
        yy=insig(end);
    end
    if Tper==-1
        G1=sum((c./poles).*(insig(1)*exp(poles*td)-yy));
    else
        if getYT
            G1vec=(c./poles).*...
            (insig(1)*exp(poles*td)-yy*exp(poles*(td-Tper)));
        else
            G1=sum((c./poles).*...
            (insig(1)*exp(poles*td)-yy*exp(poles*(td-Tper))));
        end
    end
    if d~=0.0
        if getYT
            G1vec=G1vec+d*yy;
        else
            G1=G1+d*yy;
        end
    end
    if getYT
        G2vec=0.0;
    else
        G2=0.0;
    end
    for jm=1:isection
        dfdt=(insig(jm+1)-insig(jm))/(intime(jm+1)-intime(jm));
        if dfdt~=0
            if Tper==-1
                td1=td-tsig(jm+1);
                td2=td-tsig(jm);
            else
                td1=td-intime(jm+1);
                td2=td-intime(jm);
            end

            if getYT
                Hvec=-(dfdt./poles).*(c./poles).*(exp(poles*td1)-...
                exp(poles*td2));
                G2vec=G2vec+Hvec;
            else
                H=-sum((dfdt./poles).*(c./poles).*(exp(poles*td1)-...
                exp(poles*td2)));
                G2=G2+H;
            end

        end
    end
    if getYT
        yt=G1vec+G2vec;
        ynt='';
    else
        ynt=G1+G2;
        yt='';
    end
end

function[yy,isection]=preeval(toffset,intime,insig,tin)


    tend=tin-toffset;
    isection=1;
    for i=1:length(intime)-2
        if tend>intime(i+1)
            isection=isection+1;
        end
    end

    if tend==intime(isection+1)

        yy=insig(isection+1);
    else
        delta=tend-intime(isection);

        tsi=intime(isection+1)-intime(isection);
        if insig(isection+1)==insig(isection)

            yy=insig(isection);
        elseif insig(isection+1)>insig(isection)
            yy=(delta/tsi)*(insig(isection+1)-insig(isection))+insig(isection);
        else
            yy=(1-delta/tsi)*(insig(isection)-insig(isection+1))+...
            insig(isection+1);
        end
    end
end