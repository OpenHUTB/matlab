function pmsl_deletemodel(model,ext)














    simulinkExtensions=pmsl_simulinkextensions();

    if nargin==1
        ext={'mdl','slx'};
    end

    if~iscell(ext)
        ext={ext};
    end


    pm_assert(all(cellfun(@(x)any(strcmp(simulinkExtensions,x)),ext)),...
    'Invalid extensions found');

    for idx=1:numel(ext)
        modelFile=[model,'.',ext{idx}];
        if exist(modelFile,'file')
            delete(modelFile);
        end
    end

end
