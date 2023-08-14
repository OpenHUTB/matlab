function generateDeployableSimWrapper(modelName,varargin)






































    product="Simulink_Compiler";
    [status,msg]=builtin('license','checkout',product);
    if~status
        product=extractBetween(msg,'Cannot find a license for ','.');
        if~isempty(product)
            error(message('simulinkcompiler:build:LicenseCheckoutError',product{1}));
        end
        error(msg);
    end


    opts=parseInputs(modelName,varargin{:});

    if exist(opts.FcnName,'file')==2
        error([opts.FcnName,' exists. Either delete it or specify a different name.']);
    end
    strrep(opts.FcnName,'.m','');

    opts.InputMATFile=[opts.FcnName,'_inputs'];
    opts.OutputMATFile=[opts.FcnName,'_outputs'];



    defSimInp=simulink.compiler.internal.getDefaultSimulationInput(modelName);
    save(opts.InputMATFile,'defSimInp');
    fprintf('### Saved default simulation input to: %s\n',opts.InputMATFile);


    createSimWrapper(modelName,opts);

end



function createSimWrapper(modelName,opts)



    simWrapperTmpl=fullfile(fileparts(mfilename('fullpath')),...
    '+internal',...
    'templates',...
    'SimWrapperTemplate.m');
    [fInp,errmsg]=fopen(simWrapperTmpl);
    if fInp<0,error(errmsg);end
    contents=fread(fInp,'*char')';
    status=fclose(fInp);
    if status~=0,error(['Error closing ',simWrapperTmpl,' after read']);end


    contents=strrep(contents,'SimWrapperTemplate',opts.FcnName);


    contents=strrep(contents,'TOKEN_ModelName',modelName);


    contents=strrep(contents,'TOKEN_InputMATFile',opts.InputMATFile);


    contents=strrep(contents,'TOKEN_OutputMATFile',opts.OutputMATFile);



    fName=[opts.FcnName,'.m'];
    [fOut,errmsg]=fopen(fName,'wt');
    if fOut<0,error(errmsg);end
    fprintf(fOut,'%s\n',contents);
    status=fclose(fOut);
    if status~=0,error(['Error closing ',fName,' after write']);end
    fprintf('### Created: %s\n',fName);

end



function opts=parseInputs(modelName,varargin)
    p=inputParser;
    p.addRequired('ModelName',@load_system);

    defaultFcnName=[modelName,'_SimWrapper'];
    p.addParameter('FcnName',defaultFcnName,@isvarname);

    p.parse(modelName,varargin{:});

    opts=p.Results;
end
