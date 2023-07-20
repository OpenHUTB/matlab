function styleguide_na_0036()

    rec=ModelAdvisor.Check('mathworks.maab.na_0036');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0036_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0036';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:styleguide:na_0036',@checkAlgo),'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:na_0036_tip');
    rec.setLicense({styleguide_license});
    rec.Value(true);
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportHighlighting=true;


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

    rec.loadOutofdateInputParametersCallback=@loadOutofdateInputParametersCallback;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function FailingObjs=checkAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    commonArgs={'LookUnderMasks',inputParams{2}.Value,...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks',inputParams{1}.Value};
    vss=find_system(system,commonArgs{:},'BlockType','SubSystem','Variant','on');
    vsrc=find_system(system,commonArgs{:},'BlockType','VariantSource');
    vsin=find_system(system,commonArgs{:},'BlockType','VariantSink');
    vmr=find_system(system,commonArgs{:},'BlockType','ModelReference','Variant','on');
    allVarSubsys=mdladvObj.filterResultWithExclusion([vss;vsrc;vsin;vmr]);

    flag=false(1,length(allVarSubsys));
    for i=1:length(allVarSubsys)
        if~hasDefaultVariant(allVarSubsys{i})
            flag(i)=true;
        end
    end

    recActionMsg=DAStudio.message('ModelAdvisor:styleguide:na_0036_recAction');
    FailingObjs=Advisor.Utils.createResultDetailObjs(allVarSubsys(flag),...
    'RecAction',recActionMsg);
end


function bResult=hasDefaultVariant(VarSubsys)

    bResult=false;


    isVarSrcSnk=any(strcmp(get_param(VarSubsys,'BlockType'),{'VariantSource','VariantSink'}));

    if isVarSrcSnk


        varnts=get_param(VarSubsys,'VariantControls');

        variantMode=get_param(VarSubsys,'VariantControlMode');

        if~(strcmpi(variantMode,'label')||...
            any(contains(varnts,'(default)')))&&...
...
            strcmp(get_param(VarSubsys,'AllowZeroVariantControls'),'on')
            bResult=false;
        elseif strcmpi(variantMode,'label')||...
...
            any(contains(varnts,'(default)'))
            bResult=true;

        elseif areAllConditionsCovered(varnts,VarSubsys)
            bResult=true;
        end
    else





        varnts=get_param(VarSubsys,'variants');


        if isempty(varnts)
            bResult=false;
            return;
        end

        varnts={varnts.Name};

        variantMode=get_param(VarSubsys,'VariantControlMode');

        defVrnt=contains(varnts,'(default)');

        noOfDefVar=numel(find(defVrnt));

        if~(strcmpi(variantMode,'label')||...
            (noOfDefVar>0))&&...
...
            strcmp(get_param(VarSubsys,'AllowZeroVariantControls'),'on')
            bResult=false;

        elseif(strcmpi(variantMode,'label')&&(noOfDefVar<2))
            bResult=true;

        elseif(~(strcmpi(variantMode,'label'))&&(noOfDefVar==1))
            bResult=true;

        elseif areAllConditionsCovered(varnts,VarSubsys)
            bResult=true;
        end
    end
end



function bResult=areAllConditionsCovered(varnts,obj)
    bResult=false;
    conditions=[];
    for j=1:length(varnts)


        try
            vc=evalinGlobalScope(bdroot(obj),varnts{j});
        catch
            vc=[];
        end

        if isa(vc,'Simulink.Variant')
            conditions{j}=vc.Condition;%#ok<AGROW>
        elseif isa(vc,'logical')
            conditions{j}=varnts{j};%#ok<AGROW>
        end
    end
    if~isempty(conditions)

        conditions=conditions(cellfun(@(x)~isempty(x),conditions));

        combinedExpr=strcat(conditions,'||');
        combinedExpr=regexprep([combinedExpr{:}],'\|\|$','');



        if isempty(slInternal('SimplifyVarCondExpr',combinedExpr))
            bResult=true;
        end
    end
end


function status=loadOutofdateInputParametersCallback(configUIObj)
    status=false;


    if numel(configUIObj.InputParameters)==3&&configUIObj.InputParameters{1}.Value==false
        configUIObj.InputParameters=configUIObj.InputParameters(2:3);
        status=true;
    end
end