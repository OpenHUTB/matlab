function out=fixIt(model,parameter,value,ignoreModelRef)















    if nargin<4
        ignoreModelRef=false;
    end

    model=strtok(model,'/');
    load_system(model);
    cs=getActiveConfigSet(model);


    info=configset.getParameterInfo(cs,parameter);
    staticInfo=info.ParamInfo;
    description=regexprep(staticInfo.getDescription,':$','');
    isCheckbox=strcmp(info.Type,'boolean');
    modelRef=staticInfo.ModelRef;


    newValue=~isequal(get_param(cs,parameter),value);
    if newValue

        ok=message('configset:util:OK').getString;
        cancel=message('configset:util:Cancel').getString;


        if isa(cs,'Simulink.ConfigSetRef')
            if~cs.isParameterOverridden(parameter)
                name=cs.getRefConfigSetName;
                if strcmp(cs.SourceLocation,'Data Dictionary')
                    question=message('configset:util:ConfigSetRefDDPromptQuestion',name,cs.DDName).getString;
                else
                    question=message('configset:util:ConfigSetRefPromptQuestion',name).getString;
                end
                response=questdlg(...
                question,...
                message('configset:util:ConfigSetRefPromptTitle').getString,...
                ok,cancel,cancel);
                if strcmp(response,cancel)

                    throw(MSLException([],message('configset:util:ChangeCanceled')));
                end
            end
        else

            if~ignoreModelRef&&~isempty(modelRef)
                question=message('configset:util:ConfigSetModelRefPromptQuestion',description,model).getString;
                response=questdlg(...
                question,...
                message('configset:util:ConfigSetModelRefPromptTitle').getString,...
                ok,cancel,cancel);
                if strcmp(response,cancel)

                    throw(MSLException([],message('configset:util:ChangeCanceled')));
                end
            end
        end

        try

            configset.internal.setParam(cs,parameter,value);
        catch me
            throw(MSLException([],...
            message('configset:diagnostics:ParameterFixFailWithReason',...
            description,getReason(me))));
        end

        if~isequal(get_param(cs,parameter),value)

            throw(MSLException([],message('configset:diagnostics:ParameterFixFail',...
            description)));
        end
    end


    if isCheckbox
        if xor(strcmp(value,'on'),staticInfo.isInvertValue)
            out=message('configset:diagnostics:ParameterFixSuccessSelect',model,parameter,description).getString;
        else
            out=message('configset:diagnostics:ParameterFixSuccessClear',model,parameter,description).getString;
        end
    else
        if~isempty(info.AllowedDisplayValues)
            displayValue=info.AllowedDisplayValues{strcmp(info.AllowedValues,value)};
        else
            displayValue=value;
        end
        out=message('configset:diagnostics:ParameterFixSuccess',model,parameter,description,displayValue).getString;
    end


    if newValue
        cs.refreshDialog;
    end

    function out=getReason(me)


        out=me.message;

        if~isempty(me.cause)


            if me.identifier=="configset:diagnostics:CannotChangeProp"

                out=me.cause{1}.message;
            end
        end
