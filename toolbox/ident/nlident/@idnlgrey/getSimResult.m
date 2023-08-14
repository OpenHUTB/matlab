function[y,err,xfinal,x]=getSimResult(nlsys,data,x0,par)


























    [n,ny,nu,ne]=size(data);


    nin=nargin;
    if((nin<3)||isempty(x0))
        X=nlsys.InitialStates;
        x0=cat(1,X.Value);
    end
    if((ne>1)&&(size(x0,2)==1))
        x0=repmat(x0,1,ne);
    end


    if((nin<4)||isempty(par))
        P=nlsys.Parameters_;
        par={P.Value};
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


    y=cell(1,ne);
    err=false(1,ne);
    x=cell(1,ne);


    if isempty(x0)
        x0=zeros(0,ne);
    end

    xfinal=nan(size(x0));


    for k=1:ne


        if(nu>0)
            option.InterSample=InterSample{k};
        end
        try
            [y{k},x{k},err(k)]=idutils_private(FileName,x0(:,k),option,[SamplingInstants{k},u{k}],par(:),FileArgument);
            xfinal(:,k)=x{k}(end,:)';
        catch
            y{k}=nan(n(k),ny);
            x{k}=nan(n(k),nlsys.Order.nx);
            err(k)=true;

        end
        if err(k)
            if ne>1
                ctrlMsgUtils.warning('Ident:idnlmodel:infeasibleSimulationMultiExp',k)
            else
                ctrlMsgUtils.warning('Ident:idnlmodel:infeasibleSimulation')
            end
        end
    end
