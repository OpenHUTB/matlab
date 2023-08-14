function A=ne_sparse_system_method(ssys,value_fcn_name,ss_inputs)



    pattern_fcn_name=[value_fcn_name,'_P'];
    A=double(ssys.(pattern_fcn_name)(ss_inputs));
    A(A~=0)=ssys.(value_fcn_name)(ss_inputs);
