function violations=checkSignalPropagation(system,isjmaab)




    violations=[];

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    FL=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LUM=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');



    allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FL.Value,'LookUnderMasks',LUM.Value,'Type','block','BlockType','Inport');
    allBlocks=mdlAdvObj.filterResultWithExclusion(allBlocks);

    for i=1:length(allBlocks)
        lh=get_param(allBlocks{i},'LineHandles');
        if lh.Outport==-1
            continue;
        end
        lobj=get_param(lh.Outport,'Object');
        if~isempty(lobj)
            if strcmp(get_param(allBlocks{i},'Parent'),bdroot(system))~=1

                if~isempty(lobj.Name)



                    if strcmp(lobj.signalPropagation,'off')
                        parentBlock=get_param(allBlocks{i},'Parent');
                        parentLinkStatus=get_param(parentBlock,'LinkStatus');
                        if isParentSubSystemInStateflow(allBlocks{i})

                        elseif strcmp(parentLinkStatus,'resolved')

                        else
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'Signal',lobj.Handle);
                            vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0009_warn1');
                            vObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:na_0009_rec_action1');
                            violations=[violations;vObj];%#ok<AGROW>
                        end
                    end
                else

                    if~strcmp(lobj.signalPropagation,'off')
                        propSignals=get_param(lobj.SrcPortHandle,'PropagatedSignals');
                        if isempty(propSignals)
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'Signal',lobj.Handle);
                            vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0009_warn2');
                            vObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:na_0009_rec_action2');
                            violations=[violations;vObj];%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end





    allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FL.Value,'LookUnderMasks',LUM.Value,'Type','block','BlockType','SubSystem');
    allBlocks=setdiff(allBlocks,system);
    allBlocks=mdlAdvObj.filterResultWithExclusion(allBlocks);

    ports=get_param(allBlocks,'Ports');

    for i=1:length(allBlocks)

        if strcmp(get_param(allBlocks{i},'LinkStatus'),'resolved')~=1
            lh=get_param(allBlocks{i},'LineHandles');
            for j=1:ports{i}(2)
                if(lh.Outport(j)~=-1)
                    allsinks=get_param(lh.Outport(j),'DstPortHandle');
                    hiliteHandle=get_param(lh.Outport(j),'Handle');
                    if(isempty(allsinks)~=0)||(isempty(find(allsinks==-1,1))~=0)
                        lh_obj=get_param(lh.Outport(j),'Object');

                        if~isempty(lh_obj.Name)


                            if strcmp(lh_obj.signalPropagation,'off')==1
                                vObj=ModelAdvisor.ResultDetail;
                                ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                                vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0009_warn3');
                                vObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:na_0009_rec_action3');
                                violations=[violations;vObj];%#ok<AGROW>
                            end
                        else
                            if strcmp(lh_obj.signalPropagation,'off')~=1
                                propSignals=get_param(lh_obj.SrcPortHandle,'PropagatedSignals');
                                if isempty(propSignals)
                                    vObj=ModelAdvisor.ResultDetail;
                                    ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                                    vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0009_warn4');
                                    vObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:na_0009_rec_action4');
                                    violations=[violations;vObj];%#ok<AGROW>
                                end
                            end
                        end
                    end
                end
            end
        end
    end





    if~isjmaab
        nonXformBlockTypes={...
        'Inport',...
        'InportShadow',...
        'SubSystem',...
        'From',...
        };
    else
        nonXformBlockTypes={...
        'Inport',...
        'InportShadow',...
        'SubSystem',...
        'From',...
        'FunctionCallSplit',...
        'SignalSpecification',...
        };
    end



    lineSegs=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FL.Value,'LookUnderMasks',LUM.Value,'FindAll','on','Type','line');
    lineObjs=get_param(lineSegs,'Object');

    if~iscell(lineObjs)
        lineObjs={lineObjs(:)};
    end
    for i=1:length(lineObjs)
        hiliteHandle=lineObjs{i}.Handle;

        if lineObjs{i}.SrcBlockHandle~=-1
            blkType=get_param(lineObjs{i}.SrcBlockHandle,'BlockType');
            if isempty(strmatch(blkType,nonXformBlockTypes))


                if strcmp(lineObjs{i}.signalPropagation,'off')~=1
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                    vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0009_warn5');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:na_0009_rec_action5');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            else


                if strcmp(blkType,'Inport')~=1&&strcmp(blkType,'SubSystem')~=1&&strcmp(blkType,'From')~=1

                    if strcmp(lineObjs{i}.signalPropagation,'off')==1

                        if~isempty(lineObjs{i}.Name)
                            vObj=ModelAdvisor.ResultDetail;
                            ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                            vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0009_warn6');
                            vObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:na_0009_rec_action6');
                            violations=[violations;vObj];%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end

end

function result=isParentSubSystemInStateflow(blockPath)
    blockObject=get_param(blockPath,'Object');
    parentSubSystem=blockObject.getParent;
    parentOfSubSystem=parentSubSystem.getParent;
    className=class(parentOfSubSystem);
    if strncmp(className,'Stateflow.',10)
        result=true;
    else
        result=false;
    end
end
