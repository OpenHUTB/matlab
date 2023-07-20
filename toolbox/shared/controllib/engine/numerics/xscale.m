function[a,b,c,e,sr,sl,Info]=xscale(a,b,c,d,e,Ts,varargin)




























    ne=size(e,1);
    Ts=abs(Ts);


    Options=struct('Warn',true,'Focus',[]);
    for ct=1:2:length(varargin)
        Options.(varargin{ct})=varargin{ct+1};
    end


    [w,wcf]=xscale_BaselineGrid(Options.Focus,Ts);


    [br,cr,dr]=ltipack.util.pruneIO(b,c,d);





    [a,br,cr,e,sr0,sl0]=xscaleLocal(a,br,cr,dr,e,Ts,wcf);
    b=sl0.*b;
    c=c.*sr0';


    [w,g,relacc,h,beta,gamma]=xscale_ComputeResponse(a,br,cr,dr,e,Ts,w,wcf);
    nf=numel(w);


    if any(g>0&relacc<1)

        log2w=log2(w);log2g=log2(g);
        slopes=diff(log2g)./diff(log2w);
        ds=abs(diff(slopes));
        minLRS=min(abs(slopes(1:nf-2,:)),abs(slopes(2:nf-1,:)));
        iBP=1+find(ds>0.3*max(1,minLRS));



        iOPT=xscale_OptimGrid(w,g,relacc,iBP,slopes,wcf,Ts);
    else
        iBP=[];iOPT=(1:nf).';
    end













    SYSDATA=struct('a',a,'b',br,'c',cr,'e',e,'Ts',Ts,...
    'w',w(iOPT),'h',abs(h(:,:,iOPT)),...
    'beta',abs(beta(:,:,iOPT)),'gamma',abs(gamma(:,:,iOPT)),...
    'Weight',1);
    [sl,sr]=xscale_Optimize(SYSDATA,true);


    a=a.*(sl*sr');
    if ne>0
        e=e.*(sl*sr');

        nae=norm(a,1)+norm(e,1);
        if nae>0
            s=pow2(round(log2(nae)/2));s2=s^2;
            sl=sl/s;sr=sr/s;a=a/s2;e=e/s2;
        end
    end
    b=sl.*b;
    c=c.*sr';






    scaledacc=zeros(nf,1);
    if Ts==0
        s=w;
    else
        s=ones(nf,1);
    end
    br=sl.*br;
    cr=cr.*sr';
    for ct=1:nf
        scaledacc(ct)=eps*ltipack.util.frsensLocal(a,br,cr,dr,e,...
        s(ct),h(:,:,ct),sr.\beta(:,:,ct),gamma(:,:,ct)./sl');
    end


    if any(g>0&g<Inf)&&all(relacc>1)

        WarnID='Control:analysis:InaccurateResponse';
    elseif hasAccuracyTradeoff(w,g,scaledacc,iBP,iOPT)


        WarnID='Control:transformation:StateSpaceScaling';
    else
        WarnID='';
    end


    bnorm=norm(b,1);
    cnorm=norm(c,1);
    if bnorm>0&&cnorm>0
        s=pow2(round(log2(bnorm/cnorm)/2));
        b=b/s;sl=sl/s;
        c=c*s;sr=sr*s;
    end


    sr=sr.*sr0;
    sl=sl.*sl0;


    if nargout>6


        Info=struct('Freq',w,'Gain',g,'RelAcc',relacc,'ScaledAcc',scaledacc,...
        'iBP',iBP,'iOPT',iOPT,'WarnID',WarnID);
    end


    if Options.Warn&&~isempty(WarnID)
        warning(message(WarnID))
    end



    function boo=hasAccuracyTradeoff(w,g,relacc,iBP,iOPT)



        boo=false;
        if~isempty(iBP)
            iOPT=iOPT(ismember(iOPT,iBP));
            iBAD=iBP(relacc(iBP)>1&(iBP<iOPT(1)|iBP>iOPT(end)));
            if~isempty(iBAD)
                iL=iBAD(iBAD<iOPT(1));
                LGAP=(abs(log10(w(iL,:)/w(iOPT(1))))+abs(log10(g(iL,:)/g(iOPT(1)))))/2;
                iR=iBAD(iBAD>iOPT(end));
                RGAP=(abs(log10(w(iR,:)/w(iOPT(end))))+abs(log10(g(iR,:)/g(iOPT(end)))))/2;
                boo=min([LGAP;RGAP])<5;
            end
        end