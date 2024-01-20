function[a,c,d,delay,outsize,errdb]=rationalfitcore(freq,data,varargin)

    nargoutchk(0,6)

    if nargin>2&&any(cellfun(@(x)ischar(x)&~isempty(x),varargin))
        narginchk(4,16)
        p=inputParser;
        p.CaseSensitive=false;
        p.addOptional('Tolerance',-40);
        p.addParameter('Weight',NaN);
        p.addParameter('DelayFactor',0);
        p.addParameter('TendsToZero',true);
        p.addParameter('NPoles',[0,48]);
        p.addParameter('IterationLimit',[4,24]);
        p.addParameter('WaitBar',false);
        p.parse(varargin{:});
        args=p.Results;
        defaultweight=any(strcmp('Weight',p.UsingDefaults));
    else

        narginchk(2,9)
        names={'Tolerance','Weight','DelayFactor','TendsToZero','NPoles',...
        'IterationLimit','WaitBar'};
        values={-40,[],0,true,[0,48],[4,24],false};
        nonempties=cellfun(@(x)~isempty(x),varargin);
        values(nonempties)=varargin(nonempties);
        args=cell2struct(values,names,2);
        defaultweight=isempty(args.Weight);
    end
    freq=freq(:);
    rows=numel(freq);

    rfValidateFreq(freq)
    rfValidateData(data)
    rfValidateTolerance(args.Tolerance)
    rfValidateDelayFactor(args.DelayFactor)
    rfValidateTendsToZero(args.TendsToZero)
    validateattributes(args.NPoles,{'numeric'},...
    {'nonempty','vector','integer','nonnegative','nondecreasing'},'',...
    'NPoles')
    validateattributes(args.IterationLimit,{'numeric'},...
    {'nonempty','vector','integer','positive','nondecreasing'},'',...
    'IterationLimit')
    validateattributes(args.WaitBar,{'logical','numeric'},...
    {'nonempty','scalar'},'','WaitBar')

    if ndims(data)>3
        error(message('rf:rationalfit:Not2Dor3D'))
    elseif ndims(data)==3||rows==1
        datasize=size(data);
        if rows>1&&datasize(3)~=rows
            error(message('rf:rationalfit:Bad3dSize'))
        end
        outsize=datasize(1:2);
        cols=prod(outsize);
        data=reshape(data,cols,rows).';
    else
        if isrow(data)
            data=data(:);
        end
        datasize=size(data);
        if datasize(1)==rows
            outsize=[1,datasize(2)];
            cols=datasize(2);
        elseif datasize(2)==rows
            error(message('rf:rationalfit:DataMustBeColumns'))
        else
            error(message('rf:rationalfit:WrongFreqOrDataInput'))
        end
    end

    if defaultweight
        args.Weight=ones(rows,cols);
    else
        validateattributes(args.Weight,{'numeric'},...
        {'nonempty','real','finite','nonnan','nonnegative'},'','Weight')
        if all(args.Weight(:)==0)
            error(message('rf:rationalfit:AllZeroWeight'))
        elseif isscalar(args.Weight)
            args.Weight=args.Weight*ones(rows,cols);
        elseif isvector(args.Weight)&&numel(args.Weight)==rows
            if isrow(args.Weight)
                args.Weight=args.Weight(:);
            end
            args.Weight=args.Weight(:,ones(1,cols));
        elseif isequal(size(args.Weight),datasize)
            args.Weight=reshape(args.Weight,cols,rows).';
        else
            error(message('rf:rationalfit:WrongWeightSize'))
        end
    end

    [freq,i]=unique(freq);
    if numel(freq)<rows
        error(message('rf:rationalfit:FrequenciesNotUnique'))
    end
    data=data(i,:);
    args.Weight=args.Weight(i,:);

    w=2*pi*freq;
    s=1j*w;
    unwrapped=unwrap(angle(data));
    theta=unwrapped(end,:)-unwrapped(1,:);
    delay=zeros(1,cols);
    if args.DelayFactor>0
        delay=args.DelayFactor*max(0,-theta./(w(end)-w(1)));
        data=data.*exp(delay.*s);
        unwrapped=unwrap(angle(data));
        theta=unwrapped(end,:)-unwrapped(1,:);
    end

    if numel(args.NPoles)>2
        error(message('rf:rationalfit:WrongNPolesLength'))
    end
    maxnp=max(0,rows-(~args.TendsToZero)-(freq(1)==0));
    minnp=min(maxnp,ceil(-min(theta)/pi-args.TendsToZero/2));
    args.NPoles(2)=min(args.NPoles(end),maxnp);
    args.NPoles(1)=min(args.NPoles(2),max(args.NPoles(1),minnp));

    if numel(args.IterationLimit)>2
        error(message('rf:rationalfit:WrongIterationLimitLength'))
    end
    if isscalar(args.IterationLimit)
        args.IterationLimit=[args.IterationLimit,args.IterationLimit];
    end


    opts.offset=~args.TendsToZero;
    opts.weight=args.Weight;
    weightedData=data.*opts.weight;
    opts.rhs=[real(weightedData);imag(weightedData)];
    opts.rweight=norm(weightedData,Inf);
    if rows==1
        if w==0
            opts.wscale=1;
        else
            opts.wscale=w;
        end
    else
        opts.wscale=min(diff(w));
        if 0<w(1)&&w(1)<opts.wscale
            opts.wscale=w(1);
        end
    end
    nleft=args.NPoles(1)-1;
    nright=args.NPoles(2)+1;
    np=nright-1;
    max_tries=ceil(log2(nright-1-nleft)+2);
    best_np=zeros(max_tries,1);
    best_a=cell(max_tries,1);
    best_aU=cell(max_tries,1);
    best_c=cell(max_tries,1);
    best_d=cell(max_tries,1);
    best_errdb=NaN(max_tries,1);
    if args.WaitBar
        barhandle=waitbar(0,'Fitting...','Name','rationalfit',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(barhandle,'canceling',0)
    end
    for numtry=1:max_tries
        if np>0
            poles=guesspoles(np,w,weightedData);
            [errdb,d,c]=calculateResidues(data,s,opts,poles);
            best_np(numtry)=np;
            best_a{numtry}=poles;
            best_aU{numtry}=poles;
            best_c{numtry}=c;
            best_d{numtry}=d;
            best_errdb(numtry)=max(errdb);
            err=Inf(args.IterationLimit(2),1);
            for iter=1:args.IterationLimit(2)
                [errdb,d,c,poles,polesU]=rationalfit_iter(data,s,opts,poles);
                err(iter)=max(errdb);
                if err(iter)<best_errdb(numtry)
                    best_a{numtry}=poles;
                    best_aU{numtry}=polesU;
                    best_c{numtry}=c;
                    best_d{numtry}=d;
                    best_errdb(numtry)=err(iter);
                end

                if iter>=max(4,args.IterationLimit(1))&&...
                    min(err(1:iter-3))<=min(err(iter-2:iter))
                    break
                end
            end
        else
            [errdb,d]=rationalfit_iter(data,s,opts);
            best_np(numtry)=0;
            best_a{numtry}=zeros(0,1);
            best_aU{numtry}=zeros(0,1);
            best_c{numtry}=zeros(0,cols);
            best_d{numtry}=d;
            best_errdb(numtry)=max(errdb);
        end

        if isnan(best_errdb(numtry))||best_errdb(numtry)>args.Tolerance
            nleft=np;
        else
            nright=np;
        end
        if nright==nleft+1
            break
        else
            np=floor((nright+nleft)/2);
        end

        if args.WaitBar&&~getappdata(barhandle,'canceling')
            waitbar(numtry/max_tries)
        end
    end
    if args.WaitBar&&ishghandle(barhandle)
        delete(barhandle)
    end
    succeeded=find(best_errdb<=args.Tolerance);
    if~isempty(succeeded)
        [~,temp]=min(best_np(succeeded));
        best_try=succeeded(temp);
    else
        [~,best_try]=min(best_errdb);
    end

    a=best_a{best_try};
    aU=best_aU{best_try};
    c=best_c{best_try};

    posRealPoles=a==real(a);
    numRealPoles=sum(posRealPoles);
    numCplxPoles=sum(~posRealPoles);
    if numRealPoles&&(numCplxPoles~=0)
        numPoles=numCplxPoles+numRealPoles;

        tmpa=NaN(numPoles,1);
        tmpaU=tmpa;
        tmpc=NaN(numPoles,size(c,2));
        tmpa(1:numCplxPoles)=a(~posRealPoles);
        tmpa(numCplxPoles+1:numPoles)=a(posRealPoles);
        tmpaU(1:numCplxPoles)=aU(~posRealPoles);
        tmpaU(numCplxPoles+1:numPoles)=aU(posRealPoles);
        tmpc(1:numCplxPoles,:)=c(~posRealPoles,:);
        tmpc((numCplxPoles+1:numPoles),:)=c(posRealPoles,:);

        a=tmpa;
        aU=tmpaU;
        c=tmpc;
    end

    i=any(c,2);
    c=c(i,:);
    a=a(i);
    aU=aU(i);
    d=best_d{best_try};
    errdb=best_errdb(best_try);

    if errdb>args.Tolerance
        if any(real(aU)>0)
            errdbU=calculateResidues(data,s,opts,aU);
            if max(errdbU)-errdb<-3
                warning(message('rf:rationalfit:CheckYourData',...
                sprintf('%.1f',errdb),numel(a),...
                sprintf('%.1f',args.Tolerance)))
            else
                warning(message('rf:rationalfit:ErrorToleranceNotMet',...
                sprintf('%.1f',errdb),numel(a),...
                sprintf('%.1f',args.Tolerance)))
            end
        else
            warning(message('rf:rationalfit:ErrorToleranceNotMet',...
            sprintf('%.1f',errdb),numel(a),...
            sprintf('%.1f',args.Tolerance)))
        end
    end


    function poles=guesspoles(np,w,data)

        if np==1
            poles=-w(ceil(numel(w)/2))/sqrt(3);
            return;
        end

        cost=compute_cost(data,np);
        samples=(1:length(w))';
        energy=integrate_piecewise_linear(samples,cost);
        num_pairs=floor(np/2);

        bounds=resample(energy*(num_pairs/energy(end)),samples,(0:num_pairs)');

        samples1=unique([samples;bounds]);
        cost1=resample(samples,cost,samples1);
        w1=resample(samples,w,samples1);
        integral_cost=integrate_piecewise_linear(samples1,cost1);
        integral_w_cost=integrate_piecewise_linear2(samples1,cost1,w1);
        numer=resample(samples1,integral_w_cost,bounds);
        denom=resample(samples1,integral_cost,bounds);
        pair_freqs=diff(numer)./diff(denom);

        imagpart=pair_freqs;
        realpart=-distance(pair_freqs)/sqrt(3);
        poles(2:2:2*num_pairs,1)=complex(realpart,-imagpart);
        poles(1:2:2*num_pairs-1)=complex(realpart,imagpart);
        if mod(np,2)
            poles(np)=mean(real(poles));
        end


        function d=distance(pair_freqs)

            if length(pair_freqs)>2
                d1=diff([-pair_freqs(1);pair_freqs]);
                d2=diff(pair_freqs);
                d2=[d2;d2(end)];
                d=sqrt(d1.*d2);
            elseif length(pair_freqs)==2
                d=diff(pair_freqs)*[1;1];
            else
                d=pair_freqs;
            end


            function int=integrate_piecewise_linear(t,x)

                a=x(1:end-1);
                b=x(2:end);
                average=(a+b)/2;
                int=[0;cumsum(average.*diff(t))];


                function int=integrate_piecewise_linear2(t,x,y)

                    a=x(1:end-1);
                    b=x(2:end);
                    c=y(1:end-1);
                    d=y(2:end);
                    average=(a.*c+b.*d)/3+(b.*c+a.*d)/6;
                    int=[0;cumsum(average.*diff(t))];

                    function y=resample(t,x,t1)

                        y=interp1(t,x,t1,'linear','extrap');


                        function c=compute_cost(data,np)

                            a=sum(abs(data),2);
                            if max(a)>0
                                a=a/max(a);
                            end
                            b=ones(size(a));
                            for t=[1e-8,0.5:0.05:1]
                                c=(1-t)*a+t*b;
                                if 0.5*max(c)<sum(c)/np
                                    return;
                                end
                            end

                            function[errdb,d,c,poles,polesU]=rationalfit_iter(data,s,opts,poles)
                                if nargin<4
                                    poles=zeros(0,1);
                                end
                                [rows,cols]=size(data);
                                np=numel(poles);
                                npo=np+opts.offset;
                                lowerrows=1:rows;
                                upperrows=(rows+1):(2*rows);
                                lowercols=1:npo;
                                uppercols=(npo+1):(npo+np+1);

                                if np>0

                                    DF=residuematrix(poles,s,true);
                                    A=zeros(2*rows+1,npo+np+1);
                                    R22=zeros(cols*(np+1),np+1);
                                    b=zeros(cols*(np+1),1);
                                    relaxRow=real(sum(DF));
                                    for col=1:cols
                                        wDF=opts.weight(:,col).*DF;
                                        A(lowerrows,lowercols)=real(wDF(:,lowercols));
                                        A(upperrows,lowercols)=imag(wDF(:,lowercols));
                                        DP=wDF.*-data(:,col);
                                        A(lowerrows,uppercols)=real(DP);
                                        A(upperrows,uppercols)=imag(DP);
                                        A(2*rows+1,uppercols)=opts.rweight*relaxRow;
                                        col_norm=max(abs(A));
                                        col_norm(col_norm==0)=1;
                                        [Q,R]=qr(A./col_norm,0);
                                        inds=(col*np+col-np):(col*np+col);
                                        R22(inds,:)=R(uppercols,uppercols).*...
                                        col_norm(uppercols);
                                        b(inds)=Q(end,uppercols)'*(opts.rweight*rows);
                                    end
                                    col_norm=max(abs(R22));
                                    col_norm(col_norm==0)=1;
                                    R22=R22./col_norm;
                                    row_norm=max(abs(R22),[],2);
                                    row_norm(row_norm==0)=1;
                                    R22=R22./row_norm;
                                    warn1=warning('off','MATLAB:rankDeficientMatrix');
                                    warn2=warning('off','MATLAB:nearlySingularMatrix');
                                    warn3=warning('off','MATLAB:singularMatrix');
                                    x=(R22\(b./row_norm))./col_norm';
                                    warning(warn3)
                                    warning(warn2)
                                    warning(warn1)
                                    x(~isfinite(x))=0;
                                    A2=zeros(np,np);
                                    b2=zeros(np,1);
                                    k=1;
                                    while k<=np
                                        if imag(poles(k))==0
                                            A2(k,k)=poles(k);
                                            b2(k)=1;
                                            k=k+1;
                                        else
                                            A2(k,k)=real(poles(k));
                                            A2(k+1,k+1)=real(poles(k));
                                            A2(k,k+1)=imag(poles(k));
                                            A2(k+1,k)=-imag(poles(k));
                                            b2(k)=2;
                                            k=k+2;
                                        end
                                    end
                                    c0=x(end);
                                    if c0==0
                                        c0=1;
                                    end
                                    poles=eig(A2-b2*x(1:end-1,1).'/c0);
                                    poles(~isfinite(poles))=0;

                                    polesU=poles;
                                    poles=complex(-abs(real(poles)),imag(poles));
                                end
                                [errdb,d,c]=calculateResidues(data,s,opts,poles);


                                function[errdb,d,c]=calculateResidues(data,s,opts,poles)
                                    [rows,cols]=size(data);
                                    np=numel(poles);
                                    npo=np+opts.offset;
                                    lowerrows=1:rows;
                                    upperrows=(rows+1):(2*rows);
                                    lowercols=1:npo;
                                    DF=residuematrix(poles,s,opts.offset);
                                    errdb=NaN(1,cols);
                                    d=zeros(1,cols);
                                    c=zeros(np,cols);
                                    canCombine=false;
                                    if cols==1
                                        canCombine=true;
                                    else
                                        temp=diff(opts.weight,1,2);
                                        maxdiff=max(temp(:));
                                        if maxdiff==0
                                            canCombine=true;
                                        end
                                    end
                                    if canCombine
                                        wDF=opts.weight(:,1).*DF;
                                        A3(upperrows,lowercols)=imag(wDF(:,lowercols));
                                        A3(lowerrows,lowercols)=real(wDF(:,lowercols));
                                        col_norm=max(abs(A3));
                                        col_norm(col_norm==0)=1;
                                        A3=A3./col_norm;

                                        warn1=warning('off','MATLAB:rankDeficientMatrix');
                                        xall=A3\opts.rhs;
                                        warning(warn1)
                                        x=xall./col_norm';
                                        x(~isfinite(x))=0;
                                    else
                                        for col=cols:-1:1
                                            wDF=opts.weight(:,col).*DF;
                                            A3(upperrows,lowercols)=imag(wDF(:,lowercols));
                                            A3(lowerrows,lowercols)=real(wDF(:,lowercols));
                                            col_norm=max(abs(A3));
                                            col_norm(col_norm==0)=1;
                                            A3=A3./col_norm;
                                            warn1=warning('off','MATLAB:rankDeficientMatrix');
                                            xc=(A3\opts.rhs(:,col))./col_norm';
                                            warning(warn1)
                                            xc(~isfinite(xc))=0;
                                            x(:,col)=xc;
                                        end
                                    end


                                    k=1;
                                    while k<=np
                                        if imag(poles(k))==0
                                            c(k,:)=x(k,:);
                                            k=k+1;
                                        else
                                            c(k,:)=complex(x(k,:),x(k+1,:));
                                            c(k+1,:)=complex(x(k,:),-x(k+1,:));
                                            k=k+2;
                                        end
                                    end
                                    if opts.offset==1
                                        d=x(np+1,:);
                                    end


                                    resp=d.*ones(size(data));
                                    if np>0
                                        y=1./(s-poles.');
                                        resp=resp+y*c;
                                    end
                                    for col=cols:-1:1
                                        numer=norm(opts.weight(:,col).*(data(:,col)-resp(:,col)));
                                        if numer==0
                                            errdb(col)=-Inf;
                                        else
                                            errdb(col)=20*log10(numer/norm(opts.weight(:,col).*data(:,col)));
                                        end
                                    end


                                    function DF=residuematrix(poles,s,offset)
                                        np=numel(poles);
                                        DF=zeros(numel(s),np+offset);
                                        k=1;
                                        while k<=np
                                            if imag(poles(k))==0
                                                DF(:,k)=1./(s-poles(k));
                                                k=k+1;
                                            else
                                                common=1./((s-poles(k)).*(s-poles(k+1)));
                                                DF(:,k)=(2*s-(poles(k)+poles(k+1))).*common;
                                                DF(:,k+1)=(1j*(poles(k)-poles(k+1)))*common;
                                                k=k+2;
                                            end
                                        end
                                        if offset
                                            DF(:,np+1)=1;
                                        end
