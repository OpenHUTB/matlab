function[x,f]=tr_solver(x,FUN,xMin,xMax,OPTS)


















    criticTol=1e-5;
    radiusTol=1e-6;
    radius=1e9;


    np=length(x);
    if isscalar(xMin)
        xMin=xMin*ones(np,1);
    end
    if isscalar(xMax)
        xMax=xMax*ones(np,1);
    end


    [f,df]=FUN(x);
    if f<=OPTS.Target
        return
    end
    cc=localTestCritical(x,df,xMin,xMax);


    fWindow=10;
    fHist=Inf(fWindow,1);
    fPtr=1;


    iter=0;
    fVar=Inf;
    while iter<OPTS.MaxIter&&cc>criticTol
        iter=iter+1;


        dmin=max(xMin-x,-radius);
        dmax=min(xMax-x,radius);
        d=zeros(np,1);
        d(df>0)=dmin(df>0);
        d(df<0)=dmax(df<0);


        xNew=x+d;
        [fNew,dfNew]=FUN(xNew);
        actual=f-fNew;
        pred=-df'*d;


        [radius,eta1]=updateRadius(actual,pred,radius,d);


        if actual>=eta1*pred
            x=xNew;f=fNew;df=dfNew;
            cc=localTestCritical(x,df,xMin,xMax);

            fPtr=mod(fPtr,fWindow)+1;
            fVar=fHist(fPtr)-f;
            fHist(fPtr)=f;
        end


        if radius<radiusTol*(1+norm(x,inf))||cc<=criticTol||...
            f<=OPTS.Target||fVar<OPTS.RELTOL*abs(f)
            break
        end
    end



    function[cc,d]=localTestCritical(x,df,xMin,xMax)


        if isempty(df)

            cc=0;d=[];
        else

            dmin=max(xMin-x,-1);
            dmax=min(xMax-x,1);
            d=zeros(size(x));
            d(df>0)=dmin(df>0);
            d(df<0)=dmax(df<0);
            cc=abs(df'*d);
        end


        function[radiusNew,eta1]=updateRadius(ActDecr,PredDecr,radius,d)






            radMax=1e9;
            eta1=0.05;
            eta2=0.9;
            al1=2.5;
            al2=0.25;

            if ActDecr<=eta1*PredDecr

                radiusNew=al2*norm(d,inf);
            elseif ActDecr>=eta2*PredDecr&&norm(d,inf)>=0.98*radius

                radiusNew=min(al1*radius,radMax);
            else

                radiusNew=radius;
            end
