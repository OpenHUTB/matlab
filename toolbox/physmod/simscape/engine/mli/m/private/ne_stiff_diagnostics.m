function[status,stiff,st]=ne_stiff_diagnostics(sys_in,inputs,s_method,solverName)

    try
        [status,stiff,st]=ne_stiff_diagnostics_internal(sys_in,inputs,s_method);


        for k=1:length(st)
            if isempty(st{k}.block)
                st{k}.block=strrep(solverName,sprintf('\n'),' ');
            end
        end

        if status~=0&&~isempty(st)
            warnId='physmod:simscape:engine:core:stiff:StiffFail';
            blk=strrep(solverName,sprintf('\n'),' ');
            quotedBlockString=sprintf('''%s''',blk);
            hyperlink=...
            ['<a href="matlab:simscape.internal.highlightSLStudio('...
            ,quotedBlockString,')">'...
            ,quotedBlockString,sprintf('</a>')];%#ok
            pm_warning(warnId,hyperlink,lGetMessage(status));
        end
    catch e
        rethrow(e);
    end

end

function[status,stiff,st]=ne_stiff_diagnostics_internal(sys_in,inputs,s_method)
    status=-1;
    stiff=0;
    st=[];

    if s_method==2
        [in,sys,pr]=sys_in.expand(inputs,'ParamDeriv');
    else
        [in,sys]=sys_in.expand(inputs);
    end

    st=get_default_result(sys);

    in.M=sys.MODE(in);
    sys.RESET(in);

    J=ne_sparse_system_method(sys,'DXF',in);
    M=ne_sparse_system_method(sys,'M',in);

    if has_inf_nan(J)||has_inf_nan(M)
        status=5;
        return;
    end

    dxf_p=sys.DXF_P(in);
    m_p=sys.M_P(in);

    n=sys.NumDiffStates;
    m=sys.NumStates;
    k=m-n;

    if n==0
        status=1;
        return;
    end

    A=J(1:n,1:n);
    B=J(1:n,n+1:m);
    C=J(n+1:m,1:n);
    D=J(n+1:m,n+1:m);

    J_v_x=sys.DXF_V_X(in);
    is_linear=(J_v_x==0);
    is_alg=[false(n,1);true(k,1)];
    is_general=cell2mat({sys.EquationData.general});
    is_general=is_general(:);
    is_topology=is_linear&~is_general;
    is_linear_not_topology=is_linear&is_general;
    is_switched_linear=sys.SLF(in)&~is_linear;
    is_nonlinear=~is_linear&~is_switched_linear;

    pm_assert(all(is_topology+is_linear_not_topology+is_switched_linear+is_nonlinear)==1);
    order_vec=[find(is_alg&is_topology);...
    find(is_alg&is_linear_not_topology);...
    find(is_alg&is_switched_linear);...
    find(is_alg&is_nonlinear)];
    pm_assert(length(unique(order_vec))==length(order_vec),'Repeated rows in order_vec');
    order_vec=order_vec-n;

    [indrows,deprows_all,T_all]=ne_findindrows(D,order_vec);


    ndep=0;
    if size(deprows_all,2)~=0
        ndep=size(deprows_all,1);
    end

    perm([1:n,deprows_all'+n,indrows'+n])=1:m;

    K=[M(1:n,1:n),-B;
    sparse(k,m)];
    K(deprows_all+n,1:n)=T_all*C;
    K(indrows+n,n+1:m)=-D(indrows,:);

    rhs=[A;
    sparse(k,n)];
    rhs(indrows+n,:)=C(indrows,:);

    [lastWarnMsg,lastWarnId]=lastwarn;
    lastwarn('');
    smw=warning('off','MATLAB:singularMatrix');
    nsmw=warning('off','MATLAB:nearlySingularMatrix');


    KS=K\rhs;
    KS=KS(1:n,:);

    KN=(KS+KS')/2;

    [~,ourWarnId]=lastwarn;


    lastwarn(lastWarnMsg,lastWarnId);
    warning(smw);
    warning(nsmw);

    if strcmp(ourWarnId,'MATLAB:singularMatrix')||strcmp(ourWarnId,'MATLAB:nearlySingularMatrix')
        if has_inf_nan(KS)
            status=2;
            return;
        end
    end


    [y,lambda]=eigs(KN,1,'smallestreal');

    if(lambda>=0)
        status=3;
        return;
    end

    yh=[y;
    sparse(k,1)];

    u=K'\yh;
    v=K\(rhs*y);

    if s_method==2
        prd={sys.ParameterInfo.reals};
        [np,~]=size(prd{:});

        dpdxf=ne_sparse_system_method(sys,'DPDXF',in);
        dpm=ne_sparse_system_method(sys,'DPM',in);


        pms=find(any(dpdxf,1)|any(dpm,1));
        pnames={sys.ParameterInfo.reals.path};

        pid=zeros(np,1);
        pidr=pid;
        pidc=pid;
        pidm=pid;

        for p=1:size(pms,2)
            pp=pms(p);

            PJ=double(dxf_p);
            PJ(PJ~=0)=dpdxf(:,pp);

            PM=double(m_p);
            PM(PM~=0)=dpm(:,pp);

            PD=PJ(n+1:m,n+1:m);
            PB=PJ(1:n,n+1:m);
            PC=PJ(n+1:m,1:n);
            PA=PJ(1:n,1:n);


            PJ=[PM(1:n,1:n),-PB;
            T_all*PC,sparse(ndep,k);
            sparse(k-ndep,n),-PD(indrows,:)];
            PJ=PJ(perm,:);


            Prhs=[PA;
            sparse(ndep,n);
            PC(indrows,:)];
            Prhs=Prhs(perm,:);

            KPJ=abs([u.*PJ.*v',u.*Prhs.*y']);
            mdpj=max(KPJ');
            [i,j]=max(mdpj);

            pidm(pp)=i;
            pidr(pp)=j;
            [~,j1]=max(KPJ(j,:));
            pidc(pp)=j1;
            pid(pp)=u'*Prhs*y-u'*PJ*v;


            val=pr(pp)*pr(pp);
            if(val>1||val==0.0)
                pidm(pp)=i*val;
                pid(pp)=pid(pp)*val;
            end
        end

        pid=sparse(abs(pid));
        pidr=sparse(pidr);

        if(any(pid))

            [~,j]=max(pid);


            row=pidr(j);


            col=pidc(j);

            param=pnames{j};
            prv=pr(j);
            st=get_stiffness_info(sys,M,J,row,col,param,prv);

            status=0;
            stiff=lambda;
        else
            status=4;
            return;
        end

    else
        PJ=matrix_element_diff(sys.DXF(in),dxf_p);
        PM=matrix_element_diff(sys.M(in),m_p);

        PD=PJ(n+1:m,n+1:m);
        PB=PJ(1:n,n+1:m);
        PC=PJ(n+1:m,1:n);
        PA=PJ(1:n,1:n);


        PJ=[PM(1:n,1:n),-PB;
        T_all*PC,sparse(ndep,k);
        sparse(k-ndep,n),-PD(indrows,:)];
        PJ=PJ(perm,:);


        Prhs=[PA;
        sparse(ndep,n);
        PC(indrows,:)];
        Prhs=Prhs(perm,:);

        KPJ=abs([u.*PJ.*v',u.*Prhs.*y']);
        mdpj=max(KPJ');
        [~,j]=max(mdpj);

        [~,j1]=max(KPJ(j,:));

        st=get_stiffness_info(sys,M,J,j,j1,'',0);
        status=0;
        stiff=lambda;
    end
end

function msg=lGetMessage(status)
    switch status
    case 1
        msgId='physmod:simscape:engine:core:stiff:NoDiff';
    case 2
        msgId='physmod:simscape:engine:core:stiff:HighIndex';
    case 3
        msgId='physmod:simscape:engine:core:stiff:NotStiff';
    case 4
        msgId='physmod:simscape:engine:core:stiff:NoParameter';
    case 5
        msgId='physmod:simscape:engine:core:stiff:InfNan';
    otherwise
        assert(false,'Incorrect status in stiff diagnostics');
    end

    msg=message(msgId).getString;
end

function B=matrix_element_diff(A,A_P)
    A(abs(A)<1&abs(A)>0)=1.0;
    ids=abs(A)>1;
    A(ids)=-A(ids).*A(ids);

    B=double(A_P);
    B(B~=0)=A;
end

function f=has_inf_nan(A)
    f=any(any(isinf(A)|isnan(A)));
end

function st=get_stiffness_info(sys,M,J,i,j,param,prv)





    n=sys.NumDiffStates;
    m=sys.NumStates;

    coef=0;
    is_der=true;

    if j<=n
        if i<=n
            coef=M(i,j);
        end
    else

        if j>m
            is_der=false;
            j=j-m;
        end
        coef=J(i,j);
    end

    coef=full(coef);
    vars=get_variable_string(sys,j,is_der);
    infoEqn=get_equation_info(i,sys);

    st=[];
    for k=1:length(vars)
        if~isempty(vars{k}{2})
            block=vars{k}{2};
        else
            block=infoEqn{k}{4};
        end

        sf=struct('parameter',param,...
        'value',prv,...
        'variable',vars{k}{1},...
        'coefficient',coef(k),...
        'block',block,...
        'location',infoEqn{k}{2},...
        'line',infoEqn{k}{3});
        st{end+1}=sf;
    end

end

function st=get_default_result(sys)



    st=[];

    if sys.NumStates==0
        return;
    end


    vars=get_variable_string(sys,1,false);
    infoEqn=get_equation_info(1,sys);

    st{1}=struct('parameter','',...
    'value',0.0,...
    'variable',vars{1}{1},...
    'coefficient',0.0,...
    'block',vars{1}(2),...
    'location',infoEqn{1}{2},...
    'line',infoEqn{1}{3});

end

function blockInfo=get_equation_info(rows,sys)


    equationData=sys.EquationData;
    equationRange=sys.EquationRange;
    isGeneral=cell2mat({equationData.general});
    isGeneral=isGeneral(:);

    hasRangeInfo=(cellfun(@l_eqn_has_info,{equationData.range_num},{equationData.range_start}))';
    blockInfo=[];

    for i=1:length(rows)
        idx=rows(i);

        topEq=1;
        fileName='';
        block='';
        fileLine=-1;

        if isGeneral(idx)
            topEq=0;
            if hasRangeInfo(idx)
                oneEqnData=equationData(idx);
                firstRange=equationRange(oneEqnData.range_start+1);
                fileName=firstRange.filename;
                block=oneEqnData.object;
                if strcmp(firstRange.type,'NORMAL')
                    fileLine=firstRange.endline;
                else
                    fileLine=-1;
                end
            end
        end

        blockInfo{end+1}={topEq,fileName,fileLine,block};
    end

    function result=l_eqn_has_info(rangeNum,rangeStart)
        if rangeStart+1>length(equationRange)
            result=false;
        elseif rangeNum==0
            result=false;
        elseif isempty(equationRange(rangeStart+1).filename)
            result=false;
        else
            result=true;
        end
    end


end

function vars=get_variable_string(sys,cols,diffVarsDiffed)


    var_data=sys.VariableData(cols);
    obsNames={sys.ObservableData.path}';
    obsMap=containers.Map(obsNames,1:length(obsNames));
    vars=[];
    for i=1:length(var_data)
        vd=var_data(i);
        varpath=simscape.internal.valuePathToUserString(vd.path);
        if prod(vd.dimension)>1
            varpath=[varpath,'(',num2str(vd.index),')'];%#ok
        end

        vname=varpath;

        description=vd.description;
        if diffVarsDiffed(i)&&vd.is_diff
            derId='physmod:simscape:engine:mli:ne_pre_transient_diagnose:TimeDerivativeOf';
            vname=[pm_message(derId),' ',vname];
        end
        if isempty(description)
            if obsMap.isKey(vd.path)
                description=sys.ObservableData(obsMap(vd.path)).description;
            end
        end
        if~isempty(description)
            vname=[vname,' (',description,')'];
        end

        vars{end+1}={vname,vd.object};
    end
end
