function hisf_0004




    rec=getNewCheckObject('mathworks.hism.hisf_0004',false,@checkCallback,'CGIR');
    rec.setLicense({HighIntegrity_License,'Stateflow'});
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});
    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';
    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=checkCallback(system)
    checkObject=ModelAdvisor.Common.CodingStandards.FunctionRecursion(...
    system,'RTW:misra:FunctionRecursion_');
    cgirResults=checkObject.algorithm();

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    rt=sfroot;



    charts=find_system(system,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'SFBlockType','Chart');
    chartIDs=cellfun(@(x)rt.idToHandle(sfprivate('block2chart',x)).Id,charts);



    matlabFcnBlks=find_system(system,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'SFBlockType','MATLAB Function');
    matlabFcnBlkIDs=cellfun(@(x)rt.idToHandle(sfprivate('block2chart',x)).Id,matlabFcnBlks);
    flaggedObjs=[];

    sids=getAllSids(cgirResults,inputParams{1}.Value,inputParams{2}.Value);
    for i=1:numel(sids)
        obj=Simulink.ID.getHandle(sids(i));
        if isnumeric(obj)
            obj=rt.idToHandle(sfprivate('block2chart',obj));
        end

        if strcmpi(obj.getSFBlockType,'MATLAB Function')
            if~any(ismember(matlabFcnBlkIDs,obj.Id))
                continue;
            end
        elseif isa(obj,'Stateflow.Chart')
            if~any(ismember(chartIDs,obj.Id))
                continue;
            end
        elseif~any(ismember(chartIDs,obj.Chart.Id))
            continue;
        end
        flaggedObjs=[flaggedObjs;mdladvObj.filterResultWithExclusion(obj)];
    end


    flaggedObjs=unique(flaggedObjs,'stable');
    violations=[];
    for i=1:numel(flaggedObjs)
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',flaggedObjs(i));
        violations=[violations;vObj];
    end
end

function allSids=getAllSids(cgirResults,FollowLinks,LookUnderMasks)
    sids=[];


    for i=1:numel(cgirResults)
        sid=cgirResults(i).uuid.sid;
        for j=1:numel(sid)
            if isequal(sid(j).Content,'<br/>')
                continue;
            end
            sids=[sids;string(sid(j).Content)];
        end
    end







    reuseInfo=get_param(bdroot,'CodeReuseDiagnostics');
    allSids=sids;
    rt=sfroot;













    for i=1:length(sids)
        sid=sids(i);
        obj=Simulink.ID.getHandle(sid);
        if isnumeric(obj)
            obj=rt.idToHandle(sfprivate('block2chart',obj));
        end


        if isa(obj,'Stateflow.Transition')||isa(obj,'Stateflow.Function')...
            ||isa(obj,'Stateflow.TruthTable')||isa(obj,'Stateflow.EMFunction')...
            ||isa(obj,'Stateflow.Chart')||isa(obj,'Stateflow.State')
            reuseFlag='';


            parent=obj;
            while~isa(parent,'Stateflow.Chart')
                parent=parent.getParent;
            end
            parentPath=parent.Path;


            for j=1:length(reuseInfo)
                object=Simulink.ID.getHandle(reuseInfo(j).BlockSID);
                if isnumeric(object)
                    num=object;

                    object=rt.idToHandle(sfprivate('block2chart',object));

                    if isempty(object)
                        object=get_param(num,'Object');
                    end
                end
                if strcmp(parentPath,object.Path)
                    reuseFlag=reuseInfo(j).ReuseFlag;
                    break;
                end
            end


            for j=1:length(reuseInfo)
                chart=Simulink.ID.getHandle(reuseInfo(j).BlockSID);
                if isnumeric(chart)
                    chart=rt.idToHandle(sfprivate('block2chart',chart));
                end

                if~isa(chart,'Stateflow.Chart')
                    continue;
                end
                if strcmp(reuseInfo(j).ReuseFlag,reuseFlag)

                    if isa(obj,'Stateflow.Chart')
                        allSids=[allSids;reuseInfo(j).BlockSID];
                        continue;
                    end
                    sfElements=chart.find('-isa','Stateflow.Transition','-or','-isa','Stateflow.Function'...
                    ,'-or','-isa','Stateflow.TruthTable','-or','-isa','Stateflow.EMFunction'...
                    ,'-or','-isa','Stateflow.State');

                    for k=1:length(sfElements)
                        if~isempty(obj.LabelString)&&strcmp(obj.LabelString,sfElements(k).LabelString)
                            allSids=[allSids;Simulink.ID.getSID(sfElements(k))];
                        end


                        if isa(obj,'Stateflow.Transition')&&Advisor.Utils.Stateflow.isDefaultTransition(obj)...
                            &&isa(sfElements(k),'Stateflow.Transition')&&Advisor.Utils.Stateflow.isDefaultTransition(sfElements(k))
                            allSids=[allSids;Simulink.ID.getSID(sfElements(k))];
                        end
                    end
                end
            end
        end

        if strcmpi(obj.getSFBlockType,'MATLAB Function')


            mlfbs=find_system(bdroot,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'SFBlockType','MATLAB Function');
            mlfbs=mlfbs(cellfun(@(x)~Advisor.Utils.isChildOfShippingBlock(x),mlfbs));
            mlfbs=cellfun(@(x)idToHandle(sfroot,sfprivate('block2chart',get_param(x,'handle'))),mlfbs,'UniformOutput',false);

            for i=1:numel(mlfbs)

                if strcmp(regexprep(obj.Script,'[\n\r\s]+',''),regexprep(mlfbs{i}.Script,'[\n\r\s]+',''))
                    allSids=[allSids;Simulink.ID.getSID(mlfbs{i})];
                end
            end
        end
    end
end
