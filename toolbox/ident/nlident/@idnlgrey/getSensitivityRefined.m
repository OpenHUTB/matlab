function[jac,err,xjac]=getSensitivityRefined(nlsys,data,parinfo)






































    nin=nargin;
    if(nin<3)

        parinfo=obj2var(nlsys);
    end

    ComputeXJac=nargout>2;



    x=parinfo.Value;
    xMin=parinfo.Minimum;
    xMax=parinfo.Maximum;


    npar=size(nlsys,'np')-size(nlsys,'npf');
    [n,~,nu,ne]=size(data);
    ny=nlsys.Order.ny;


    IniStates=nlsys.InitialStates_;
    nXfree=sum(~cat(1,IniStates.Fixed),1);


    if isempty(nXfree)
        nXfree=zeros(1,ne);
    end


    FileName=nlsys.FileName_;
    FileArgument=nlsys.FileArgument_;
    if isempty(FileArgument)
        FileArgument={};
    end
    option=nlsys.Algorithm.SimulationOptions;
    if strcmpi(option.Solver,'Auto')
        if((pvget(nlsys,'Ts')>0)||(nlsys.Order.nx==0))
            option.Solver='FixedStepDiscrete';
        else
            option.Solver='ode45';
        end
    end



    option.InterSample='zoh';
    InterSample=pvget(data,'InterSample');
    SamplingInstants=pvget(data,'SamplingInstants');
    u=pvget(data,'InputData');



    nx=size(nlsys,'nx');
    np=numel(x);


    dx=min(max(1000*eps^(1/3)*abs(x),nlsys.Algorithm.GradientOptions.DiffMinChange),...
    nlsys.Algorithm.GradientOptions.DiffMaxChange);


    jac=cell(1,ne);xjac=jac;
    for k=1:ne
        jac{k}=zeros(n(k)*ny,np);
        if ComputeXJac
            xjac{k}=zeros(n(k)*nx,np);
        end
    end
    err=false(ne,np);


    delp=zeros(1,np);
    switch lower(nlsys.Algorithm.GradientOptions.DiffScheme(1))
    case{'a','c'}

        bigX=zeros(nx,2*ne*np);
        bigPar=cell(length(nlsys.Parameters),2*np);



        for j=1:np

            xjL=min(xMax(j),x(j)+dx(j));
            xjR=max(xMin(j),x(j)-dx(j));


            xL=x;
            xL(j)=xjL;
            xR=x;
            xR(j)=xjR;
            delp(j)=xjL-xjR;
            if(delp(j)==0)
                delp(j)=eps;
            end


            [x0L,parL]=var2obj(nlsys,xL);
            [x0R,parR]=var2obj(nlsys,xR);
            if(nx==0)

                x0L=zeros(0,ne);
                x0R=zeros(0,ne);
            end
            bigX(:,2*(j-1)*ne+1:(2*j-1)*ne)=x0L;
            bigX(:,(2*j-1)*ne+1:2*ne*j)=x0R;
            bigPar(:,2*j-1)=parL;
            bigPar(:,2*j)=parR;
        end


        offset=npar;
        for k=1:ne


            if(nu>0)
                option.InterSample=InterSample{k};
            end
            kX0=bigX(:,k:ne:end);


            usefulpart=kX0(:,2*offset+1:2*(offset+nXfree(k)));


            kX0(:,2*npar+1:end)=[];
            kX0=[kX0,usefulpart];
            jj=npar+nXfree(k);



            [dF,dFx]=localEvalCentralDiff(kX0,bigPar(:,1:2*jj),ComputeXJac);


            jac{k}(:,1:npar)=dF(:,1:npar)./repmat(delp(1:npar),n(k)*ny,1);
            jac{k}(:,offset+1:offset+nXfree(k))=dF(:,npar+1:end)./repmat(delp(offset+1:offset+nXfree(k)),n(k)*ny,1);

            if ComputeXJac
                xjac{k}(:,1:npar)=dFx(:,1:npar)./repmat(delp(1:npar),n(k)*nx,1);
                xjac{k}(:,offset+1:offset+nXfree(k))=dFx(:,npar+1:end)./repmat(delp(offset+1:offset+nXfree(k)),n(k)*nx,1);
            end

            offset=offset+nXfree(k);
        end
    case{'f','b'}

        bigX=zeros(nx,ne*(np+1));
        bigPar=cell(length(nlsys.Parameters),np+1);
        if strcmpi(nlsys.Algorithm.GradientOptions.DiffScheme(1),'f')
            fwd=true;
        else
            fwd=false;
        end


        [x0R,parR]=var2obj(nlsys,x);
        if(nx==0)

            x0R=zeros(0,ne);
        end
        bigX(:,1:ne)=x0R;
        bigPar(:,1)=parR;



        for j=1:np

            if fwd
                xjL=min(xMax(j),x(j)+dx(j));
            else
                xjL=max(xMin(j),x(j)-dx(j));
            end
            xjR=x(j);


            xL=x;
            xL(j)=xjL;
            delp(j)=xjL-xjR;
            if(delp(j)==0)
                delp(j)=eps;
            end


            [x0L,parL]=var2obj(nlsys,xL);
            if(nx==0)

                x0L=zeros(0,ne);
            end
            bigX(:,ne*j+1:ne*(j+1))=x0L;
            bigPar(:,j+1)=parL;
        end


        offset=npar;
        for k=1:ne


            if(nu>0)
                option.InterSample=InterSample{k};
            end
            kX0=bigX(:,k:ne:end);


            usefulpart=kX0(:,offset+2:offset+nXfree(k)+1);


            kX0(:,npar+2:end)=[];
            kX0=[kX0,usefulpart];
            jj=npar+nXfree(k);



            [dF,dFx]=localEvalUnidirDiff(kX0,bigPar(:,1:jj+1),ComputeXJac);


            jac{k}(:,1:npar)=dF(:,1:npar)./repmat(delp(1:npar),n(k)*ny,1);
            jac{k}(:,offset+1:offset+nXfree(k))=dF(:,npar+1:end)./repmat(delp(offset+1:offset+nXfree(k)),n(k)*ny,1);

            if ComputeXJac
                xjac{k}(:,1:npar)=dFx(:,1:npar)./repmat(delp(1:npar),n(k)*nx,1);
                xjac{k}(:,offset+1:offset+nXfree(k))=dFx(:,npar+1:end)./repmat(delp(offset+1:offset+nXfree(k)),n(k)*nx,1);
            end

            offset=offset+nXfree(k);
        end
    otherwise
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInvalidDiffScheme')
    end





    function[dF_,dFx_]=localEvalCentralDiff(x_,p_,ComputeXJac)

        dFx_=[];
        errsim0=false(1,jj);
        try
            [y,xx,errsim]=idutils_private(FileName,x_,option,[SamplingInstants{k},u{k}],p_,FileArgument);
        catch
            y=zeros(n(k),jj*ny*2);
            errsim=true(2*jj,1);
            errsim0=true(1,jj);

        end


        dF_=zeros(n(k)*ny,jj);
        if ComputeXJac
            dFx_=zeros(n(k)*nx,jj);
        end
        for kk=1:jj
            if~(errsim(2*kk-1)||errsim(2*kk))
                dfl=y(:,2*ny*(kk-1)+1:ny*(2*kk-1))-y(:,ny*(2*kk-1)+1:2*ny*kk);
                dfl=dfl(:);
                dfl(imag(dfl)~=0)=0;
                dF_(:,kk)=dfl;

                if ComputeXJac
                    dfl=xx(:,2*nx*(kk-1)+1:nx*(2*kk-1))-xx(:,nx*(2*kk-1)+1:2*nx*kk);
                    dfl=dfl(:);
                    dfl(imag(dfl)~=0)=0;
                    dFx_(:,kk)=dfl;
                end
            else
                errsim0(kk)=true;
            end
        end
        if any(errsim0)
            if ne>1
                ctrlMsgUtils.warning('Ident:idnlmodel:infeasibleJacobian1MultiExp',k)
            else
                ctrlMsgUtils.warning('Ident:idnlmodel:infeasibleJacobian1')
            end
        end


        err(k,1:npar)=errsim0(1:npar);
        err(k,npar+1:npar+nXfree(k))=errsim0(npar+1:end);
    end


    function[dF_,dFx_]=localEvalUnidirDiff(x_,p_,ComputeXJac)

        dFx_=[];
        try
            [y,xx,errsim]=idutils_private(FileName,x_,option,[SamplingInstants{k},u{k}],p_,FileArgument);
        catch
            y=zeros(n(k),(jj+1)*ny);
            errsim=true(jj+1,1);

        end
        if errsim(1)
            ctrlMsgUtils.warning('Ident:idnlmodel:infeasibleJacobian2')
            errsim=true(jj+1,1);
        end


        dFl_=y(:,ny+1:end)-repmat(y(:,1:ny),1,jj);
        dFl_(:,err(2:end))=0;
        dFl_(imag(dFl_)~=0)=0;
        dF_=zeros(n(k)*ny,jj);
        for kk=1:jj
            dfl=dFl_(:,ny*(kk-1)+1:ny*kk);
            dfl=dfl(:);
            dF_(:,kk)=dfl;
        end

        if ComputeXJac
            dFl_=xx(:,nx+1:end)-repmat(xx(:,1:nx),1,jj);
            dFl_(:,err(2:end))=0;
            dFl_(imag(dFl_)~=0)=0;
            dFx_=zeros(n(k)*nx,jj);
            for kk=1:jj
                dfl=dFl_(:,nx*(kk-1)+1:nx*kk);
                dfl=dfl(:);
                dFx_(:,kk)=dfl;
            end
        end


        err(k,1:npar)=errsim(2:npar+1);
        err(k,npar+1:npar+nXfree(k))=errsim(npar+2:end);
    end
end
