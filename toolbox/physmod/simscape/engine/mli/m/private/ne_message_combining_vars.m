function msg=ne_message_combining_vars(sys,T,id)


    msg='';
    for i=1:size(T,1)
        diffVarAppendDotDer=true;
        hyperlinks=ne_variable_hyperlink(sys,find(T(i,:)),diffVarAppendDotDer);
        hyp_ret=cellfun(@(x)[x,sprintf('\n')],hyperlinks,'UniformOutput',false);
        one_var_dependency_string=...
        [ne_allvars_hyperlink(sys,T(i,:)),pm_message(id,cell2mat(hyp_ret))];
        msg=[msg,one_var_dependency_string,sprintf('\n\n')];%#ok
    end





