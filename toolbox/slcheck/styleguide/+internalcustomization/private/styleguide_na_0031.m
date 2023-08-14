function styleguide_na_0031

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.na_0031',false,@hCheckAlgo,'PostCompile');
    rec.SupportExclusion=false;

    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.maab.na_0031';

    rec.setLicense({styleguide_license});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function violations=hCheckAlgo(system)

    violations=[];





    allVarsWithEnum=Advisor.Utils.Simulink.findVars(system,'on','all','IncludeEnumTypes',true);
    varsWithoutEnums=Advisor.Utils.Simulink.findVars(system,'on','all');

    enumVars=setdiff(allVarsWithEnum,varsWithoutEnums);

    for i=1:numel(enumVars)





        if~strcmpi(enumVars(i).SourceType,'MATLAB File')
            continue;
        end

        allMethods=methods(enumVars(i).Name,'-full');

        if~any(startsWith(allMethods,'Static')&endsWith(allMethods,'getDefaultValue'))
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'FileName',enumVars(i).Source);
            violations=[violations;vObj];%#ok<AGROW>
        end
    end

end