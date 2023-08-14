function jit=getXYZJitterImpl(hObj,~)



    if~hObj.JitterDirty_I
        jit=hObj.XYZJitter_I;
        return
    end

    n=numel(hObj.XDataCache);
    jit=zeros(n,3);
    jit_types={hObj.XJitter,hObj.YJitter,hObj.ZJitter};

    if isempty(hObj.XDataCache)&&isempty(hObj.YDataCache)&&isempty(hObj.ZDataCache)
        return
    end


    oldstate=rng;
    rng(4514);
    resetRng=onCleanup(@()rng(oldstate));


    dodensity=strcmp(jit_types,'density');
    if any(dodensity)
        if isequal(dodensity,[1,0,0])

            grp=hObj.XDataCache(:);
            data=hObj.YDataCache(:);
        elseif isequal(dodensity,[0,1,0])

            grp=hObj.YDataCache(:);
            data=hObj.XDataCache(:);
        elseif isequal(dodensity,[0,0,1])&&~isempty(hObj.ZDataCache)

            grp=hObj.ZDataCache(:);
            data=hObj.YDataCache(:);
        elseif isequal(dodensity,[1,1,0])&&~isempty(hObj.ZDataCache)

            grp=[hObj.XDataCache(:),hObj.YDataCache(:)];
            data=hObj.ZDataCache(:);
        elseif isequal(dodensity,[1,0,1])&&~isempty(hObj.ZDataCache)

            grp=[hObj.XDataCache(:),hObj.ZDataCache(:)];
            data=hObj.YDataCache(:);
        elseif isequal(dodensity,[0,1,1])&&~isempty(hObj.ZDataCache)

            grp=[hObj.YDataCache(:),hObj.ZDataCache(:)];
            data=hObj.XDataCache(:);
        else

            throwAsCaller(MException(message('MATLAB:scatter:InvalidJittertype')));
        end

        ksd=getgroupedksd(grp,data);
        ksd=ksd./max(ksd);
    end

    jit_width=[hObj.XJitterWidth,hObj.YJitterWidth,hObj.ZJitterWidth];
    for i=1:3
        if strcmp(jit_types{i},'rand')
            r=rand(n,1);



            minr=min(r);
            maxr=max(r);
            jit(:,i)=(jit_width(i)/2)*(r-minr)/(maxr-minr);
        elseif strcmp(jit_types{i},'randn')
            r=abs(randn(n,1));
            minr=min(r);
            maxr=max(r);
            jit(:,i)=(jit_width(i)/2)*(r-minr)/(maxr-minr);
        elseif strcmp(jit_types{i},'density')
            r=rand(n,1);
            minr=min(r);
            maxr=max(r);
            r=(jit_width(i)/2)*(r-minr)/(maxr-minr);
            jit(:,i)=ksd.*r;
        elseif strcmp(jit_types{i},'none')
            continue
        end



        flipind=randperm(size(jit,1));
        flipind=flipind(1:floor(numel(flipind)/2));
        jit(flipind',i)=-jit(flipind',i);
    end


    jit(~isfinite(jit))=0;


    hObj.JitterDirty_I=false;
    hObj.XYZJitter_I=jit;
end

function ksd=getgroupedksd(grp,data)

    ksd=nan(size(data));
    if size(grp,2)==1
        [ind,grpval]=findgroups(grp);
    elseif size(grp,2)==2
        [ind,grpval]=findgroups(grp(:,1),grp(:,2));
    end

    N=nan(numel(grpval),1);
    for i=1:numel(grpval)
        useind=ind==i&isfinite(data);

        thesedata=data(useind);
        if isscalar(thesedata)
            ksd(useind)=0;
        else
            ksd(useind)=computeksd(thesedata);
        end
        if~isempty(thesedata)
            N(i)=sum(useind);
        end
    end


    prop=N/max(N);
    kmax=max(ksd);
    for i=1:numel(grpval)
        ksd(ind==i)=prop(i)*ksd(ind==i)./kmax;
    end
    ksd=ksd(:);
end

function ky=computeksd(y)

    maxsamp=5000;
    n=numel(y);



    if n>maxsamp
        x=y(randperm(n,maxsamp));
    else
        x=y;
    end


    bw=std(x)*(4/3/numel(x))^(1/5);
    if bw==0
        ky=ones(size(y));
        return
    end


    ky=mean(exp(-.5*((x(:)-x(:)')/bw).^2)/sqrt(2*pi))/bw;


    if n>maxsamp
        [ux,ind]=unique(x);
        ky=interp1(ux,ky(ind),y);
    end

end