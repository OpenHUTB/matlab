






function[ResultDescription]=checkVariantOverride(system)

    ResultDescription={};


    systemH=get_param(system,'Handle');
    vssH=find_system(systemH,'LookUnderMasks','on','FollowLinks','on','MatchFilter',@Simulink.match.allVariants,'BlockType','SubSystem','Variant','on');
    vmrH=find_system(systemH,'LookUnderMasks','on','FollowLinks','on','MatchFilter',@Simulink.match.allVariants,'BlockType','ModelReference','Variant','on');
    vsrcH=find_system(systemH,'LookUnderMasks','on','FollowLinks','on','MatchFilter',@Simulink.match.allVariants,'BlockType','VariantSource');
    vsinH=find_system(systemH,'LookUnderMasks','on','FollowLinks','on','MatchFilter',@Simulink.match.allVariants,'BlockType','VariantSink');
    allH=[vssH;vmrH;vsrcH;vsinH];


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(systemH);
    allH=mdladvObj.filterResultWithExclusion(allH);

    variantOverrideBlks=[];
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setInformation(DAStudio.message('Simulink:tools:MATitletipCheckVariantOverride'));
    ft.setSubBar(0);


    if~isempty(allH)


        allOverride=get_param(allH,'LabelModeActiveChoice');
        if~iscell(allOverride)
            allOverride={allOverride};
        end
        idx=~strcmp(allOverride,'');
        variantOverrideBlks=allH(idx);
    end

    info={};





    if~isempty(variantOverrideBlks)

        for i=1:length(variantOverrideBlks)
            variants={};
            evalInGlobalWS={};
            block=variantOverrideBlks(i);



            if(strcmp(get_param(block,'BlockType'),'VariantSource')||strcmp(get_param(block,'BlockType'),'VariantSink'))
                varObjs=get_param(variantOverrideBlks(i),'VariantControls');
                for ii=1:length(varObjs)
                    object=char(varObjs(ii));

                    if IsValidToEvalVariantControl(object)
                        variants{end+1}={object};
                    end
                end
            else



                varObjs=get_param(variantOverrideBlks(i),'Variants');






                for ii=1:length(varObjs)
                    object=varObjs(ii).Name;

                    if IsValidToEvalVariantControl(object)
                        variants{end+1}={object};
                    end
                end

            end


            for j=1:length(variants)
                objects=char(variants{j});


                Model=bdroot(systemH);
                isVarObj=existsInGlobalScope(Model,objects);



                if isVarObj

                    if evalinGlobalScope(systemH,['isa(',objects,', ''Simulink.Variant'');'])
                        objects=evalinGlobalScope(systemH,[objects,'.Condition']);
                    end
                end

                try





                    if~isempty(objects)
                        val=slInternal('evalSimulinkBooleanExprInGlobalScopeWS',systemH,objects);
                        evalInGlobalWS=[evalInGlobalWS;islogical(val)];
                    end
                catch


                    evalInGlobalWS=[evalInGlobalWS;0];
                end

            end



            if sum([evalInGlobalWS{:}])>0
                info=[info;{block,get_param(block,'LabelModeActiveChoice')}];
            end
        end
    end




    if~isempty(variantOverrideBlks)&&~isempty(info)
        ft.setColTitles({DAStudio.message('Simulink:tools:VariantBlocks'),...
        DAStudio.message('Simulink:tools:CurrentOverrideSetting')});

        ft.setTableInfo(info);
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultCheckVariantOverride'));
        ft.setRecAction(DAStudio.message('Simulink:tools:MASubResultStatusVariantOverride'));
        mdladvObj.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MAVariantOverrideCheckPassed'));
        mdladvObj.setCheckResultStatus(true);
    end

    ResultDescription{end+1}=ft;
end









function[isValid]=IsValidToEvalVariantControl(variant)

    isValid=true;



    if(isvarname(strtrim(variant)))
        return;
    end


    if isempty(variant)
        isValid=false;
        return;
    end


    if strfind(strtrim(variant),'%')==1
        isValid=false;
        return;
    end



    defVariantKeyword='(default)';
    if strcmp(defVariantKeyword,variant)
        isValid=false;
    end
end
