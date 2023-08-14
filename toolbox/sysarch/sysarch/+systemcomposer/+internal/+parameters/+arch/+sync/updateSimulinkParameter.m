function updateSimulinkParameter(blockOrModelHandle,paramName,propName,propVal)





    isModel=strcmp(get_param(blockOrModelHandle,'Type'),'block_diagram');
    if strcmpi(propName,'units')
        propName='Unit';
    end


    if isModel
        if strcmpi(propName,'Minimum')
            propName='Min';
            propVal=str2num(propVal);%#ok<*ST2NM>
        elseif strcmpi(propName,'Maximum')
            propName='Max';
            propVal=str2num(propVal);
        end

        modelWksp=get_param(blockOrModelHandle,'ModelWorkspace');
        if modelWksp.hasVariable(paramName)
            slParam=modelWksp.getVariable(paramName);
            if strcmp(propName,'Name')
                assignin(modelWksp,propVal,slParam);
                evalin(modelWksp,['clear ',paramName]);
                if~isobject(slParam)
                    existing_args=get_param(blockOrModelHandle,'ParameterArgumentNames');
                    if isempty(existing_args)
                        existing_args=name;
                    else
                        existing_args=sprintf('%s, %s',existing_args,propVal);
                    end
                    set_param(blockOrModelHandle,'ParameterArgumentNames',existing_args);
                end
            else


                if isa(slParam,'Simulink.Parameter')
                    try
                        if strcmpi(propName,'Value')
                            slParam.Value=eval(propVal);
                        else
                            slParam.set(propName,propVal);
                        end
                    catch exp
                        throw(exp);
                    end
                else
                    warnState=warning('query','backtrace');
                    oc=onCleanup(@()warning(warnState));
                    warning off backtrace;
                    warning('SystemArchitecture:Parameter:UnsupportedModelArgument',...
                    DAStudio.message(...
                    'SystemArchitecture:Parameter:UnsupportedModelArgument',...
                    paramName));
                end
            end
        end

    else

        maskObj=get_param(blockOrModelHandle,'MaskObject');
        maskParam=maskObj.getParameter(paramName);


        if strcmpi(propName,'Minimum')
            propName='Min';
        elseif strcmpi(propName,'Maximum')
            propName='Max';
        elseif strcmpi(propName,'Units')
            propName='Unit';
        elseif strcmpi(propName,'Type')
            propName='DataType';
        elseif strcmpi(propName,'Value')
            propName='DefaultValue';
        elseif strcmpi(propName,'Dimensions')
            if isnumeric(propVal)

                propVal=mat2str(propVal);
            end
        end


        if strcmp(propName,'Unit')
            unitVal=Simulink.Mask.Unit;
            unitVal.BaseUnit=propVal;
            propVal=unitVal;
        end


        oldVal=maskParam.(propName);
        try
            maskParam.(propName)=propVal;
        catch e


            maskParam.(propName)=oldVal;
            throw(e);
        end
    end