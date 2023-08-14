function jmaab_jc_0796


    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.jc_0796',false,@hCheckAlgo,'None');

    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramConvention=Advisor.Utils.createStandardInputParameters('jmaab.StandardSelection');
    paramMaxLength=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MaxLength',[2,2],[3,4]);

    paramLookUnderMasks.RowSpan=[1,1];
    paramLookUnderMasks.ColSpan=[3,4];
    paramConvention.RowSpan=[2,2];
    paramConvention.ColSpan=[1,2];

    [~,paramMaxLength.Value]=Advisor.Utils.Naming.getNameLength('JMAAB');

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters({paramFollowLinks,paramLookUnderMasks,paramConvention,paramMaxLength});
    rec.setInputParametersCallbackFcn(@inputParam_CallBack);

    rec.setLicense({styleguide_license,'Stateflow'});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function violations=hCheckAlgo(system)

    violations={};


    maObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    FL=Advisor.Utils.getStandardInputParameters(maObj,'find_system.FollowLinks');
    LUM=Advisor.Utils.getStandardInputParameters(maObj,'find_system.LookUnderMasks');

    inputParams=maObj.getInputParameters;
    maxLength=str2double(inputParams{4}.Value);

    if~isempty(maxLength)&&~isnan(maxLength)&&isnumeric(maxLength)
        maxLength=maxLength(1);
    else
        [~,maxLength]=Advisor.Utils.Naming.getNameLength('JMAAB');
        maxLength=str2double(maxLength);
    end

    allSFData=Advisor.Utils.Stateflow.sfFindSys(system,FL.Value,LUM.Value,{'-isa','Stateflow.Data'});
    systemObj=get_param(bdroot(system),'object');


    allSfObjs=systemObj.find('-isa','Stateflow.Data','SSIdNumber',0);

    allSFData=unique([cell2mat(allSFData);allSfObjs]);

    if isempty(allSFData)
        return;
    end


    allSFData=maObj.filterResultWithExclusion(allSFData);

    for idx=1:length(allSFData)
        if length(allSFData(idx).Name)>maxLength
            violations=[violations,makeViolation(allSFData(idx),maxLength)];%#ok<AGROW>
        end
    end
end

function res=makeViolation(sfData,maxLength)
    res=ModelAdvisor.ResultDetail();
    ModelAdvisor.ResultDetail.setData(res,'SID',sfData);
    res.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0796_rec_action',maxLength);
end

function inputParam_CallBack(taskobj,tag,handle)%#ok<INUSD>
    if strcmp(tag,'InputParameters_3')
        if isa(taskobj,'ModelAdvisor.Task')
            inputParameters=taskobj.Check.InputParameters;
        elseif isa(taskobj,'ModelAdvisor.ConfigUI')
            inputParameters=taskobj.InputParameters;
        else
            return
        end

        switch inputParameters{3}.Value
        case 'JMAAB'

            [~,inputParameters{4}.Value]=Advisor.Utils.Naming.getNameLength('JMAAB');
            inputParameters{4}.Enable=false;
        case 'Custom'
            inputParameters{4}.Enable=true;
        otherwise

        end

    end
end
