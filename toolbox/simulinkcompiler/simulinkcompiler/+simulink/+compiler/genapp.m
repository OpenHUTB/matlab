function app=genapp(modelName,varargin)


































    product="Simulink_Compiler";
    [status,msg]=builtin('license','checkout',product);
    if~status
        product=extractBetween(msg,'Cannot find a license for ','.');
        if~isempty(product)
            error(message('simulinkcompiler:build:LicenseCheckoutError',product{1}));
        end
        error(msg);
    end

    [varargin{:}]=convertStringsToChars(varargin{:});


    appGenerator=simulink.compiler.internal.AppGenerator(modelName,varargin{:});


    try
        appGenerator.generateTheApp();
    catch ME
        genAppException=MException(message('simulinkcompiler:genapp:ErrorGeneratingApp'));
        genAppException=addCause(genAppException,ME);
        throwAsCaller(genAppException);
    end


    app=appGenerator.launchApp();

end
