function hisl_0040

    rec=getNewCheckObject('mathworks.hism.hisl_0040',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.ConfigurationParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ConfigurationParameterStyle'});

    rec.setLicense({HighIntegrity_License});

    act=ModelAdvisor.Action;
    act.setCallbackFcn(@fixSimulationOptions);
    act.Name=DAStudio.message('Advisor:engine:CCModifyButton');
    act.Description=DAStudio.message('Advisor:engine:CCActionDescription');
    rec.setAction(act);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function LifeSpan=getApplicationLifeSpan(system)
    LifeSpan=Advisor.Utils.Simulink.resolveConfigSetValue(bdroot(system),'LifeSpan');
    if isnumeric(LifeSpan)
        LifeSpan=lower(num2str(LifeSpan));
    end
    if(strcmp(get_param(bdroot(system),'IsERTTarget'),'on')&&strcmp(LifeSpan,'auto'))
        LifeSpan='1';
    end
end

function ConstraintMap=GetConstraints(system)

    def.ParameterName='StartTime';
    def.SupportedParameterValues={0};
    def.FixValue=0;
    def.ID='A';
    strtCnstrt=Advisor.authoring.PositiveModelParameterConstraint(def);
    strtCnstrt.IsRootConstraint=1;


    LifeSpan=getApplicationLifeSpan(system);

    StopTime=Advisor.Utils.Simulink.resolveConfigSetValue(bdroot(system),'StopTime');
    if ischar(StopTime)
        StopTime=str2double(StopTime);
    end

    def2.ID='B';
    def2.ParameterName='StopTime';
    def2.SupportedParameterValues={StopTime};


    if~(strcmp(LifeSpan,'inf')||strcmp(LifeSpan,'auto'))


        if(StopTime>=(str2double(LifeSpan)*86400))||(StopTime<=0)
            def2.SupportedParameterValues={str2double(LifeSpan)*86400-1};

            def2.FixValue=str2double(LifeSpan)*86400-1;
        end
    elseif(StopTime<=0)
        def2.SupportedParameterValues={2000};
        def2.FixValue=2000;
    end
    stpCnstrt=Advisor.authoring.PositiveModelParameterConstraint(def2);
    stpCnstrt.IsRootConstraint=1;

    ConstraintMap=containers.Map({'A','B'},{strtCnstrt,stpCnstrt});
end

function violations=hCheckAlgo(system)
    violations=[];
    system=bdroot(system);

    startTime=Advisor.Utils.Simulink.resolveConfigSetValue(system,'StartTime');
    if startTime~=0
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','StartTime','CurrentValue',num2str(startTime),'RecommendedValue',num2str(0));
        violations=[violations;vObj];
    end


    LifeSpan=getApplicationLifeSpan(system);
    stopTime=Advisor.Utils.Simulink.resolveConfigSetValue(system,'StopTime');
    if ischar(stopTime)
        stopTime=str2double(stopTime);
    end

    if~(strcmp(LifeSpan,'inf')||strcmp(LifeSpan,'auto'))


        if(stopTime>=(str2double(LifeSpan)*86400))||(stopTime<=0)||isnan(stopTime)
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','StopTime','CurrentValue',num2str(stopTime),'RecommendedValue',num2str(str2double(LifeSpan)*86400-1));
            violations=[violations;vObj];
        end
    elseif(stopTime<=0)
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','StopTime','CurrentValue',num2str(stopTime),'RecommendedValue',num2str(2000));
        violations=[violations;vObj];
    end
end

function result=fixSimulationOptions(~)
    maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    system=bdroot(maObj.System);
    constraintMap=GetConstraints(system);
    keys=constraintMap.keys;

    for i=1:length(keys)
        constraint=constraintMap(keys{i});
        constraint.check(system)
        constraint.fixIncompatability(system);
    end

    of=Advisor.authoring.OutputFormatting('action');
    of.setConstraints(constraintMap);

    result=of.getFormattedOutput(system);
end
