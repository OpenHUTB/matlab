function privatecheckweights(weights,expectedSize)











    if isempty(weights)

        return
    end

    if isa(weights,'function_handle')
        try
            wVec=weights((1:5)');
        catch ME
            if strcmp('MATLAB:UndefinedFunction',ME.identifier)...
                &&~isempty(strfind(ME.message,func2str(weights)))
                error(message('stats:nlinfit:WeightFunctionNotFound',func2str(weights)));
            elseif strcmp('MATLAB:minrhs',ME.identifier)...
                &&nargin(weights)>1
                error(message('SimBiology:sbionlinfit:WeightFunMinRHS'));
            else
                m=message('stats:nlinfit:WeightFunctionError',func2str(weights));
                throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
            end
        end


        if~isnumeric(wVec)||size(wVec,1)~=5||size(wVec,2)~=1
            error(message('SimBiology:sbionlinfit:InvalidWeights'));
        end
    else

        if~isnumeric(weights)||any(~isreal(weights))||any(weights(~isnan(weights))<=0)
            error(message('SimBiology:sbionlinfit:InvalidWeights2'));
        end

        if~isequal(size(weights),expectedSize)
            error(message('SimBiology:sbionlinfit:WeightsWrongSize'));
        end

    end