function hisl_0070_new

    rec=getNewCheckObject('mathworks.hism.hisl_0070',false,@hCheckAlgo,'None');


    inputParamRowVec=[1,1];

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.setRowSpan(inputParamRowVec);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Name='Check Behavior';
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Entries={DAStudio.message('ModelAdvisor:hism:hisl_0070_mode1'),DAStudio.message('ModelAdvisor:hism:hisl_0070_mode2')};
    inputParamList{end}.Value=DAStudio.message('ModelAdvisor:hism:hisl_0070_mode1');
    inputParamList{end}.Visible=false;


    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamRowVec=inputParamRowVec+1;
    inputParamList{end}.setRowSpan(inputParamRowVec);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:hisl_0070_input_param_1');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='5';
    inputParamList{end}.Visible=false;


    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamRowVec=inputParamRowVec+1;
    inputParamList{end}.setRowSpan(inputParamRowVec);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:hisl_0070_maxChildCountSL');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='100';
    inputParamList{end}.Visible=false;


    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamRowVec=inputParamRowVec+1;
    inputParamList{end}.setRowSpan(inputParamRowVec);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:hisl_0070_maxChildCountSF');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='100';
    inputParamList{end}.Visible=false;


    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamRowVec=inputParamRowVec+1;
    inputParamList{end}.setRowSpan(inputParamRowVec);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:hisl_0070_maxChildCountML');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='200';
    inputParamList{end}.Visible=false;



    inputParamRowVec=inputParamRowVec+1;
    inputParamList=[inputParamList,Advisor.Utils.Eml.getEMLStandardInputParams(inputParamRowVec(1))];


    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamRowVec=inputParamRowVec+[3,8];
    inputParamList{end}.RowSpan=inputParamRowVec;
    inputParamList{end}.ColSpan=[1,8];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:hisl_0070_input_param_3');
    inputParamList{end}.Type='BlockType';
    inputParamList{end}.Value=ModelAdvisor.Common.getExemptBlockList_RequirementLink;
    inputParamList{end}.Visible=false;

    rec.setInputParametersLayoutGrid([inputParamRowVec(2),4]);
    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@inputParamCallBack);

    rec.setLicense({HighIntegrity_License,'Simulink_Requirements'});
    rec.HasANDLicenseComposition=true;

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function inputParamCallBack(taskobj,~,~)


    inParam=taskobj.InputParameters;
    if strcmp(inParam{1}.Value,DAStudio.message('ModelAdvisor:hism:hisl_0070_mode2'))
        inParam{5}.Enable=false;
    else
        inParam{5}.Enable=true;
    end
end

function violations=hCheckAlgo(system)

    Advisor.Utils.LoadLinkCharts(system);

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    [violations,opt]=validateInputs(mdladvObj);
    opt.modelName=bdroot(system);

    if isempty(violations)


        [opt.slHs,opt.sfHs]=Advisor.Utils.Utils_hisl_0070.getHandlesWithRequirements_hisl_0070(system);






        simComponent=mdladvObj.filterResultWithExclusion(Advisor.Utils.Utils_hisl_0070.getSimComponent_hisl_0070(system,opt));
        sfComponent=mdladvObj.filterResultWithExclusion(Advisor.Utils.Utils_hisl_0070.getSFComponent_hisl_0070(simComponent,opt));
        mlComponentBeforeExclusion=Advisor.Utils.Utils_hisl_0070.getMLComponent_hisl_0070(system,opt);
        mlComponent={};
        for i=1:numel(mlComponentBeforeExclusion)

            if isstruct(mlComponentBeforeExclusion{i})
                mlComponent{end+1}=mlComponentBeforeExclusion{i};
            else
                mlComponent{end+1}=mdladvObj.filterResultWithExclusion(mlComponentBeforeExclusion{i});
            end
        end
        if~isempty(simComponent)
            simComponent=get_param(simComponent,'object');
        end

        failingSimObj=Advisor.Utils.Utils_hisl_0070.getFailingSimObj_hisl_0070(simComponent,opt);
        if isempty(sfComponent)
            failingSFObj=[];
        else
            failingSFObj=Advisor.Utils.Utils_hisl_0070.getFailingSFObj_hisl_0070(sfComponent,opt);
        end

        for ii=1:length(failingSFObj)
            if isa(failingSFObj{ii},'Stateflow.Chart')||isa(failingSFObj{ii},'Stateflow.LinkChart')||isa(failingSFObj{ii},'Stateflow.EMChart')
                failingSimObj=failingSimObj(cellfun(@(x)x~=get_param(sfprivate('chart2block',failingSFObj{ii}.Id),'Object'),failingSimObj));
            end
        end




        if opt.link2ContainerOnly
            [failingMLObj,ExceedLinkObjsML,ExceedLoCML]=Advisor.Utils.Utils_hisl_0070.getFailingMLFunctions_hisl_0070(mlComponent,opt,true);
        else
            failingMLObj=[];
            ExceedLinkObjsML=[];
            ExceedLoCML=[];
        end



        if opt.linkCntThreshold~=Inf
            ExceedLinkObjs=mdladvObj.filterResultWithExclusion(GetObjsExceedLinkCount(opt));
        else
            ExceedLinkObjs={};
        end



        if opt.childCntThresholdSL~=Inf
            ExceedChildObjs=mdladvObj.filterResultWithExclusion(GetObjsExceedChildCount(system,opt));
        else
            ExceedChildObjs={};
        end


        violations=loc_makeReport([failingSimObj;failingSFObj],ExceedLinkObjs,ExceedChildObjs,failingMLObj,ExceedLinkObjsML,ExceedLoCML,opt);
    end
end




function[InputOptions,ErrorFields]=loc_validate(modelAdvObj)
    ErrorFields={};

    inputParams=modelAdvObj.getInputParameters;
    InputOptions.link2ContainerOnly=strcmp(inputParams{1}.Value,inputParams{1}.Entries{1});
    InputOptions.lookUnderMask=inputParams{8}.Value;
    InputOptions.followLinks=inputParams{7}.Value;
    InputOptions.externalFile=inputParams{6}.Value;
    InputOptions.excludedBlks=inputParams{9}.Value;
    InputOptions.linkCntThreshold=str2double(inputParams{2}.Value);
    InputOptions.childCntThresholdSL=str2double(inputParams{3}.Value);
    InputOptions.childCntThresholdSF=str2double(inputParams{4}.Value);
    InputOptions.childCntThresholdML=str2double(inputParams{5}.Value);

    if~isnumeric(InputOptions.linkCntThreshold)||InputOptions.linkCntThreshold<=0||isnan(InputOptions.linkCntThreshold)
        ErrorFields=[ErrorFields;'LinkThreshold'];
        InputOptions.linkCntThreshold=inputParams{2}.Value;
    end

    if~isnumeric(InputOptions.childCntThresholdSL)||InputOptions.childCntThresholdSL<=0||isnan(InputOptions.childCntThresholdSL)
        ErrorFields=[ErrorFields;'ChildThreshold'];
        InputOptions.childCntThresholdSL=inputParams{3}.Value;
    end

    if~isnumeric(InputOptions.childCntThresholdSF)||InputOptions.childCntThresholdSF<=0||isnan(InputOptions.childCntThresholdSF)
        ErrorFields=[ErrorFields;'ChildThreshold'];
        InputOptions.childCntThresholdSF=inputParams{4}.Value;
    end

    if~isnumeric(InputOptions.childCntThresholdML)||InputOptions.childCntThresholdML<=0||isnan(InputOptions.childCntThresholdML)
        ErrorFields=[ErrorFields;'ChildThreshold'];
        InputOptions.childCntThresholdML=inputParams{5}.Value;
    end



    if~Advisor.Utils.license('test','Simulink_Requirements')
        ErrorFields=[ErrorFields;'SLReqLicense'];
    end


end

function[violations,opt]=validateInputs(modelAdvObj)
    violations=[];

    [opt,ErrorFields]=loc_validate(modelAdvObj);

    if~isempty(ErrorFields)

        violations=ModelAdvisor.ResultDetail;
        violations.IsInformer=true;
        violations.IsViolation=true;
        ModelAdvisor.ResultDetail.setSeverity(violations,'fail');
        violations.Status=' ';

        if contains(ErrorFields,'SLReqLicense')

            violations.Description=DAStudio.message('ModelAdvisor:hism:hisl_0070_invalid_license');
            violations.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0070_invalid_license_action');

            return;
        end

        errorString={DAStudio.message('ModelAdvisor:hism:hisl_0070_wrong_input_param')};

        for idx=1:length(ErrorFields)
            switch(ErrorFields{idx})
            case 'LinkThreshold'
                errorString{end+1}=DAStudio.message('ModelAdvisor:hism:hisl_0070_invalid_link_threshold',num2str(opt.linkCntThreshold));

            case 'ChildThreshold'
                errorString{end+1}=DAStudio.message('ModelAdvisor:hism:hisl_0070_invalid_child_threshold',num2str(opt.childCntThresholdSL));
            end
        end

        violations.Description=strjoin(errorString,'<br/>');
        violations.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0070_wrong_input_param_action');

    end
end

function violations=loc_makeReport(MissingLinkObjs,ExceedLinkObjs,ExceedChildObjs,MissingLinkObjsML,ExceedLinkObjsML,ExceedLoCML,opt)

    violations=[];

    if~isempty(MissingLinkObjs)
        violations=[violations;Advisor.Utils.createResultDetailObjs(MissingLinkObjs,...
        'Status',DAStudio.message('ModelAdvisor:hism:hisl_0070_warn1'),...
        'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0070_rec_action1_new',opt.modelName))'];
    end

    if~isempty(MissingLinkObjsML)
        violations=[violations;MissingLinkObjsML];
    end






    if~isempty(ExceedLinkObjs)
        violations=[violations;ExceedLinkObjs];
    end

    if~isempty(ExceedChildObjs)
        violations=[violations;ExceedChildObjs];
    end

    if~isempty(ExceedLinkObjsML)
        violations=[violations;ExceedLinkObjsML];
    end

    if~isempty(ExceedLoCML)
        violations=[violations;ExceedLoCML];
    end





end





function violations=GetObjsExceedLinkCount(opt)
    violations=[];
    uniqueContainer=[];

    if isinf(opt.linkCntThreshold)
        return;
    end

    rt=sfroot;

    if~isempty(opt.slHs)||~isempty(opt.sfHs)

        for h=[opt.slHs;opt.sfHs]'
            if~isempty(find(opt.slHs==h,1))
                mdlObj=get_param(h,'Object');
            else
                mdlObj=rt.idToHandle(h);
            end

            if thisOrParentCommented(mdlObj)
                continue;
            end


            isUnique=true;
            if isempty(uniqueContainer)
                uniqueContainer=[uniqueContainer,{Simulink.ID.getSID(mdlObj)}];
            else
                if ismember(Simulink.ID.getSID(mdlObj),uniqueContainer)
                    isUnique=false;
                else
                    uniqueContainer=[uniqueContainer,{Simulink.ID.getSID(mdlObj)}];
                end
            end

            count=length(rmi('get',h));
            if count>opt.linkCntThreshold&&isUnique
                vObj=ModelAdvisor.ResultDetail;
                vObj.Format='Table';
                ModelAdvisor.ResultDetail.setData(vObj,'SID',mdlObj);
                vObj.CustomData={num2str(count)};
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0070_warn2',num2str(opt.linkCntThreshold));
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0070_rec_action2');
                violations=[violations;vObj];%#ok<*AGROW>
            end
        end
    end
end




function violations=GetObjsExceedChildCount(systemH,opt)
    violations=[];

    rt=sfroot;





    if~isempty(opt.slHs)&&~isempty(opt.sfHs)&&rmidata.isExternal(bdroot(systemH))



        opt.slHs=opt.slHs(arrayfun(@(x)~Stateflow.SLUtils.isStateflowBlock(x),opt.slHs));
    end

    if~isinf(opt.childCntThresholdSL)

        for i=1:length(opt.slHs)
            count=0;
            if thisOrParentCommented(opt.slHs(i))
                continue;
            end

            if strcmp(get_param(opt.slHs(i),'type'),'annotation')&&strcmp(get_param(opt.slHs(i),'AnnotationType'),'area_annotation')
                areaPosition=get_param(opt.slHs(i),'Position');
                children=find_system(get_param(opt.slHs(i),'Parent'),'FindAll','on','LookUnderMasks',opt.lookUnderMask,'FollowLinks',opt.followLinks,'SearchDepth',1,'type','block');

                for idx=1:length(children)
                    child=get_param(children(idx),'Object');
                    if isCommented(child)
                        continue;
                    end
                    if~Advisor.Utils.Utils_hisl_0070.isObjExcluded_hisl_0070(child.Handle,opt)
                        blockPosition=child.Position;
                        if blockPosition(:,1)>=areaPosition(1)&&blockPosition(:,3)<=areaPosition(3)&&blockPosition(:,2)>=areaPosition(2)&&blockPosition(:,4)<=areaPosition(4)
                            count=count+1;
                        end
                    end
                end
            elseif strcmp(get_param(opt.slHs(i),'type'),'block_diagram')||(strcmp(get_param(opt.slHs(i),'type'),'block')&&strcmp(get_param(opt.slHs(i),'BlockType'),'SubSystem'))

                children=find_system(opt.slHs(i),'LookUnderMasks',opt.lookUnderMask,'FollowLinks',opt.followLinks,'SearchDepth',1,'type','block');
                children=children(arrayfun(@(x)~isCommented(x),children));
                count=numel(children(arrayfun(@(x)~Advisor.Utils.Utils_hisl_0070.isConditionallyExempt(x,opt),children)));
            end


            if count>opt.childCntThresholdSL
                mdlObj=get_param(opt.slHs(i),'Object');
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',mdlObj);
                vObj.CustomData={num2str(count)};
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0070_warn3_SL',num2str(opt.childCntThresholdSL));
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0070_rec_action3_SL');
                violations=[violations;vObj];
            end
        end
    end

    if~isinf(opt.childCntThresholdSF)

        for i=1:length(opt.sfHs)
            mdlObj=rt.idToHandle(opt.sfHs(i));

            if thisOrParentCommented(mdlObj)
                continue;
            end
            children=mdlObj.getChildren;
            children=children(arrayfun(@(x)~Advisor.Utils.Utils_hisl_0070.isSFObjExcluded_hisl_0070(x,opt,false)&&~isa(x,'Stateflow.Junction'),children));
            children=children(arrayfun(@(x)~isCommented(x),children));
            if length(children)>opt.childCntThresholdSF
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',mdlObj);
                vObj.CustomData={num2str(length(children))};
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0070_warn3_SF',num2str(opt.childCntThresholdSL));
                vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0070_rec_action3_SF');
                violations=[violations;vObj];
            end
        end
    end
end


function res=thisOrParentCommented(obj)
    res=false;

    if isnumeric(obj)
        obj=get_param(obj,'Object');
    end

    while~isa(obj,'Simulink.BlockDiagram')

        if isCommented(obj)
            res=true;
            return;
        end

        obj=obj.getParent;
    end
end

function res=isCommented(obj)
    res=false;

    if isnumeric(obj)
        obj=get_param(obj,'Object');
    end

    if isa(obj,'Simulink.BlockDiagram')
        return;
    end

    if isa(obj,'Stateflow.Object')&&~isa(obj,'Stateflow.Chart')
        if ismethod(obj,'isCommented')&&obj.isCommented
            res=true;
        end
        return;
    end

    if isa(obj,'Stateflow.Chart')
        obj=get_param(obj.Path,'Object');
    end

    if isfield(get(obj),'Commented')&&isequal(obj.Commented,'on')
        res=true;
        return;
    end
end


