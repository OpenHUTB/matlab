function b=normalizeSystem(model)




    if nargin==0
        pm_error('MATLAB:minrhs');
    end

    b='off';
    if exist('is_simulink_loaded','file')&&is_simulink_loaded()&&bdIsLoaded(model)
        cs=getActiveConfigSet(model);
        if cs.isValidParam('SimscapeNormalizeSystem')
            b=get_param(model,'SimscapeNormalizeSystem');
        end
    end
end
