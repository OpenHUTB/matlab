function constructReplacementModel(obj,~)




    replacementMdlParams.('InheritedTsInSrcMsg')='none';
    replacementMdlParams.('RecordCoverage')='off';
    replacementMdlParams.('StrictBusMsg')='ErrorLevel1';
    replacementMdlParams.('SaveWithParameterizedLinksMsg')='none';
    replacementMdlParams.('SaveFormat')='StructureWithTime';
    replacementMdlParams.('SaveTime')='off';
    replacementMdlParams.('SaveOutput')='off';
    replacementMdlParams.('SaveState')='off';
    replacementMdlParams.('SaveFinalState')='off';
    replacementMdlParams.('MinMaxOverflowLogging')='ForceOff';

    replacementMdlParams=sldvprivate('get_single_tasking_params',obj.ModelH,replacementMdlParams);

    genCopyModel=false;

    if~obj.MdlInlinerOnlyMode

        [~,modelObjSrcCS]=sldvshareprivate('mdl_get_configset',obj.ModelH);
        if~strcmpi(get_param(modelObjSrcCS,'ConcurrentTasks'),'on')





            activeRules=obj.AllActiveRules;
            BlockTypesActiveRules=cell(length(activeRules),1);
            anyCustomReplacementRule=false;
            for idx=1:length(activeRules)
                currentRule=activeRules{idx};
                BlockTypesActiveRules{idx}=currentRule.BlockType;
                anyCustomReplacementRule=anyCustomReplacementRule|~currentRule.IsBuiltin;
            end

            if Simulink.internal.useFindSystemVariantsMatchFilter()
                opts={'FollowLinks','on','LookUnderMasks','all','MatchFilter',@Simulink.match.activeVariants};
            else
                opts={'FollowLinks','on','LookUnderMasks','all'};
            end

            aBlks=find_system(obj.ModelH,opts{:});
            aBlks(1)=[];

            if anyCustomReplacementRule





                genCopyModel=true;
                obj.AutoRepRuleForSubSystemWillWork=true;
            else



                ModelName=get_param(obj.ModelH,'Name');
                mdlBlks=Sldv.utils.findModelBlocks(ModelName);

                if~isempty(mdlBlks)&&...
                    any(strcmp('ModelReference',BlockTypesActiveRules))
                    genCopyModel=true;


                    replacementMdlParams.('BusObjectLabelMismatch')='error';
                else


                    aBlkTypes=get_param(aBlks,'BlockType');
                    for idx=1:length(BlockTypesActiveRules)
                        matchedBlockIdx=strcmp(BlockTypesActiveRules{idx},aBlkTypes);
                        if any(matchedBlockIdx)
                            blockreprule=activeRules{idx};
                            matchedBlocks=aBlks(matchedBlockIdx);
                            for jdx=1:length(matchedBlocks)
                                blockH=get_param(matchedBlocks(jdx),'Handle');
                                try




                                    genCopyModel=blockreprule.IsReplaceableCallBack(blockH);
                                    if genCopyModel&&...
                                        blockreprule.IsAuto&&...
                                        strcmp(blockreprule.BlockType,'SubSystem')
                                        obj.AutoRepRuleForSubSystemWillWork=true;
                                    end
                                catch Mex %#ok<NASGU>




                                    genCopyModel=true;
                                end
                                if genCopyModel
                                    break;
                                end
                            end
                        end
                        if genCopyModel
                            break;
                        end
                    end
                end
            end
        end

        if genCopyModel&&~obj.BlockReplacementsEnforced&&...
            (contains(get(obj.SldvOptConfig,'OutputDir'),'/')&&...
            strcmp(strtrim(get(obj.SldvOptConfig,'OutputDir')),'.'))
            currentOpts=obj.SldvOptConfig;
            obj.SldvOptConfig=currentOpts.deepCopy;
            set(obj.SldvOptConfig,'OutputDir','sldv_output/$ModelName$');
        end

        obj.RepMdlGenerated=genCopyModel;

        obj.MdlInfo=Sldv.xform.RepMdlInfo(obj.ModelH,...
        [obj.MdlRefBlkRepRulesTree,obj.SubSystemRepRulesTree,obj.BuiltinBlkRepRulesTree],...
        obj.RepMdlGenerated,false,obj.SldvOptConfig,replacementMdlParams);

    else

        obj.RepMdlGenerated=true;
        repRules=obj.MdlRefBlkRepRulesTree;

        obj.MdlInfo=Sldv.xform.RepMdlInfo(obj.ModelH,repRules,obj.InlinerOrigMdlH);

    end


    if obj.RepMdlGenerated
        sldvcc=sldvprivate('configcomp_get',obj.MdlInfo.ModelH);
        if~isempty(sldvcc)
            set_param(obj.MdlInfo.ModelH,'DVBlockReplacement','off');
        end
        if obj.IsReplacementForAnalysis

            add_param(obj.MdlInfo.ModelH,'DVDesignModelName',...
            get_param(obj.MdlInfo.OrigModelH,'Name'));
            testcomp=obj.MdlInfo.TestComp;
            logStr=getString(message('Sldv:Analyzer:PreprocessingModel'));
            logStr=sprintf('\n%s',logStr);
            if isa(testcomp.progressUI,'AvtUI.Progress')
                testcomp.progressUI.showLogArea();
                testcomp.progressUI.appendToLog(logStr);
            elseif~sldvshareprivate('util_is_analyzing_for_fixpt_tool')...
                &&~ModelAdvisor.isRunning
                fprintf(1,logStr);
            end
            testcomp.resolvedSettings.BlockReplacementModelFileName=...
            get_param(obj.MdlInfo.ModelH,'FileName');
        end
    end
end
