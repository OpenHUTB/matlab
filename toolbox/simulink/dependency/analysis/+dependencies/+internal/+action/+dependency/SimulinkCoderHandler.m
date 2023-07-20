classdef SimulinkCoderHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="SimulinkCoder";
    end

    methods
        function unhilite=openUpstream(~,dependency)
            unhilite=@()[];

            [cs,modelName]=getConfigSet(dependency);

            if isempty(cs)
                return;
            end

            types=dependency.Type.Parts;
            if length(types)>3
                if~strcmp(types(3),"CodeCustomization")
                    return;
                end

                subGroup=types(4);
            elseif length(types)<3||strcmp(types(3),"CustomCode")
                subGroup="Custom Code";
            else
                subGroup=types(3);
            end

            unhilite=i_showParameterGroup(cs,subGroup,modelName);
        end
    end
end

function unhilite=i_showParameterGroup(cs,subGroup,modelName)
    unhilite=@()[];

    group="Code Generation";

    switch(subGroup)
    case{"Custom Code","Comments"}
        configset.showParameterGroup(cs,[group,subGroup]);
    case{"Templates"}
        if strcmp(get_param(modelName,"SystemTargetFile"),"ert.tlc")
            configset.showParameterGroup(cs,[group,subGroup]);
        else
            configset.showParameterGroup(cs,group);
        end
    case{"PostCodeGenCommand","MakeCommand","SystemTargetFile"}
        param=char(subGroup);
        unhilite=i_highliteParam(param,cs);
    case{"DefineNamingFcn","ParamNamingFcn","SignalNamingFcn"}
        param=char(subGroup);
        if i_isAvailableParam(param,cs)
            unhilite=i_highliteParam(param,cs);
        end
    otherwise
        configset.showParameterGroup(cs,group);
    end
end

function unhilite=i_highliteParam(param,cs)
    configset.highlightParameter(cs,param);
    unhilite=@()configset.clearParameterHighlights(cs);
end

function available=i_isAvailableParam(param,cs)
    configSetAdapter=configset.internal.data.ConfigSetAdapter(cs);
    status=configSetAdapter.getParamStatus(param);
    available=(status~=configset.internal.data.ParamStatus.UnAvailable);
end
