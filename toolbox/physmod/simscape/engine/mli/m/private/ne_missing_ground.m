function[status,c_err_string]=ne_missing_ground(sys,si)











    dxf=ne_sparse_system_method(sys,'DXF',si);
    status=0;
    c_err_string='';
    if sys.NumStates==0
        return;
    end

    order=sys.NumDiffStates+1:sys.NumStates;








    varDimensions={sys.VariableData.dimension}';
    scalar=(prod(cell2mat(varDimensions(order)),2)==1);
    order=[order(scalar),order(~scalar)];








    varBlocks={sys.VariableData.object};
    varBlocks=strrep(varBlocks,sprintf('\n'),' ');
    varPaths={sys.VariableData.path};
    depth=cellfun(@(path,obj)nnz(path=='.')-nnz(obj=='/'),...
    varPaths(order),varBlocks(order));
    depth(cellfun(@isempty,varBlocks(order)))=Inf;
    [~,inds]=sort(depth,'descend');
    order=order(inds);
    isNodal=logical(cell2mat({sys.VariableData.nodal}));
    isLv=sys.LV(si)';
    isSlv=sys.SLV(si)'&~isLv;
    isNl=~isLv&~isSlv;
    order=[order(isLv(order)&~isNodal(order))...
    ,order(isLv(order)&isNodal(order))...
    ,order(isSlv(order))...
    ,order(isNl(order))];

    [~,dep,T]=ne_findindrows(dxf',order);
    isMissingRef=isLv&isNodal;
    isDepMissingRef=isMissingRef(dep);
    depRef=dep(isDepMissingRef);
    status=1.0*(~isempty(depRef));
    no_ref_msg='';
    TMissingRef=T(isDepMissingRef,:);
    missing_ref_id='physmod:simscape:engine:mli:ne_pre_transient_diagnose:PossibleMissingReference';
    if status~=0
        no_ref_msg=...
        [no_ref_msg,local_msg_per_var(sys,depRef,missing_ref_id,TMissingRef)];
        no_ref_msg=[no_ref_msg,sprintf('\n')];
    end








    isPureMissingVar=isLv&~isNodal&~any(dxf,1);
    lnni=find(isPureMissingVar);
    lnni=lnni(lnni>sys.NumDiffStates);
    no_var_msg='';
    if~isempty(lnni)
        status=1;
        missing_var_id='physmod:simscape:engine:mli:ne_pre_transient_diagnose:MissingVariable';




        no_var_msg=local_msg_per_var(sys,lnni,missing_var_id);

        no_var_msg=[no_var_msg,sprintf('\n')];
    end




    isComplex=~isPureMissingVar&~isMissingRef;
    isComplexDep=isComplex(dep);
    dep_vars_msg='';
    if nnz(isComplexDep)>0
        status=1;
        TComplex=T(isComplexDep,:);
        dep_vars_id='physmod:simscape:engine:mli:ne_pre_transient_diagnose:DependentVariables';
        dep_vars_msg=ne_message_combining_vars(sys,TComplex,dep_vars_id);
    end

    if status==0
        c_err_string='';
    else
        umbrella_string=pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:VariableUmbrella');
        umbrella_string=[umbrella_string,sprintf('\n\n')];
        c_err_string=[umbrella_string,no_ref_msg,no_var_msg,dep_vars_msg];
    end


    function msg=local_msg_per_var(sys,dep,id,Tpart)
        hyperlinks=ne_variable_hyperlink(sys,dep);
        msg='';
        for i=1:length(hyperlinks)
            if exist('Tpart','var')
                one_missing_ground_string=ne_allvars_hyperlink(sys,Tpart(i,:));
            else
                one_missing_ground_string='';
            end
            one_missing_ground_string=[one_missing_ground_string,pm_message(id,hyperlinks{i})];
            msg=[msg,one_missing_ground_string,sprintf('\n\n')];
        end
