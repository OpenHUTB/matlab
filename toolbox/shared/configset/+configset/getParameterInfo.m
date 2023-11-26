function info=getParameterInfo(csOrModel,paramName,component)

    if nargin<2
        error(message('Simulink:dialog:MissingInpArgs'));
    end

    if~ischar(paramName)&&~isStringScalar(paramName)
        error(message('Simulink:dialog:PrmMustBeStr'));
    end



    if isa(csOrModel,'Simulink.ConfigSet')&&strcmp(csOrModel.IsDialogCache,'on')
        cs=csOrModel;
    else
        cs=configset.util.getConfigSetObject(csOrModel);
    end

    if nargin<3
        hasComponent=false;
    else
        hasComponent=true;
    end

    info=[];

    if isempty(cs)
        dm=configset.internal.getConfigSetStaticData;
        if hasComponent&&isempty(dm.getComponent(component))
            DAStudio.error('Simulink:ConfigSet:Component_NotFound',component);
        end
        if dm.isValidParam(paramName)
            p=dm.getParam(paramName);
            if iscell(p)
                if hasComponent
                    for i=1:length(p)
                        tmp=configset.ParameterStaticInfo(p{i});
                        if strcmp(component,tmp.Component)
                            info=tmp;
                            break;
                        end
                    end
                else
                    info=cellfun(@(param)configset.ParameterStaticInfo(param),p,'UniformOutput',false);
                end
            else
                info=configset.ParameterStaticInfo(p);
            end
        end
    else
        if hasComponent
            MSLDiagnostic('Simulink:ConfigSet:Component_NotNeeded',component).reportAsWarning;
        end

        dm=configset.internal.data.ConfigSetAdapter(cs);
        if dm.isValidParam(paramName)
            p=dm.getParamData(paramName);
            if~isempty(p)



                info=configset.ParameterInfo(cs,p,dm);
            end
        end
    end

    if isempty(info)
        DAStudio.error('Simulink:dialog:NoSuchParameter',paramName);
    end
end

