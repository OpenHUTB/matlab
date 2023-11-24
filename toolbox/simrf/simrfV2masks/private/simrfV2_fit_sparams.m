function cacheData=simrfV2_fit_sparams(auxData,cacheData,block)

    freq=auxData.Spars.Frequencies;
    sparam=auxData.Spars.Parameters;
    nport=size(sparam,1);

    if size(sparam,3)==1
        cacheData=process_single_sparam(auxData,cacheData);
        return
    end

    tol=cacheData.FitTol;
    maxpoles=cacheData.MaxPoles;
    tendstozero=false;
    worst_fit_err=-Inf;
    w1=warning('off','simrf:simrfV2errors:ErrorToleranceNotMet');

    switch cacheData.FitOpt
    case 1

        Poles=cell(nport*nport,1);
        Residues=Poles;
        DF=Poles;
        for ii=1:nport

            [model,current_fit_err]=rational(freq,...
            sparam(:,ii,:),tol,'TendsToZero',tendstozero,...
            'MaxPoles',maxpoles,'Qlimit',inf);
            check_fiterror(current_fit_err,cacheData.FitTol,...
            sprintf('column %d of the S-parameters matrix',ii),...
            block)
            Poles((ii-1)*nport+1:ii*nport)={model.Poles};
            resSqueeze=squeeze(shiftdim(model.Residues,2));
            Residues((ii-1)*nport+1:ii*nport)=arrayfun(...
            @(i)resSqueeze(:,i),1:nport,'UniformOutput',false);
            DF((ii-1)*nport+1:ii*nport)=arrayfun(...
            @(i)model.DirectTerm(i),1:nport,'UniformOutput',false);
            worst_fit_err=max(worst_fit_err,current_fit_err);
        end

    case 2

        [model,current_fit_err]=rational(freq,sparam,tol,...
        'TendsToZero',tendstozero,'MaxPoles',maxpoles,'Qlimit',inf);
        check_fiterror(current_fit_err,cacheData.FitTol,...
        'the S-parameters matrix',block);
        Poles=cell(model.NumPorts^2,1);
        Residues=Poles;
        DF=Poles;
        Poles(1:nport^2)={model.Poles};
        for ii=1:model.NumPorts^2
            Residues(ii)={reshape(model.Residues(...
            ii:model.NumPorts^2:numel(model.Residues)),[],1)};
            DF(ii)={model.DirectTerm(ii)};
        end
        worst_fit_err=max(worst_fit_err,current_fit_err);

    case 3

        Poles=cell(nport,nport);
        Residues=Poles;
        DF=Poles;
        for ii=1:nport
            for kk=1:nport
                [model,current_fit_err]=rational(freq,...
                sparam(ii,kk,:),tol,'TendsToZero',tendstozero,...
                'MaxPoles',maxpoles,'Qlimit',inf);
                check_fiterror(current_fit_err,cacheData.FitTol,...
                sprintf('S(%d,%d)',ii,kk),block);
                Poles{ii,kk}=model.Poles;
                Residues{ii,kk}=squeeze(model.Residues);
                DF{ii,kk}=model.DirectTerm;
                worst_fit_err=max(worst_fit_err,current_fit_err);
            end
        end
        Poles=Poles(:);
        Residues=Residues(:);
        DF=DF(:);
    end
    warning(w1)

    if iscell(Poles{1})
        Poles=Poles{:};
        Residues=Residues{:};
        DF=DF{:};
    end

    cacheData.FitErrorAchieved=worst_fit_err;
    cacheData.RationalModel.A=Poles;
    cacheData.RationalModel.C=Residues;
    cacheData.RationalModel.D=DF;

    x=cellfun(@horzcat,Poles,Residues,'UniformOutput',false);
    y=cellfun(@process_poles_residues,x,'UniformOutput',false);

    idxPolesNotEmpty=~cellfun(@isempty,Poles);

    [Aname_cell,Cname_cell,Dname_cell]=...
    get_rational_param_names(sqrt(numel(Residues)));
    tempstr=cellfun(@(x)simrfV2vector2str(x(1,:)),y,...
    'UniformOutput',false);
    A=[Aname_cell(idxPolesNotEmpty);reshape(tempstr(idxPolesNotEmpty),...
    1,[])];
    tempstr=cellfun(@(x)simrfV2vector2str(x(2,:)),y,...
    'UniformOutput',false);
    C=[Cname_cell(idxPolesNotEmpty);reshape(tempstr(idxPolesNotEmpty),...
    1,[])];
    DFmat=reshape(DF,nport,nport);
    D=[Dname_cell;{simrfV2vector2str(cell2mat(reshape(DFmat.',1,[])))}];

    cacheData.RationalModel.ACell=A;
    cacheData.RationalModel.CCell=C;
    cacheData.RationalModel.DCell=D;
    z0=auxData.Spars.Impedance;
    cacheData.RationalModel.Z0Cell={'Z0';...
    simrfV2vector2str(real(z0).*ones(1,nport))};
end

function cacheData=process_single_sparam(auxData,cacheData)



    sparam=auxData.Spars.Parameters;
    nport=cacheData.NumPorts;

    [~,~,Dname_cell]=get_rational_param_names(1);
    DF=sparam(:);
    cacheData.RationalModel.A={};
    cacheData.RationalModel.C={};
    cacheData.RationalModel.D=DF;
    cacheData.RationalModel.ACell={};
    cacheData.RationalModel.CCell={};
    DFmat=reshape(DF,sqrt(size(DF,1)),[]);
    DF_real=reshape(DFmat.',1,[]);

    cacheData.RationalModel.DCell=[Dname_cell;{simrfV2vector2str(DF_real)}];
    if isscalar(auxData.Spars.Impedance)
        ImpVec=real(auxData.Spars.Impedance)*ones(1,nport);
    else
        ImpVec=real(auxData.Spars.Impedance);
    end
    cacheData.RationalModel.Z0Cell={'Z0';simrfV2vector2str(ImpVec)};
    cacheData.FitErrorAchieved=[];
end

function y=process_poles_residues(xin)



    x=simrfV2rmconj(xin);
    tempy=[real(x(:,1)),imag(x(:,1)),real(x(:,2)),imag(x(:,2))];

    y=[reshape(tempy(:,1:2).',1,[]);reshape(tempy(:,3:4).',1,[])];

end

function[Aname_cell,Cname_cell,Dname_cell]=...
    get_rational_param_names(nport)

    Aname_cell=cell(1,nport*nport);
    Cname_cell=Aname_cell;
    Dname_cell={'D'};
    for ii=1:nport
        for kk=1:nport
            idx=nport*(ii-1)+kk;
            Aname_cell{idx}=sprintf('P%d%d',kk,ii);
            Cname_cell{idx}=sprintf('R%d%d',kk,ii);
        end
    end
end

function check_fiterror(achieved_relerr,FitTol,ParamName,blockname)

    if achieved_relerr>FitTol
        warning(message('simrf:simrfV2errors:ErrorToleranceNotMet',...
        blockname,ParamName,sprintf('%4.2f',achieved_relerr)))
    end
end