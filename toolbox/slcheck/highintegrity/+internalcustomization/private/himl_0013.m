function himl_0013




    rec=getNewCheckObject('mathworks.hism.himl_0013',false,@hCheckAlgo,'PostCompile');
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams();
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[4,4];
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:himl_0013_Threshold');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='40';
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[5,15];
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:himl_0013_FunctionList');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value=[];
    inputParamList{end}.Visible=false;

    rec.setInputParametersLayoutGrid([15,5]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    rootDir=Simulink.fileGenControl('get','CacheFolder');
    if exist([rootDir,filesep,'slprj',filesep,'modeladvisor',filesep,'MA_IR_Data.mat'],'file')
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        threshold=mdladvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:hism:himl_0013_Threshold'));
        threshold=str2double(threshold.Value);

        fcnExclusionList=mdladvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:hism:himl_0013_FunctionList'));
        if isempty(fcnExclusionList.Value)
            fcnExclusionList='';
        else
            fcnExclusionList=strtrim(strsplit(fcnExclusionList.Value,','));
        end
        FL=mdladvObj.getInputParameterByName('Follow links');
        LUM=mdladvObj.getInputParameterByName('Look under masks');
        checkExt=mdladvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:hism:common_eml_check_ref_files'));


        fcnNames=getAllMATLABFunctionBlocks_loc(system,FL.Value,LUM.Value);
        fcnNames=mdladvObj.filterResultWithExclusion(fcnNames);
        for k=1:length(fcnNames)
            curFcn=fcnNames{k};
            blockH=get_param(curFcn,'handle');
            id=sfprivate('block2chart',blockH);
            ssid=1;
            chkSum=[sf('SFunctionSpecialization',id,blockH),num2str(ssid)];
            curFcnObj=idToHandle(sfroot,id);
            FailingObjs=[FailingObjs,CheckForViolation(curFcnObj,chkSum,threshold,fcnExclusionList,checkExt)];
        end


        sfChartName=sfFindSys_loc(system,FL.Value,LUM.Value);
        for idxChart=1:length(sfChartName)
            curChart=sfChartName{idxChart};
            chartBlockH=get_param(curChart,'handle');
            chartId=sfprivate('block2chart',chartBlockH);
            curChartObj=idToHandle(sfroot,chartId);
            EMFcnObj=find(curChartObj,{'-isa','Stateflow.EMFunction'});
            EMFcnObj=mdladvObj.filterResultWithExclusion(EMFcnObj);

            for idxEMF=1:length(EMFcnObj)
                if~EMFcnObj(idxEMF).isCommented
                    ssid=EMFcnObj(idxEMF).SSIdNumber;
                    chkSum=[sf('SFunctionSpecialization',chartId,chartBlockH),num2str(ssid)];
                    FailingObjs=[FailingObjs,CheckForViolation(EMFcnObj(idxEMF),chkSum,threshold,fcnExclusionList,checkExt)];
                end
            end
        end
    end
end

function violationObj=CheckForViolation(fcnObj,fcnName,threshold,fcnExclusionList,checkExt)
    rootDir=Simulink.fileGenControl('get','CacheFolder');
    load([rootDir,filesep,'slprj',filesep,'modeladvisor',filesep,'MA_IR_Data.mat'],fcnName);
    violationObj=[];
    var=eval(fcnName);
    for m=1:length(var)

        [~,name,~]=fileparts(var(m).functionName);
        if strcmp(var(m).functionType,'ship')&&~any(contains(fcnExclusionList,name))&&var(m).functionCC>threshold
            violationObj=ModelAdvisor.ResultDetail;
            funInfo=strsplit(var(m).functionLoc,',');
            funLineInfo=funInfo(contains(funInfo,'line'));
            funLineInfo=strrep(funLineInfo,'line','');
            lnNo=str2double(funLineInfo{1});
            funNameInfo=funInfo(contains(funInfo,'Function'));
            funNameInfo=strsplit(funNameInfo{1});
            filePath=strrep(funNameInfo{2},'''','');
            [~,filePath,~]=fileparts(filePath);

            if strcmp(fcnObj.Name,filePath)

                ModelAdvisor.ResultDetail.setData(violationObj,'Custom',...
                DAStudio.message('ModelAdvisor:hism:himl_0013_Column1'),...
                fcnObj,...
                DAStudio.message('ModelAdvisor:hism:himl_0013_Column2'),...
                name,...
                DAStudio.message('ModelAdvisor:hism:himl_0013_Column3'),...
                num2str(var(m).functionCC));

                violationObj.Status=DAStudio.message('ModelAdvisor:hism:himl_0013_warn',threshold);

            else






                extFilePath=which(filePath);
                if isempty(extFilePath)
                    if checkExt.Value
                        ModelAdvisor.ResultDetail.setData(violationObj,'Custom',...
                        DAStudio.message('ModelAdvisor:hism:himl_0013_Column1'),...
                        fcnObj,...
                        DAStudio.message('ModelAdvisor:hism:himl_0013_Column2'),...
                        name,...
                        DAStudio.message('ModelAdvisor:hism:himl_0013_Column3'),...
                        num2str(var(m).functionCC));
                        violationObj.Status=DAStudio.message('ModelAdvisor:hism:himl_0013_warn',threshold);
                    end
                else
                    ModelAdvisor.ResultDetail.setData(violationObj,'Custom',...
                    DAStudio.message('ModelAdvisor:hism:himl_0013_Column1'),...
                    extFilePath,...
                    DAStudio.message('ModelAdvisor:hism:himl_0013_Column2'),...
                    name,...
                    DAStudio.message('ModelAdvisor:hism:himl_0013_Column3'),...
                    num2str(var(m).functionCC));
                    violationObj.Status=DAStudio.message('ModelAdvisor:hism:himl_0013_warn',threshold);
                end
            end
        end
    end
end

function slObjsCell=getAllMATLABFunctionBlocks_loc(system,FollowLinks,LookUnderMasks)



    slObjsCell=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'SFBlockType','MATLAB Function');
    slObjsCell=slObjsCell(cellfun(@(x)~Advisor.Utils.isChildOfShippingBlock(x),slObjsCell));
end

function[SFCharts]=sfFindSys_loc(system,FollowLinks,LookUnderMasks)



    SFCharts=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'SFBlockType','Chart');

    SFCharts=FilterSFCharts(SFCharts,FollowLinks,LookUnderMasks);
end


function charts=FilterSFCharts(charts,followLinks,lookUnderMask)

    switch lookUnderMask
    case 'none'
        charts=charts(hasMask(charts)==0);
    case 'graphical'
        charts=charts(hasMask(charts)~=2);
    case 'functional'
        charts=charts(hasMask(charts)~=1);
    end

    if strcmp(followLinks,'off')


        charts=charts(cellfun(@(x)~x.isLinked,get_param(charts,'object')));
    end
end

function res=hasMask(charts)
    res=zeros(1,length(charts));
    for i=1:length(charts)
        if Stateflow.SLUtils.isChildOfStateflowBlock(get_param(charts{i},'Handle'))
            res(i)=0;
        else
            res(i)=hasmask(charts{i});
        end
    end
end
