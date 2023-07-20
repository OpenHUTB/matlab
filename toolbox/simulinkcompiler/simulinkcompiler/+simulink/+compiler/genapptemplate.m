function genapptemplate(sourceApp,varargin)






















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

    templateGenerator=simulink.compiler.internal.TemplateGenerator(sourceApp,varargin{:});
    templateGenerator.generate();

end
