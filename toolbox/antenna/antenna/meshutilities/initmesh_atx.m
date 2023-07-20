function[p,e,t]=initmesh_atx(g,varargin)






























































    p=inputParser;
    addParamValue(p,'Hmax',0,@checkHmax);
    addParamValue(p,'Hgrad',1.3,@checkHgrad);
    addParamValue(p,'Box','off',@checkBox);
    addParamValue(p,'Init','off',@checkInit);
    addParamValue(p,'Jiggle','mean',@checkJiggle);
    addParamValue(p,'JiggleIter',-1,@checkJiggleIter);
    addParamValue(p,'MesherVersion','preR2013a',@checkAlgoLabels);
    addParamValue(p,'MaxRefineSteps',inf);
    addParamValue(p,'ConstrainedDelaunayRefinement',false);

    parse(p,varargin{:});
    Hmax=p.Results.Hmax;
    Hgrad=p.Results.Hgrad;
    Box=lower(p.Results.Box);
    Init=lower(p.Results.Init);
    Jiggle=lower(p.Results.Jiggle);
    JiggleIter=p.Results.JiggleIter;
    useDt=strcmpi(p.Results.MesherVersion,'r2013a');
    maxRefineSteps=p.Results.MaxRefineSteps;
    constrainedDelaunayRefine=p.Results.ConstrainedDelaunayRefinement;


    if isa(g,'pde.AnalyticGeometry')
        g=g.geom;
    end




    [p,e,Hmin,factor]=pdemgeom_atx(g);
    chkTopology(p,e);


    delTri=pdeDelTri_atx(p');
    excludeInner=false;
    cm=getEdgeConstraints(e,excludeInner);
    warnState(1)=warning('off','MATLAB:DelaunayTri:ConsSplitPtWarnId');
    warnState(2)=warning('off','MATLAB:DelaunayTri:ConsConsSplitWarnId');
    warnState(3)=warning('off','MATLAB:DelaunayTri:DupConsWarnId');
    warnState(4)=warning('off','MATLAB:DelaunayTri:LoopConsWarnId');
    delTri.setConstraints(cm);
    warning(warnState);
    numCmOld=size(cm,1);
    numCmNew=size(delTri.getConstraints(),1);

    if(numCmOld~=numCmNew)
        checkSelfIntersections_atx(g)
    end


    x=p(1,:);y=p(2,:);
    xmin=min(x);xmax=max(x);
    ymin=min(y);ymax=max(y);
    xdiff=xmax-xmin;ydiff=ymax-ymin;
    x1=xmin-xdiff;x2=xmax+xdiff;
    y1=ymin-ydiff;y2=ymax+ydiff;
    p=[x1,x2,x2,x1;y1,y1,y2,y2];
    e(1:2,:)=e(1:2,:)+4;
    t=[1,1;2,3;3,4;0,0];

    if~Hmax
        Hmax=0.1*max(xdiff,ydiff);
    end


    if Hmax~=inf
        ntg=floor(2*(xmax-xmin)*(ymax-ymin)/Hmax^2);
    else
        ntg=0;
    end
    if(ntg>20000)
        fprintf(['\n',message('pdelib:initmesh:LargeMesh',ntg).getString(),'\n']);
    end


    small=10000*eps;
    scale=max(xmax-xmin,ymax-ymin);
    tol=small*scale;
    tol2=small*scale^2;


    if(useDt)

        delTri=pdeDelTri_atx(p');
        delTri.pdevoron(x,y);
        p=delTri.getPoints();
        t=delTri.getTriangles();
        c=delTri.getCircumcenters();
    else
        [p,t,c]=pdevoron_atx(p,t,[],Hmax,x,y,tol,Hmax,Hgrad);
    end


    [p,e,t,c]=pderespe_atx(g,p,e,t,c,Hmax,tol,tol2,Hmax,Hgrad);


    if Hmax==inf&&strcmp(Box,'on')
        return
    end


    [k,t]=pdeintrn_atx(p,e,t);
    it=t(:,k);
    ic=c(:,k);


    if Hmax==inf

        [p,e,t]=pdermpnt_atx(p,e,it);
        return
    end


    h=pdehloc_atx(p,e,it,Hmax,Hmin,Hgrad);


    [x,y,e,h]=pdedistr_atx(g,p,e,it,Hmax,Hgrad,tol,h,factor);


    if(~useDt)
        try
            [p,t,c,h]=pdevoron_atx(p,t,[],h,x,y,tol,Hmax,Hgrad);
        catch err
            pdevoronFailureMessage(err);
        end

        [p,e,t,c,h]=pderespe_atx(g,p,e,t,c,h,tol,tol2,Hmax,Hgrad);
    else
        delTri=pdeDelTri_atx(p');
        [p,t,c]=delTri.pdevoron(x,y);
        excludeInner=false;
        cm=getEdgeConstraints(e,excludeInner);
        delTri.setConstraints(cm);
        p=delTri.getPoints();
        t=delTri.getTriangles();
    end


    [k,t]=pdeRegionCalc(e,t);

    it=t(:,k);
    ic=c(:,k);


    if strcmp(Init,'on')&&strcmp(Box,'on')
        return
    end


    if strcmp(Init,'on')

        [p,e,t]=pdermpnt_atx(p,e,it);
        return
    end

    if(useDt)
        delTri=pdeDelTri_atx(p');
        excludeInner=~constrainedDelaunayRefine;
        cm=getEdgeConstraints(e,excludeInner);
        delTri.setConstraints(cm);
        p=delTri.getPoints();
        t=delTri.getTriangles();
        c=delTri.getCircumcenters();
        hEdge=calcEdgeH(p,e);
        hInterpol=delTri.buildSizeInterp(hEdge,Hmax,Hgrad);
        k=delTri.getInOutStatus();
        it=t(:,k);
        ic=c(:,k);
    end

    t(:,k)=[];
    c(:,k)=[];
    ne=size(t,2);
    t=[t,it];
    c=[c,ic];

    numRefine=0;
    while true

        it1=it(1,:);
        it2=it(2,:);
        it3=it(3,:);


        l1=(p(1,it2)-p(1,it1)).^2+(p(2,it2)-p(2,it1)).^2;
        l2=(p(1,it3)-p(1,it2)).^2+(p(2,it3)-p(2,it2)).^2;
        l3=(p(1,it1)-p(1,it3)).^2+(p(2,it1)-p(2,it3)).^2;


        maxTriLen=sqrt(max(l1,max(l2,l3)));


        a=pdehloc_atx(p,e,it);


        if(useDt)
            if size(h,2)>1
                hit1=hInterpol(p(:,it1)')';
                hit2=hInterpol(p(:,it2)')';
                hit3=hInterpol(p(:,it3)')';
                hh=prod([hit1;hit2;hit3]).^(1/3);
            else
                hh=h;
            end
            enclosingTri=delTri.getEnclosingTriangles(ic(1:2,:)');
            allTri=delTri.getTriangles();
            net=pdeFilterInsertPts(p,e,allTri,ic,enclosingTri);
            k=find(maxTriLen>=1.2*hh&min(abs(a-pi/2))>pi/8&net);
        else
            if size(h,2)>1
                hh=prod([h(it1);h(it2);h(it3)]).^(1/3);
                k=find(maxTriLen>=1.2*hh&min(abs(a-pi/2))>pi/8);
            else
                k=find(maxTriLen>=1.2*h&min(abs(a-pi/2))>pi/8);
            end
        end


        if isempty(k),break,end


        it=it(:,k);
        ic=ic(:,k);
        maxTriLen=maxTriLen(k);



        [maxTriLen,si]=sort(maxTriLen);

        sj=filterTrianglesByCircumcenter(ic,si,tol);

        x=ic(1,sj);
        y=ic(2,sj);


        i=find(x>x2|x<x1|y>y2|y<y1);
        x(i)=[];
        y(i)=[];
        if isempty(x),break,end


        if(~useDt)
            try
                [pNew,t1,c1,h]=pdevoron_atx(p,t,c,h,x,y,tol,Hmax,Hgrad);
            catch err
                pdevoronFailureMessage(err);
            end
            npNew=size(pNew,2)-size(p,2);
            p=pNew;



            if any(any(t(:,1:ne)~=t1(:,1:ne)))

                [p,e,t,c,h]=pderespe_atx(g,p,e,t1,c1,h,tol,tol2,Hmax,Hgrad);


                k=pdeintrn_atx(p,e,t);

                it=t(:,k);
                ic=c(:,k);
                t(:,k)=[];
                c(:,k)=[];
                ne=size(t,2);
                t=[t,it];
                c=[c,ic];
            else
                t=t1;
                c=c1;
                it=t(:,ne+1:size(t,2));
                ic=c(:,ne+1:size(t,2));
            end
        else
            [p,t1,c1,npNew]=delTri.pdevoron(x,y);
            if(constrainedDelaunayRefine)
                k=pdeRegionCalc(e,t);
            else
                k=delTri.getInOutStatus();
            end
            it=t1(:,k);
            ic=c1(:,k);
            t=t1;
            c=c1;
        end

        numRefine=numRefine+1;

        if(numRefine>maxRefineSteps||npNew==0)
            break;
        end

    end

    if(~useDt)

        [p,e,t,c,h]=pderespe_atx(g,p,e,t,c,h,tol,tol2,Hmax,Hgrad);
    else

        excludeInner=false;
        cm=getEdgeConstraints(e,excludeInner);
        delTri.setConstraints(cm);
        p=delTri.getPoints();
        t=delTri.getTriangles();
    end


    [k,t]=pdeRegionCalc(e,t);


    if strcmp(Box,'on')
        return
    end


    t=t(:,k);
    [p,e,t]=pdermpnt_atx(p,e,t);

    if~strcmp(Jiggle,'off')
        if strcmp(Jiggle,'on')
            Opt='off';
        else
            Opt=Jiggle;
        end
        p=jigglemesh_atx(p,e,t,'Iter',JiggleIter,'Opt',Opt);
    end

end

function c=getEdgeConstraints(e,excludeInner)
    if(excludeInner)
        eOuter=e(6,:)==0|e(7,:)==0;
        c=[e(1,eOuter)',e(2,eOuter)'];
    else
        c=[e(1,:)',e(2,:)'];
    end

end

function h=calcEdgeH(p,e)
    v1=e(1,:);
    v2=e(2,:);
    x1=p(:,v1);
    x2=p(:,v2);
    dx=x2-x1;
    hEdge=sqrt(dx(1,:).*dx(1,:)+dx(2,:).*dx(2,:));
    h=zeros(1,size(p,2));
    h(v1)=hEdge;
    h(v2)=hEdge;
end

function chkTopology(p,e)
    np=size(p,2);
    ne=size(e,2);
    T=sparse(e(1,:),e(2,:),ones(ne,1),np,np);
    T=T+T';
    singleEdgeNodes=find(sum(T)==1);
    if(~isempty(singleEdgeNodes))
        xyLocs=sprintf('\n');
        for j=1:size(singleEdgeNodes,2)
            i=singleEdgeNodes(j);
            xyLocs=[xyLocs,sprintf('(%g,%g)\n',p(1,i),p(2,i))];
        end
        error(message('pdelib:initmesh:InvalidGeometry',xyLocs))
    end
end

function pdevoronFailureMessage(err)
    if(strcmp(err.identifier,'pdelib:pdevoron:GeomError'))
        warnState=warning('backtrace','off');
        warning(message('pdelib:initmesh:TryNewMesher'));
        warning(warnState);
    end
    rethrow(err);
end


function ok=checkHmax(Hmax)
    if ischar(Hmax)||(isstring(Hmax)&&isscalar(Hmax))
        error(message('pdelib:initmesh:HmaxString'))
    elseif~all(size(Hmax)==[1,1])
        error(message('pdelib:initmesh:HmaxNotScalar'))
    elseif imag(Hmax)
        error(message('pdelib:initmesh:HmaxComplex'))
    elseif Hmax<0
        error(message('pdelib:initmesh:HmaxNeg'))
    end
    ok=true;
end
function ok=checkHgrad(Hgrad)
    if ischar(Hgrad)||(isstring(Hgrad)&&isscalar(Hgrad))
        error(message('pdelib:initmesh:HgradString'))
    elseif~all(size(Hgrad)==[1,1])
        error(message('pdelib:initmesh:HgradNotScalar'))
    elseif imag(Hgrad)
        error(message('pdelib:initmesh:HgradComplex'))
    elseif Hgrad<=1||Hgrad>=2
        error(message('pdelib:initmesh:HgradOutOfRange'))
    end
    ok=true;
end
function ok=checkBox(Box)
    if~ischar(Box)&&~(isstring(Box)&&isscalar(Box))
        error(message('pdelib:initmesh:BoxNotString'))
    elseif~strcmp(Box,'on')&&~strcmp(Box,'off')
        error(message('pdelib:initmesh:BoxInvalidString'))
    end
    ok=true;
end
function ok=checkInit(Init)
    if~ischar(Init)&&~(isstring(Init)&&isscalar(Init))
        error(message('pdelib:initmesh:InitNotString'))
    elseif~strcmp(Init,'on')&&~strcmp(Init,'off')
        error(message('pdelib:initmesh:InitInvalidString'))
    end
    ok=true;
end
function ok=checkJiggle(Jiggle)
    if~ischar(Jiggle)&&~(isstring(Jiggle)&&isscalar(Jiggle))
        error(message('pdelib:initmesh:JiggleNotString'))
    elseif~strcmp(Jiggle,'on')&&~strcmp(Jiggle,'off')&&...
        ~strcmp(Jiggle,'minimum')&&~strcmp(Jiggle,'mean')
        error(message('pdelib:initmesh:JiggleInvalidString'))
    end
    ok=true;
end
function ok=checkJiggleIter(JiggleIter)
    if ischar(JiggleIter)||(isstring(JiggleIter)&&isscalar(JiggleIter))
        error(message('pdelib:initmesh:JiggleiterString'))
    elseif~all(size(JiggleIter)==[1,1])
        error(message('pdelib:initmesh:JiggleiterNotScalar'))
    elseif imag(JiggleIter)
        error(message('pdelib:initmesh:JiggleiterComplex'))
    elseif JiggleIter<0
        error(message('pdelib:initmesh:JiggleiterNeg'))
    end
    ok=true;
end
function ok=checkAlgoLabels(mesherVer)
    if(~ischar(mesherVer))&&~(isstring(mesherVer)&&isscalar(mesherVer))
        error(message('pdelib:initmesh:MesherVersionNotString'))
    end
    if~(strcmp(mesherVer,'preR2013a')||strcmp(mesherVer,'R2013a'))
        error(message('pdelib:initmesh:MesherVersionInvalidString'))
    end
    ok=true;
end
