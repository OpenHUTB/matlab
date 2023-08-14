

function result=actionFcnCallUsage()
    maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    system=bdroot(maObj.System);
    constraintMap=GetConstraints(system);
    if~isempty(constraintMap)
        keys=constraintMap.keys;

        for i=1:length(keys)
            constraint=constraintMap(keys{i});
            constraint.check(system);
            constraint.fixIncompatability(system);
        end

        of=Advisor.authoring.OutputFormatting('action');
        of.setConstraints(constraintMap);
        result=of.getFormattedOutput(system);
    else
        result=[];
    end
end

function ConstraintMap=GetConstraints(system)
    keys={};
    values={};
    currParamVal=get_param(bdroot(system),'FcnCallInpInsideContextMsg');
    if~strcmpi(currParamVal,'error')
        configParam.ParameterName='FcnCallInpInsideContextMsg';
        configParam.SupportedParameterValues={'error'};
        configParam.FixValue='error';
        configParam.ID='FcnCallInpInsideContextMsg';
        constraint=Advisor.authoring.PositiveModelParameterConstraint(configParam);
        constraint.IsRootConstraint=1;
        keys{end+1}='FcnCallInpInsideContextMsg';
        values{end+1}=constraint;
    end
    if~isempty(keys)
        ConstraintMap=containers.Map(keys,values);
    else
        ConstraintMap=[];
    end
end