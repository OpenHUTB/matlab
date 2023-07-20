function jmaab_jc_0801





    mdladvRoot=ModelAdvisor.Root;
    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.jc_0801',false,@checkAlgo,'None');
    rec.SupportLibrary=false;
    rec.SupportExclusion=false;
    rec.Value=false;

    rec.setLicense({styleguide_license});

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.setCallbackFcn(@(system,checkObj)...
    Advisor.Utils.genericCheckCallback(...
    system,...
    checkObj,...
    'ModelAdvisor:jmaab:jc_0801',...
    @checkAlgo),...
    'PostCompile','DetailStyle');

    mdladvRoot.publish(rec,{sg_jmaab_group,sg_maab_group});

end


function result=checkAlgo(system)



    system=bdroot(system);
    result=[checkMPTObjects(system),checkCGTFiles(system)];

end


function res=checkMPTObjects(system)
    res=[];


    parameters=Simulink.findVars(system,'SearchMethod','cached');
    for i=1:length(parameters)

        obj=Advisor.Utils.safeEvalinGlobalScope(system,parameters(i).Name);
        if~(isa(obj,'mpt.Signal')||isa(obj,'mpt.Parameter'))
            continue;
        end


        if~isempty(regexp(obj.Description,'(/\*)|(\*/)','once'))
            failure=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(failure,'SID',parameters(i));
            res=[res,failure];%#ok<AGROW>
        end
    end
end


function res=checkCGTFiles(system)
    res=[];


    if~isequal(get_param(system,'SystemTargetFile'),'ert.tlc')
        return;
    end


    paramsToAnalyze={'ERTSrcFileBannerTemplate','ERTHdrFileBannerTemplate'...
    ,'ERTDataSrcFileTemplate','ERTDataHdrFileTemplate'};


    [paramsToAnalyze,files]=filterParams(system,paramsToAnalyze);


    for i=1:length(paramsToAnalyze)

        if isempty(files{i})||exist(files{i},'file')==0
            continue;
        end


        if startsWith(which(files{i}),matlabroot)
            continue;
        end

        data=fileread(files{i});
        if~isempty(regexp(data,'(/\*)|(\*/)','once'))
            failure=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(failure,'Model',system,'Parameter',paramsToAnalyze{i},'CurrentValue','-','RecommendedValue','-');
            res=[res,failure];%#ok<AGROW>
        end
    end
end


function[params,files]=filterParams(system,params)

    files=cellfun(@(x)get_param(system,x),params,'UniformOutput',false);
    [files,original]=unique(files,'stable');
    params=params(original);
end




