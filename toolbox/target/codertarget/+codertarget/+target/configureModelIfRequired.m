function configureModelIfRequired(hCS)





    products={...
    {'Simulink Coder','UseSimulinkCoderFeatures'},...
    {'Embedded Coder','UseEmbeddedCoderFeatures'}...
    };
    fill={'';' and '};
    requiredCodersText='';
    missingCodersText='';
    missingCodersParameters={};
    for i=1:length(products)
        if isequal(get_param(hCS,products{i}{2}),'on')
            requiredCodersText=[requiredCodersText,...
            fill{~isempty(requiredCodersText)+1},...
            products{i}{1}];%#ok<AGROW>
            if~dig.isProductInstalled(products{i}{1})
                missingCodersText=[missingCodersText,...
                fill{~isempty(missingCodersText)+1},...
                products{i}{1}];%#ok<AGROW>
                missingCodersParameters{end+1}=products{i}{2};%#ok<AGROW>
            end
        end
    end

    if~isempty(missingCodersParameters)
        reply='';
        msg=DAStudio.message('codertarget:build:CodersUnavailableQuestion',...
        requiredCodersText,missingCodersText,missingCodersText);
        while(isempty(reply))
            reply=questdlg(msg,'Question Dialog','Continue','Abort','Continue');
        end
        if isequal(reply,'Continue')
            for i=1:numel(missingCodersParameters)
                set_param(hCS,missingCodersParameters{i},'off');
                if isequal(missingCodersParameters{i},'UseEmbeddedCoderFeatures')
                    if slfeature('AutoMigrationIM')>0



                        codertarget.target.copyInactiveCodeMappingsIfNeeded(hCS.getModel)
                    end
                end
            end
        else
            DAStudio.error('codertarget:build:CodersUnavailableError',...
            requiredCodersText,missingCodersText);
        end
    end
end


