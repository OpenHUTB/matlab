function is=isValidControlVarValue2(ctrlVarInfo)








    value=ctrlVarInfo.Value;
    isParam=ctrlVarInfo.IsParam;
    isParamValueExpression=ctrlVarInfo.IsParamValueExpression;
    isAUTOSARParam=ctrlVarInfo.IsAUTOSARParam;
    isSimulinkVariantControl=ctrlVarInfo.IsSimulinkVariantControl;

    is=slvariants.internal.config.utils.isNonEmptyString(value)||isParamValueExpression;
    is=is&&(isParamValueExpression||isempty(find(strcmp(value,{'v','isParam','is','isParamValueExpression','isAUTOSARParam'}),1)));
    if~is
        return;
    end
    try
        if isSimulinkVariantControl
            varCtrl=Simulink.VariantControl();%#ok<NASGU>
            if isParam
                if~isAUTOSARParam
                    param=Simulink.Parameter;%#ok<NASGU>
                else
                    param=AUTOSAR.Parameter;%#ok<NASGU>
                end
                if isParamValueExpression
                    eval(['param.Value = slexpr(''',value,''');']);
                else
                    eval(['param.Value = ',value,';']);%#ok<EVLEQ>
                end
                eval('varCtrl.Value = param ;');%#ok<EVLCS>
            else
                eval(['varCtrl.Value = ',value,';']);%#ok<EVLEQ>
            end
        elseif~isParam
            eval(['avar = ',value,';']);%#ok<EVLEQ>
        else
            if~isAUTOSARParam
                param=Simulink.Parameter;%#ok
            else
                param=AUTOSAR.Parameter;%#ok
            end
            if isParamValueExpression



                eval(['param.Value = slexpr(''',value,''');']);
            else
                eval(['param.Value = ',value,';']);%#ok<EVLEQ>
            end
        end
    catch
        is=false;
    end
end
