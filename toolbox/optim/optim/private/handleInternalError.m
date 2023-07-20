function ME=handleInternalError(internalExitCode,caller)












    if nargin<2||~any(strcmpi(caller,{'intlinprog','linprog','quadprog'}))
        return;
    end


    catalog=sprintf('optim:%s:',lower(caller));


    switch internalExitCode
    case '1'


        catalog=sprintf('%sCoefficientsAreNaN',catalog);
        ME=MException(catalog,getString(message(catalog)));
    case '0'


        catalog=sprintf('%sCoefficientsTooLarge',catalog);
        ME=MException(catalog,getString(message(catalog)));
    case '-2_3'

        catalog=sprintf('%sFinalConstraintsViolated',catalog);
        ME=MException(catalog,getString(message(catalog,...
        internalExitCode)));
    case '-2_4'

        catalog=sprintf('%sFinalConstraintsViolated',catalog);
        ME=MException(catalog,getString(message(catalog,...
        internalExitCode)));
    otherwise


        catalog=sprintf('%sUnknownError',catalog);
        ME=MException(catalog,getString(message(catalog,...
        internalExitCode)));
    end


    throwAsCaller(ME);
