function p=jigglemesh_atx(p,e,t,p1,v1,p2,v2)



































    nargs=nargin;
    if rem(nargs+3,2)
        error(message('pdelib:jigglemesh:NoParamPairs'))
    end


    Opt='off';
    Iter=-1;

    for i=4:2:nargs
        Param=eval(['p',int2str((i-4)/2+1)]);
        Value=eval(['v',int2str((i-4)/2+1)]);
        if~ischar(Param)&&~(isstring(Param)&&isscalar(Param))
            error(message('pdelib:jigglemesh:ParamNotString'))
        elseif size(Param,1)~=1
            error(message('pdelib:jigglemesh:ParamEmptyOrNot1row'))
        end
        Param=lower(Param);
        if strcmp(Param,'opt')
            Opt=lower(Value);
            if~ischar(Opt)&&~(isstring(Opt)&&isscalar(Opt))
                error(message('pdelib:jigglemesh:OptNotString'))
            elseif~strcmp(Opt,'off')&&~strcmp(Opt,'minimum')&&~strcmp(Opt,'mean')
                error(message('pdelib:jigglemesh:OptInvalidString'))
            end
        elseif strcmp(Param,'iter')
            Iter=Value;
            if ischar(Iter)||(isstring(Iter)&&isscalar(Iter))
                error(message('pdelib:jigglemesh:IterString'))
            elseif~all(size(Iter)==[1,1])
                error(message('pdelib:jigglemesh:IterNotScalar'))
            elseif imag(Iter)
                error(message('pdelib:jigglemesh:IterComplex'))
            elseif Iter<-1
                error(message('pdelib:jigglemesh:IterNeg'))
            end
        else
            error(message('pdelib:jigglemesh:InvalidParam',Param))
        end
    end

    if Iter==-1&&strcmp(Opt,'off')
        Iter=1;
    elseif Iter==-1
        Iter=20;
    end


    ep=sort([e(1,:),e(2,:)]);
    i=ones(1,size(p,2));
    j=ep(find([1,sign(diff(ep))]));
    i(j)=zeros(size(j));
    i=find(i);

    np=size(p,2);
    nt=size(t,2);

    if~strcmp(Opt,'off')
        q=pdetriq_atx(p,t);
        if strcmp(Opt,'minimum')
            q=min(q);
        else
            q=mean(q);
        end
    end

    j=1;
    while j<=Iter
        X=sparse(t([1,2,3],:),t([2,3,1],:),p(1,t(1:3,:)),np,np);
        Y=sparse(t([1,2,3],:),t([2,3,1],:),p(2,t(1:3,:)),np,np);
        N=sparse(t([1,2,3],:),t([2,3,1],:),1,np,np);
        m=sum(N);
        X=sum(X)./m;
        Y=sum(Y)./m;
        p1=p;
        p(1,i)=X(i);
        p(2,i)=Y(i);
        if~strcmp(Opt,'off')
            q1=q;
            q=pdetriq_atx(p,t);
            if strcmp(Opt,'minimum')
                q=min(q);
            elseif strcmp(Opt,'mean')
                q=mean(q);
            end
            if q<q1
                p=p1;
                break,
            elseif q1+1e-4>q
                break
            end
        end
        j=j+1;
    end

