function[initialValue,isCoderConstant]=getGlobalInitialValueSingle(varName)
    try
        globals=whos('global');
        for ii=1:numel(globals)
            if strcmp(globals(ii).name,varName)
                eval(['global ',varName]);
                globalValue=eval(varName);
                globalValue=coder.internal.makeDoubleTypesSingle(globalValue);
                if isa(globalValue,'coder.Constant')
                    initialValue=globalValue.Value;
                    isCoderConstant=true;
                else
                    initialValue=globalValue;
                    isCoderConstant=false;
                end
                break;
            end
        end
    catch
    end
end
