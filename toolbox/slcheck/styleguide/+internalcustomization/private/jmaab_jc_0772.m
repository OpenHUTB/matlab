function jmaab_jc_0772

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0772');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0772_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0772';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0772',@hCheckAlgo),'None','DetailStyle');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0772_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0772_tip')];
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;

    sfJunctionStates=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,...
    {'-isa','Stateflow.Junction','-or','-isa','Stateflow.State','-or','-isa','Stateflow.SimulinkBasedState'},true);
    sfJunctionStates=mdlAdvObj.filterResultWithExclusion(sfJunctionStates);

    for i=1:length(sfJunctionStates)
        sourcedTxns=getSourcedTransitions(sfJunctionStates{i});
        numSrcTxns=numel(sourcedTxns);
        if numSrcTxns==1
            continue;
        end

        if isa(sfJunctionStates{i},'Stateflow.State')
            numInternalTxns=sum(arrayfun(@(x)x.Source==sfJunctionStates{i}&&x.Destination.getParent==sfJunctionStates{i},sourcedTxns));
            numExternalTxns=numSrcTxns-numInternalTxns;

            for j=1:numSrcTxns
                if sourcedTxns(j).Source==sfJunctionStates{i}&&sourcedTxns(j).Destination.getParent==sfJunctionStates{i}
                    threshold=numInternalTxns;
                else
                    threshold=numExternalTxns;
                end
                if sourcedTxns(j).ExecutionOrder~=threshold&&...
                    hasNoCondition(sourcedTxns(j).LabelString)
                    FailingObjs{end+1}=sourcedTxns(j);%#ok<AGROW>
                end
            end
        else
            for j=1:numSrcTxns
                if sourcedTxns(j).ExecutionOrder~=numSrcTxns&&...
                    hasNoCondition(sourcedTxns(j).LabelString)
                    FailingObjs{end+1}=sourcedTxns(j);%#ok<AGROW>
                end
            end
        end
    end


    defTrans=Advisor.Utils.Stateflow.sfFindSys(system,'on','graphical',{'-isa','Stateflow.Transition','-and','Source',[]},true);
    if isempty(defTrans)
        return;
    end


    [uniqueSet,~,groupIndices]=unique(cellfun(@(x)x.getParent.getFullName,defTrans,'UniformOutput',false));
    for i=1:length(uniqueSet)
        txnSet=defTrans(groupIndices==i);
        for j=1:length(txnSet)
            if txnSet{j}.ExecutionOrder~=length(txnSet)&&...
                hasNoCondition(txnSet{j}.LabelString)
                FailingObjs{end+1}=txnSet{j};%#ok<AGROW>
            end
        end
    end

end

function srcdTxns=getSourcedTransitions(sf_obj)
    if isa(sf_obj,'Stateflow.SimulinkBasedState')
        prt=sf_obj.Chart;
        srcdTxns=prt.find('-isa','Stateflow.Transition','Source',sf_obj);
    else
        srcdTxns=sf_obj.sourcedTransitions;
    end
end

function bCondition=hasNoCondition(transition_label)

    label_split=regexp(transition_label,'\n','split');




    expressionComment='^%.*|(\/\*)+.*(\*\/)+|(\/\/)+.*';
    comment_filtered=cellfun(@(x)regexprep(x,expressionComment,''),label_split,'UniformOutput',false);
    comment_filtered=comment_filtered(cellfun(@(x)~isempty(x),comment_filtered));
    comment_filtered=strjoin(comment_filtered,'\n');

    expressionAction='\s*{.*}\s*';
    action_filtered=regexprep(comment_filtered,expressionAction,'');

    bCondition=isempty(action_filtered);
end
