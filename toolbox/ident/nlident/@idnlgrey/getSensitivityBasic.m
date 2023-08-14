function[jac,err,xjac]=getSensitivityBasic(nlsys,data,parinfo)



































    nin=nargin;
    if(nin<3)

        parinfo=obj2var(nlsys);
    end

    ComputeXJac=nargout>2;



    x=parinfo.Value;
    xMin=parinfo.Minimum;
    xMax=parinfo.Maximum;
    [x0,par]=var2obj(nlsys,x);


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
    [n,~,nu,ne]=size(data);
    ny=nlsys.Order.ny;



    np=numel(x);
    nx=nlsys.Order.nx;


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


    switch lower(nlsys.Algorithm.GradientOptions.DiffScheme(1))
    case{'a','c'}

        for j=1:np


            xjL=min(xMax(j),x(j)+dx(j));
            xjR=max(xMin(j),x(j)-dx(j));


            xL=x;
            xL(j)=xjL;
            xR=x;
            xR(j)=xjR;


            [x0L,parL]=var2obj(nlsys,xL);
            [x0R,parR]=var2obj(nlsys,xR);
            localEvalJac(x0L,x0R,parL,parR);
        end
    case 'f'

        [x0R,parR]=var2obj(nlsys,x);
        for j=1:np


            xjL=min(xMax(j),x(j)+dx(j));
            xjR=x(j);


            xL=x;
            xL(j)=xjL;


            [x0L,parL]=var2obj(nlsys,xL);
            localEvalJac(x0L,x0R,parL,parR);
        end
    case 'b'

        [x0L,parL]=var2obj(nlsys,x);
        for j=1:np


            xjR=max(xMin(j),x(j)-dx(j));
            xjL=x(j);


            xR=x;
            xR(j)=xjR;


            [x0R,parR]=var2obj(nlsys,xR);
            localEvalJac(x0L,x0R,parL,parR);
        end
    otherwise
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInvalidDiffScheme')
    end





    function localEvalJac(xl,xr,parl,parr)



        if isempty(xl)
            xl=zeros(0,ne);
        end
        if isempty(xr)
            xr=zeros(0,ne);
        end
        for k1=1:ne


            if(nu>0)
                option.InterSample=InterSample{k};
            end

            if(isequal(xl(:,k1),xr(:,k1))&&isequal(parl,parr))


                continue;
            end


            try
                [y,xx,errsim]=idutils_private(FileName,[xl(:,k1),xr(:,k1)],option,...
                [SamplingInstants{k1},u{k1}],cat(2,parl(:),parr(:)),FileArgument);
            catch
                y=zeros(n(k1),2*ny);
                errsim=true(1,2);

            end


            if(errsim(1)&&~errsim(2))


                parl=par;
                xl=x0;
                xjL=x(j);
            elseif(~errsim(1)&&errsim(2))


                parr=par;
                xr=x0;
                xjR=x(j);
            end

            if(any(errsim)&&~all(errsim))

                try
                    [y,xx,errsim]=idutils_private(FileName,[xl(:,k1),xr(:,k1)],option,...
                    [SamplingInstants{k1},u{k1}],cat(2,parl(:),parr(:)),FileArgument);
                catch
                    y=zeros(n(k1),2*ny);
                    errsim=true(1,2);

                end
            end


            if any(errsim)

                dF=0;dFx=0;
                err(k1,j)=true;
                ctrlMsgUtils.warning('Ident:idnlmodel:infeasibleJacobian',k)
            else
                dF=y(:,1:ny)-y(:,ny+1:end);
                if ComputeXJac
                    dFx=xx(:,1:nx)-xx(:,nx+1:end);
                end
            end


            dF=dF(:);
            dF(imag(dF)~=0)=0;
            jac{k1}(:,j)=dF./(xjL-xjR);

            if ComputeXJac
                dFx=dFx(:);
                dFx(imag(dFx)~=0)=0;
                xjac{k1}(:,j)=dFx./(xjL-xjR);
            end
        end
    end
end
