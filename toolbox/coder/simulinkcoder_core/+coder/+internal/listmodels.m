function models=listmodels




    openModels=i_get_open_models;
    pwdModels=i_get_pwd_models;

    models=unique([openModels(:)',pwdModels(:)']);

    function pwdModels=i_get_pwd_models


        modelExtExpr='\.((mdl)|(slx))$';

        d=dir(pwd);
        names={d.name};
        pwdModels=regexp(names,['.*',modelExtExpr],'match','once');
        keepIdx=~strcmp(pwdModels,'');
        pwdModels=pwdModels(keepIdx);


        pwdModels=regexprep(pwdModels,modelExtExpr,'','once');





        function models=i_get_open_models

            if is_simulink_loaded
                models=find_system('type','block_diagram');
            else
                models={};
            end

