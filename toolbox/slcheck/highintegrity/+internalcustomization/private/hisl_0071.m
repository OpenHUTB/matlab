function hisl_0071

    rec=getNewCheckObject('mathworks.hism.hisl_0071',false,@hCheckAlgo,'None');
    rec.SupportLibrary=false;
    rec.SupportExclusion=false;

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function violations=hCheckAlgo(system)
    violations=[];
    system=bdroot(system);

    part1Violations=[];
    if checkDeviceType(system,'32-bit Generic')
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','ProdHWDeviceType','CurrentValue',get_param(system,'ProdHWDeviceType'));
        vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_warn');
        vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_rec_action');
        vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_subtitle');
        vObj.Description='IGNORE';
        vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_description');
        part1Violations=[part1Violations;vObj];

    elseif~checkDeviceType(system,'ASIC/FPGA')
        if strcmp(get_param(system,'ProdEndianess'),'Unspecified')
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','ProdEndianess','CurrentValue',get_param(system,'ProdEndianess'));
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_warn');
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_rec_action');
            vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_subtitle');
            vObj.Description='IGNORE';
            vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_description');
            part1Violations=[part1Violations;vObj];
        end
        if strcmp(get_param(system,'ProdIntDivRoundTo'),'Undefined')
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','ProdIntDivRoundTo','CurrentValue',get_param(system,'ProdIntDivRoundTo'));
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_warn');
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_rec_action');
            vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_subtitle');
            vObj.Description='IGNORE';
            vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_description');
            part1Violations=[part1Violations;vObj];
        end

        if~strcmp(get_param(system,'TargetHWDeviceType'),'Unspecified')

            if strcmp(get_param(system,'TargetEndianess'),'Unspecified')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','TargetEndianess','CurrentValue',get_param(system,'TargetEndianess'));
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_warn');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_rec_action');
                vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_subtitle');
                vObj.Description='IGNORE';
                vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_description');
                part1Violations=[part1Violations;vObj];
            end

            if strcmp(get_param(system,'TargetIntDivRoundTo'),'Undefined')
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','TargetIntDivRoundTo','CurrentValue',get_param(system,'TargetIntDivRoundTo'));
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_warn');
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_rec_action');
                vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_subtitle');
                vObj.Description='IGNORE';
                vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_description');
                part1Violations=[part1Violations;vObj];
            end
        else
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Model',system,'Parameter','TargetHWDeviceType','CurrentValue',get_param(system,'TargetHWDeviceType'));
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_warn');
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_rec_action');
            vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_subtitle');
            vObj.Description='IGNORE';
            vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_description');
            part1Violations=[part1Violations;vObj];
        end
    end

    if isempty(part1Violations)
        vObj=ModelAdvisor.ResultDetail;
        vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_pass');
        vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_subtitle');
        vObj.Description='IGNORE';
        vObj.RecAction='IGNORE';
        vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_a_description');
        vObj.IsViolation=false;
        violations=[violations;vObj];
    else
        violations=[violations;part1Violations];
    end


    Part2Violations=[...
    compareAndEmit(system,'ProdBitPerChar','TargetBitPerChar');...
    compareAndEmit(system,'ProdBitPerShort','TargetBitPerShort');...
    compareAndEmit(system,'ProdBitPerInt','TargetBitPerInt');...
    compareAndEmit(system,'ProdBitPerLong','TargetBitPerLong');...
    compareAndEmit(system,'ProdShiftRightIntArith','TargetShiftRightIntArith');...
    compareAndEmit(system,'ProdBitPerLongLong','TargetBitPerLongLong');...
    compareAndEmit(system,'ProdLongLongMode','TargetLongLongMode');...
    compareAndEmit(system,'ProdEndianess','TargetEndianess');...
    compareAndEmit(system,'ProdIntDivRoundTo','TargetIntDivRoundTo')];

    if isempty(Part2Violations)
        vObj=ModelAdvisor.ResultDetail;
        vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_b_pass');
        vObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_b_subtitle');
        vObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_b_description');
        vObj.Description='IGNORE';
        vObj.RecAction='IGNORE';
        vObj.IsViolation=false;
        violations=[violations;vObj];
    else
        violations=[violations;Part2Violations];
    end
end

function flag=checkDeviceType(system,typeString)
    try
        flag=RTW.isHWDeviceTypeEq(get_param(system,'ProdHWDeviceType'),typeString);
    catch ME
        switch ME.identifier
        case 'RTW:targetRegistry:badHWType'
            if strcmp(typeString,'32-bit Generic')
                flag=false;
            elseif strcmp(typeString,'ASIC/FPGA')
                flag=true;
            end
        otherwise
            rethrow(ME)
        end
    end
end

function rdObj=compareAndEmit(system,Param1,Param2)
    rdObj=[];
    pVal1=num2str(get_param(system,Param1));
    try
        pVal2=num2str(get_param(system,Param2));
    catch
        pVal2='Unspecified';
    end

    if~strcmp(pVal1,pVal2)
        rdObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(rdObj,'Custom',...
        DAStudio.message('ModelAdvisor:hism:hisl_0071_b_column1'),Advisor.Utils.getHyperlinkToConfigSetParameter(system,Param1),...
        DAStudio.message('Advisor:engine:CurrentValue'),pVal1,...
        DAStudio.message('ModelAdvisor:hism:hisl_0071_b_column2'),Advisor.Utils.getHyperlinkToConfigSetParameter(system,Param2),...
        DAStudio.message('Advisor:engine:CurrentValue'),pVal2);
        rdObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0071_b_warn');
        rdObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0071_b_rec_action');
        rdObj.Title=DAStudio.message('ModelAdvisor:hism:hisl_0071_b_subtitle');
        rdObj.Information=DAStudio.message('ModelAdvisor:hism:hisl_0071_b_description');
        rdObj.Description='IGNORE';
    end
end