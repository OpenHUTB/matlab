classdef ParamUtils




    properties(Constant)
        SimulateUsingStringSetValues={...
        'SystemBlock:MATLABSystem:SimulateUsingCodeGeneration',...
        'SystemBlock:MATLABSystem:SimulateUsingInterpretedExecution'};
        SimulateUsingParameterValues={'Code generation','Interpreted execution'};
        SimulateUsingDialogValues={...
        getString(message('SystemBlock:MATLABSystem:SimulateUsingCodeGeneration')),...
        getString(message('SystemBlock:MATLABSystem:SimulateUsingInterpretedExecution'))};

        TreatAsFiStringSetValues={...
        'SystemBlock:MATLABSystem:TreatFixedPointAsFi',...
        'SystemBlock:MATLABSystem:TreatFixedPointAndIntegerAsFi'};
        TreatAsFiParameterValues={'Fixed-point','Fixed-point & Integer'};
        TreatAsFiDialogValues={...
        getString(message('SystemBlock:MATLABSystem:TreatFixedPointAsFi')),...
        getString(message('SystemBlock:MATLABSystem:TreatFixedPointAndIntegerAsFi'))};

        BlockDefaultFimathStringSetValues={...
        'SystemBlock:MATLABSystem:DefaultFiSameAsMatlab',...
        'SystemBlock:MATLABSystem:DefaultFiSpecifyOther'};
        BlockDefaultFimathParameterValues={'Same as MATLAB','Specify Other'};
        BlockDefaultFimathDialogValues={...
        getString(message('SystemBlock:MATLABSystem:DefaultFiSameAsMatlab')),...
        getString(message('SystemBlock:MATLABSystem:DefaultFiSpecifyOther'))};
    end

    methods(Static)
        function isReserved=isReservedParameterName(name)
            isReserved=ismember(name,...
            matlab.system.ui.ParamUtils.ReservedBlockParameterNames);
        end

        function dialogValue=paramValueToDialogValue(name,paramValue)
            if ismember(name,{'SimulateUsing','TreatAsFi','BlockDefaultFimath'})
                dialogValues=getDialogValues(name);
                paramValues=getParameterValues(name);
                dialogValue=dialogValues{strcmp(paramValue,paramValues)};
            else
                dialogValue=paramValue;
            end
        end

        function paramValue=dialogValueToParamValue(name,dialogValue)
            if ismember(name,{'SimulateUsing','TreatAsFi','BlockDefaultFimath'})
                dialogValues=getDialogValues(name);
                paramValues=getParameterValues(name);
                ind=find(strcmp(dialogValue,dialogValues));
                if isempty(ind)

                    paramValue=dialogValue;
                else
                    paramValue=paramValues{ind};
                end
            else
                paramValue=dialogValue;
            end
        end

        function options=getPopupParameterValues(paramName,typeOptions)
            if ismember(paramName,{'SimulateUsing','TreatAsFi','BlockDefaultFimath'})
                options=getParameterValues(paramName);
            else
                if~isempty(typeOptions)&&count(typeOptions{1},':')>=2
                    try
                        locale=matlab.internal.i18n.locale('en_US');
                        for i=1:length(typeOptions)
                            typeOptions{i}=getString(message(typeOptions{i}),locale);
                        end
                    catch
                    end
                end
                options=typeOptions;
            end
        end

        function vals=stringSetValuesToDialogValues(name,vals)

            if ismember(name,{'SimulateUsing','TreatAsFi','BlockDefaultFimath'})
                for k=1:numel(vals)
                    vals{k}=message(vals{k}).getString;
                end
            end
        end

        function ind=paramValueToDialogIndex(name,paramValue)
            if ismember(name,{'SimulateUsing','TreatAsFi','BlockDefaultFimath'})
                paramValues=getParameterValues(name);
                ind=find(strcmp(paramValue,paramValues))-1;
            else
                ind=paramValue;
            end
        end

        function names=ReservedBlockParameterNames








            persistent paramNames;
            persistent fullListComputed;
            if isempty(paramNames)||(~fullListComputed&&is_simulink_loaded)
                if is_simulink_loaded
                    sharedBlockNames=matlab.system.ui.getReservedSimulinkBlockParameterNames;
                    fullListComputed=true;
                else
                    sharedBlockNames={'Name','Tag','Description','Type','Parent','Handle',...
                    'Object','URL','Position','Orientation','InstanceData','UserData'};
                    fullListComputed=false;
                end
                systemBlockSpecificNames={'System','BlockParametersCall','SimulateUsing',...
                'SaturateOnIntegerOverflow','TreatAsFi','BlockDefaultFimath','InputFimath'};
                paramNames=[systemBlockSpecificNames,sharedBlockNames];
            end
            names=paramNames;
        end
    end
end

function paramValues=getParameterValues(name)
    propName=[name,'ParameterValues'];
    paramValues=matlab.system.ui.ParamUtils.(propName);
end

function paramValues=getDialogValues(name)
    propName=[name,'DialogValues'];
    paramValues=matlab.system.ui.ParamUtils.(propName);
end
