function uniqueVars=findVariantControlVars(model,varargin)























































    [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Simulink.VariantManager.findVariantControlVars');
    if~isInstalled
        throwAsCaller(err);
    end


    narginchk(1,3);
    nargoutchk(0,1);


    vars=Simulink.internal.vmgr.VMUtils.getEmptyCtrlVarsStruct();
    vars(end)=[];

    if~ischar(model)&&~(isstring(model)&&isscalar(model))

        messageId='Simulink:Variants:InvalidModelName';
        excepObj=MException(message(messageId));
        throw(excepObj);
    end

    if~isvarname(model)

        excepObj=MException(message('Simulink:LoadSave:InvalidBlockDiagramName',model));
        throwAsCaller(excepObj);
    end

    if~bdIsLoaded(model)

        excepObj=MException(message('Simulink:VariantManager:ModelNotLoaded',model));
        throwAsCaller(excepObj);
    end



    persistent p
    if isempty(p)
        p=inputParser;
        p.FunctionName='Simulink.VariantManager.findVariantControlVars';
        p.StructExpand=false;
        p.PartialMatching=false;
        addParameter(p,'SearchReferencedModels','on',@(x)validateattributes(x,...
        {'char','string','logical'},{}));
    end
    try
        parse(p,varargin{:});
        searchReferencedModels=p.Results.SearchReferencedModels;
        if ischar(searchReferencedModels)&&~any(strcmpi(searchReferencedModels,{'on','off'}))
            ME=MException(message('Simulink:Data:FindVarsBadBooleanValue','SearchReferencedModels'));
            throwAsCaller(ME);
        end
    catch ME
        throwAsCaller(ME);
    end

    if slfeature('VMGRV2UI')>0
        uniqueVars=slvariants.internal.manager.core.findVariantControlVars(model,...
        strcmpi(searchReferencedModels,'on'));

        uniqueVars=rmfield(uniqueVars,'Usage');




        [~,idx]=unique(strcat({uniqueVars.Name},{uniqueVars.Source}),'stable');
        uniqueVars=struct(uniqueVars(idx));

    else
        try
            optArgs=Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs();
            optArgs.RecurseIntoModelReferences=strcmpi(searchReferencedModels,'on');
            [varNames,variableUsageInfo,SourceInfo,errs]=Simulink.variant.utils.getControlVariableNamesFromVariantExpressions(model,optArgs);

            varsToModelsMap=Simulink.variant.utils.i_invertMap(SourceInfo.ModelsToVarsMap);

            for varIdx=1:numel(varNames)
                varName=varNames{varIdx};
                modelsUsingVar=varsToModelsMap(varName);
                for modelIdx=1:numel(modelsUsingVar)
                    specialVarsInfoManager=SourceInfo.SpecialVarsInfoManagerMap(modelsUsingVar{modelIdx});
                    vars=[vars;Simulink.internal.vmgr.VMUtils.getValuesOfControlVariables(modelsUsingVar{modelIdx},...
                    {varName},specialVarsInfoManager)];%#ok<AGROW>
                end
            end

            for varIdx=1:numel(vars)
                if~vars(varIdx).Exists&&~isa(vars(varIdx).Value,'Simulink.VariantControl')&&...
                    any(strcmp(vars(varIdx).Name,variableUsageInfo.ControlVarsFromParams))


                    vars(varIdx).Value=Simulink.VariantControl(Value=vars(varIdx).Value);
                end
            end


            uniqueVars=Simulink.internal.vmgr.VMUtils.getEmptyCtrlVarsStruct();

            uniqueVars(end)=[];
            allVarsSourcesMap=containers.Map();
            for i=1:numel(vars)

                if~(allVarsSourcesMap.isKey(vars(i).Name)&&any(strcmp(allVarsSourcesMap(vars(i).Name),vars(i).Source)))


                    Simulink.variant.utils.i_addKeyValueToMap(allVarsSourcesMap,vars(i).Name,{vars(i).Source});
                    uniqueVars(numel(uniqueVars)+1,1)=vars(i);
                end
            end
            warnState=warning('off','backtrace');
            for i=1:numel(errs)
                warning('Simulink:Variants:IncompleteVariantControlVariablesList',errs{i}.message);
            end
            warning(warnState.state,'backtrace');
        catch me
            throwAsCaller(me);
        end
    end
end


