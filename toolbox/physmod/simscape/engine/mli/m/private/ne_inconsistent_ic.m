function[status,msg]=ne_inconsistent_ic(tsol,tin,tol,~)





























    [in,sol]=tsol.expand(tin);

    status=0;
    msg='';


    tol=tol/sqrt(size(sol.NumStates,1));


    highx=strcmp({sol.VariableData.init_mode},'MANDATORY');
    A=sparse(diag(highx));
    b=sol.IC(in);
    b(~highx)=0;
    res=A*in.X-b;

    unmet_targets=~(abs(res)<=tol);


    xder=zeros(sol.NumStates,1);
    nd=sol.NumDiffStates;
    if nd>0
        mass=ne_sparse_system_method(sol,'M',in);
        mass_dd=mass(1:nd,1:nd);
        f=sol.F(in);
        xder(1:nd)=mass_dd\f(1:nd);
    end


    icrm=ne_sparse_system_method(sol,'ICRM',in);
    is_initial_icr=cell2mat({sol.ICRData.initial});
    is_initial_icr=is_initial_icr(:);
    res_icrs=icrm*xder+sol.ICR(in);
    res_icrs(~is_initial_icr)=0;

    unmet_icrs=~(abs(res_icrs)<=tol);


    if~any(unmet_targets)&&~any(unmet_icrs)
        return;
    end


    status=1;
    nl=sprintf('\n');%#ok



    in.X(highx)=b(highx);


    linAlgRows=(~(sol.DXF_V_X(in)|...
    sol.DUF_V_X(in)|...
    sol.DTF_V_X(in)|...
    sol.VMF(in))|...
    sol.SLF(in));
    linAlgRows(1:sol.NumDiffStates)=false;

    dxf=ne_tosparse(sol.DXF_P(in),sol.DXF(in));
    ddf=ne_tosparse(sol.DDF_P(in),sol.DDF(in));
    dxicr=ne_tosparse(sol.DXICR_P(in),sol.DXICR(in));
    ddicr=ne_tosparse(sol.DDICR_P(in),sol.DDICR(in));

    df=[dxf,ddf;dxicr,ddicr];


    icr_linear=sol.ICR_IL(in);
    icr_rows=~any(sol.ICRM_P(in),2)&icr_linear&is_initial_icr;
    linAlgRows=[linAlgRows;icr_rows];

    df(~linAlgRows,:)=0;
    msg='';

    highd=strcmp({sol.DiscreteData.init_mode},'MANDATORY');
    high=[highx,highd];
    dfm=df(:,~high);

    [~,~,T]=ne_findindrows(dfm,1:size(dfm,1));


    f=[sol.F(in);sol.ICR(in)];
    f=f.*linAlgRows;
    c=T*f;


    bad=~(abs(c)<=tol);
    unmet_eqns=[zeros(sol.NumStates,1);unmet_icrs];

    msg_target=pm_message('physmod:simscape:engine:mli:ne_inconsistent_ic:VariableTargetsNotMet');
    msg=[msg,msg_target,nl,nl];

    if any(bad)


        cd=pm_message('physmod:simscape:engine:mli:ne_inconsistent_ic:ConstraintDetected');



        dc=T*df;
        vars_in_any_eqn=ne_logical_matrix_product(T,df);
        dc(~bad,:)=0;
        dc(abs(dc)<sqrt(eps))=0;
        dc(:,~high)=0;
        nz_dc=find(any(dc,2));


        for i=1:length(nz_dc)


            msg=[msg,cd,nl,nl];%#ok


            [~,inc_vars]=find(dc(nz_dc(i),:));


            unmet_targets(inc_vars)=0;


            hyperlinks=get_hyperlinks(sol,inc_vars);
            msg=[msg,hyperlinks{:},nl];%#ok

            [~,inc_eqns]=find(T(nz_dc(i),:));
            unmet_eqns(inc_eqns)=0;


            eqn_msg=get_one_eqn_string(sol,...
            T(nz_dc(i),:),...
            vars_in_any_eqn(nz_dc(i),1:sol.NumStates));
            msg=[msg,eqn_msg];%#ok
        end
    end

    if any(unmet_targets)

        cnd=pm_message('physmod:simscape:engine:mli:ne_inconsistent_ic:ConstraintNotDetected');



        hyperlinks=get_hyperlinks(sol,unmet_targets);
        msg=[msg,cnd,nl,nl,hyperlinks{:}];
    end

    if any(unmet_eqns)

        icrn=pm_message('physmod:simscape:engine:mli:ne_inconsistent_ic:ICRNotDetected');



        eqnd_msg=get_one_eqn_string(sol,unmet_eqns',[]);
        msg=[msg,icrn,nl,nl,eqnd_msg];%#ok
    end

end

function hyperlinks=get_hyperlinks(sol,vars)
    num_states=sol.NumStates;
    nl=sprintf('\n');%#ok

    hyperlinksx=ne_variable_hyperlink(sol,vars(vars<=num_states));
    for j=1:length(hyperlinksx)
        hyperlinksx{j}=[hyperlinksx{j},nl];
    end

    hyperlinksd=ne_discrete_hyperlink(sol,vars(vars>num_states)-num_states);
    for j=1:length(hyperlinksd)
        hyperlinksd{j}=[hyperlinksd{j},nl];
    end

    hyperlinks=[hyperlinksx,hyperlinksd];
end

function msg=get_one_eqn_string(sol,err_row,vars)
    to=pm_message('physmod:simscape:engine:mli:ne_inconsistent_ic:TopologyOnly');
    el=pm_message('physmod:simscape:engine:mli:ne_inconsistent_ic:EquationList');
    nl=sprintf('\n');%#ok

    [one_err_string,topology_only]=...
    ne_get_one_err_string(err_row,...
    sol.EquationData,...
    sol.EquationRange,...
    sol.VariableData,...
    vars,...
    sol.ICRData,...
    sol.ICRRange);

    if topology_only
        msg=[to,nl,nl];
    else
        msg=[el,nl,nl,one_err_string];
    end
end
