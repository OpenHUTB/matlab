function styleguide_na_0037

    rec=ModelAdvisor.Check('mathworks.maab.na_0037');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0037_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0037';
    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:na_0037_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:na_0037_tip')];
    rec.setLicense({styleguide_license});
    rec.Value(true);
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportHighlighting=true;

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);


    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function ResultDescription=checkCallBack(system)
    ResultDescription={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    FailingObjs=checkAlgo(system);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setInformation(DAStudio.message('ModelAdvisor:styleguide:na_0037_tip'));
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:na_0037_TableCol1'),...
    DAStudio.message('ModelAdvisor:styleguide:na_0037_TableCol2'),...
    DAStudio.message('ModelAdvisor:styleguide:na_0037_TableCol3')});
    ft.setSubBar(0);

    if~isempty(FailingObjs)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na_0037_fail'));
        ft.setTableInfo(struct2cell(FailingObjs')');
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:na_0037_recAction'));
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:na_0037_pass'));
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    end

    ResultDescription{end+1}=ft;

end


function FailingObjs=checkAlgo(system)


























    FailingObjs=[];
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

    for i=1:length(allVarSubsys)

        if~isempty(get_param(allVarSubsys{i},'LabelModeActiveChoice'))
            continue;
        end


        if any(strcmp(get_param(allVarSubsys{i},'BlockType'),{'VariantSource','VariantSink'}))
            varnts=get_param(allVarSubsys{i},'VariantControls');
        else
            varnts=get_param(allVarSubsys{i},'variants');
            varnts={varnts.Name};
        end
        hasDefaultVarCond=any(contains(varnts,'(default)'));

        count=0;

        index=[];
        for j=1:length(varnts)

            if~strcmp(varnts{j},'(default)')

                try
                    vc=evalinGlobalScope(system,varnts{j});
                catch
                    vc=[];
                end
                if isa(vc,'Simulink.Variant')
                    conditional=vc.Condition;
                elseif isa(vc,'logical')
                    conditional=varnts{j};
                else


                    temp.Expression=DAStudio.message('ModelAdvisor:styleguide:na_0037_ConditionalError');
                    temp.VariantName=varnts{j};
                    temp.VSS=allVarSubsys{i};
                    FailingObjs=[FailingObjs,temp];%#ok<AGROW>
                    continue;
                end

                mt=mtree(conditional);





                id_nodes=mt.find('Kind','ID','Parent.Kind','CALL');


                varsInCond=unique(id_nodes.stringvals);





                errFlag=false;
                if hasDefaultVarCond
                    if numel(varsInCond)>1
                        errFlag=true;
                    end
                else












                    numRelops=mt.find('Kind',{'EQ','LT','GT','NE','GE','LE'}).count;
                    numLogops=mt.find('Kind',{'ANDAND','AND','OR','OROR'}).count;
                    reloprtree=mt.find('Kind',{'EQ','LT','GT','NE','GE','LE'});

                    condition=regexprep(conditional,varsInCond,'');

                    if numel(varsInCond)>1
                        if numLogops>1
                            errFlag=true;
                        elseif hasSameCondition(reloprtree,numRelops,condition)
                            count=count+1;
                            index=[index,j];%#ok<AGROW> % Add index of variant condition
                            if count>1
                                for k=1:count
                                    temp.Expression=conditional;
                                    if strcmp(varnts{index(k)},conditional)
                                        temp.VariantName='N/A';
                                    else
                                        temp.VariantName=varnts{index(k)};
                                    end
                                    temp.VSS=allVarSubsys{i};
                                    FailingObjs=[FailingObjs,temp];%#ok<AGROW>
                                end
                            end
                        else
                            errFlag=true;
                        end
                    end
                end
                if errFlag
                    temp.Expression=conditional;
                    if strcmp(varnts{j},conditional)
                        temp.VariantName='N/A';
                    else
                        temp.VariantName=varnts{j};
                    end
                    temp.VSS=allVarSubsys{i};
                    FailingObjs=[FailingObjs,temp];%#ok<AGROW>
                end
            end
        end
    end
end

function result=hasSameCondition(reloprtree,numRelops,condition)




    result=false;
    operator=arrayfun(@(x)reloprtree.select(x).kind,reloprtree.indices,'UniformOutput',false);
    operands=arrayfun(@(x)reloprtree.select(x).Right.string,reloprtree.indices,'UniformOutput',false);

    if(numRelops>1)&&(numRelops<3)&&all(strcmp(operator,operator{1}))&&all(strcmp(operands,operands{1}))
        result=true;
    elseif(numRelops>2)

        condition=regexprep(condition,'\s','');
        condexp=regexp(condition,'\&\&|\|\||\&|\|','split');
        if all(strcmp(condexp,condexp{1}))
            result=true;
        end
    end
end