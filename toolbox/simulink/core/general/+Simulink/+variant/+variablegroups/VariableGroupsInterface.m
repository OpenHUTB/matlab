classdef VariableGroupsInterface<handle




    properties
        modelName char;
        origModelName char;
        variableGroups;
    end

    methods(Access='protected')


        function cvvMod=getParamWithUpdateValue(~,cvv,cvvSpecified)
            cvvMod=copy(cvvSpecified);
            isSlexprValue=isa(cvvMod.Value,'Simulink.data.Expression');
            if isSlexprValue
                cvvMod.Value=cvv;
            else




                cvvMod.Value=str2num([class(cvvMod.Value),'(',Simulink.variant.reducer.utils.i_num2str(cvv),')']);%#ok<ST2NM>
            end
        end





        function ctrlVars=updateCtrlVarsForslVarCtrl(~,ctrlVars,slVarCtrlNameValueMap)
            if isempty(intersect(slVarCtrlNameValueMap.keys(),{ctrlVars().Name}))
                return;
            end


            for i=1:numel(ctrlVars)
                if slVarCtrlNameValueMap.isKey(ctrlVars(i).Name)



                    value=ctrlVars(i).Value;
                    ctrlVars(i).Value=slVarCtrlNameValueMap(ctrlVars(i).Name);
                    if ischar(value)||isstring(value)
                        ctrlVars(i).Value.Value=str2num(value);%#ok<ST2NM>
                    else

                        ctrlVars(i).Value.Value=value;
                    end
                end
            end
        end






        function val=getUpdatedValueForParamsAndSLVarCtrl(obj,cvv,cvvSpecified,skipGlobalWksCheck)
            val=[];



            isCvvSpecifiedSimParameter=Simulink.variant.manager.configutils.isScalarParameterObj(cvvSpecified);


            isCvvSimParameter=Simulink.variant.manager.configutils.isScalarParameterObj(cvv);


            isCvvSpecifiedSimVarCtrl=Simulink.variant.manager.configutils.isScalarVariantControlObj(cvvSpecified);
            isCvvSimVarCtrl=Simulink.variant.manager.configutils.isScalarVariantControlObj(cvv);



            if(isCvvSimParameter||isCvvSimVarCtrl)
                val=cvv;
            elseif isCvvSpecifiedSimParameter&&~skipGlobalWksCheck





                val=obj.getParamWithUpdateValue(cvv,cvvSpecified);
            elseif isCvvSpecifiedSimVarCtrl&&~skipGlobalWksCheck


                cvvMod=cvvSpecified;
                if Simulink.variant.manager.configutils.isScalarParameterObj(cvvSpecified)
                    cvvMod.Value=obj.getParamWithUpdateValue(cvv,cvvMod.Value);
                else
                    cvvMod.Value=str2num([class(cvvMod.Value),'(',Simulink.variant.reducer.utils.i_num2str(cvv),')']);%#ok<ST2NM>
                end
                val=cvvMod;
            end
        end
    end

    methods(Abstract)
        createConfig(obj,configName,ctrlVars,slVarCtrlNameValueMap)
        val=getControlVariableValue(obj,cvv,cvvSpecified,skipGlobalWksCheck);
    end

end


