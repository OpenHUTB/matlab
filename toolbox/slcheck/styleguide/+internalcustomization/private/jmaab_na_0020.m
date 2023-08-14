function jmaab_na_0020




    subchecks(1).Type='Normal';
    subchecks(1).subcheck.ID='slcheck.jmaab.na_0020_a';

    rec=slcheck.Check('mathworks.jmaab.na_0020',...
    subchecks,...
    {sg_jmaab_group,sg_maab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;

    inputParamList=rec.setDefaultInputParams();
    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:na_0020_input');
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=false;
    rec.setInputParametersLayoutGrid([1,1]);
    rec.setInputParameters(inputParamList);

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@checkActionCallback);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('ModelAdvisor:jmaab:na_0020_ActionDescription');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);

    rec.register();

end

function ents=getRelevantEntity(system,FL,LUM)

    vss=find_system(system,'FollowLinks',FL,'LookUnderMasks',LUM,'MatchFilter',@Simulink.match.allVariants,'BlockType','SubSystem','Variant','on');


    ents=[];
    for iVSS=1:length(vss)
        vssChoice=find_system(vss(iVSS),'SearchDepth',1,'FollowLinks',FL,'LookUnderMasks',LUM,'MatchFilter',@Simulink.match.allVariants,'regexp','on','BlockType','(SubSystem)|(ModelReference)');
        ents=[ents;get_param(setdiff(vssChoice,vss(iVSS)),'handle')];
    end
end

function result=checkActionCallback(~)
    result=ModelAdvisor.Paragraph;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);
    ch_result=mdladvObj.getCheckResult('mathworks.jmaab.na_0020');


    isValid=true;
    inputParams=mdladvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:jmaab:na_0020_input'));
    inputParams=inputParams.Value;
    inValidObj=[];


    if 2==length(ch_result)
        FailingObjs=ch_result{1}.TableInfo(:,2);
        inValidObj=(ch_result{2}.ListObj)';
    elseif 1==length(ch_result)&&strcmp(ch_result{1}.SubTitle.Content,DAStudio.message('ModelAdvisor:jmaab:na_0020_a_subtitle'))
        FailingObjs=(ch_result{1}.TableInfo(:,2));
    else
        isValid=false;
        inValidObj=ch_result{1}.ListObj;
    end

    if isValid
        if length(FailingObjs)==1


            FailingObjs=FailingObjs{:};
            if iscell(FailingObjs)
                FailingObjs=FailingObjs{:};
            end
            FailingObjs={Simulink.ID.getFullName(FailingObjs)};
        elseif length(FailingObjs)>1
            FailingObjs=cellfun(@(x)x{:},FailingObjs,'UniformOutput',false);
            FailingObjs=Simulink.ID.getFullName(FailingObjs);
        end

        UpdatedList={};
        for n=1:length(FailingObjs)
            addedPort=false;
            isShadowPort=false;

            curBlk=FailingObjs{n};
            if strcmp(get_param(curBlk,'BlockType'),'ModelReference')||~strcmp(get_param(curBlk,'LinkStatus'),'none')...
                ||Stateflow.SLUtils.isStateflowBlock(curBlk)||~isempty(get_param(curBlk,'ReferencedSubsystem'))

                continue
            end

            parentBlk=get_param(curBlk,'Parent');
            inpVSS=find_system(parentBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Inport');
            inpVSS=get_param(inpVSS,'PortName');
            outVSS=find_system(parentBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Outport');
            outVSS=get_param(outVSS,'PortName');



            inpSS=find_system(curBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Inport');
            inpSS=get_param(inpSS,'PortName');
            outSS=find_system(curBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Outport');
            outSS=get_param(outSS,'PortName');



            blkPorts=get_param(curBlk,'Ports');
            if blkPorts(3)||blkPorts(4)
                inpSS=[inpSS;...
                get_param(find_system(curBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','TriggerPort'),'name');...
                get_param(find_system(curBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','EnablePort'),'name')];
            end


            missingPort=setdiff(inpVSS,inpSS);
            posI=[1,1,30,14];
            posT=[300,1,330,14];
            for k=1:length(missingPort)



                if-1~=getSimulinkBlockHandle([curBlk,'/',strrep(missingPort{k},'/','//')])

                    isShadowPort=true;
                    break
                end


                inp=add_block('simulink/Sources/In1',[curBlk,'/',strrep(missingPort{k},'/','//')],'Position',posI+[0,k*100,0,k*100]);


                if strcmp(get_param(curBlk,'Variant'),'off')
                    term=add_block('simulink/Sinks/Terminator',[curBlk,'/',strrep(missingPort{k},'/','//'),'_term'],'Position',posT+[0,k*100,0,k*100]);
                    inp=strrep(get_param(inp,'PortName'),'/','//');
                    term=strrep(get_param(term,'Name'),'/','//');
                    add_line(curBlk,[inp,'/1'],[term,'/1']);
                end
                addedPort=true;

            end


            missingPort=setdiff(outVSS,outSS);
            posO=[500,1,530,14];
            posG=[400,1,430,14];
            for k=1:length(missingPort)



                if~inputParams||strcmp(get_param([curBlk,'/',strrep(missingPort{k},'/','//')],'OutputWhenUnConnected'),'off')

                    out=add_block('simulink/Sinks/Out1',[curBlk,'/',strrep(missingPort{k},'/','//')],'Position',posO+[0,k*50,0,k*50]);


                    if strcmp(get_param(curBlk,'Variant'),'off')&&~Stateflow.SLUtils.isStateflowBlock(curBlk)
                        gnd=add_block('simulink/Sources/Ground',[curBlk,'/',strrep(missingPort{k},'/','//'),'_gnd'],'Position',posG+[0,k*50,0,k*50]);
                        out=strrep(get_param(out,'PortName'),'/','//');
                        gnd=strrep(get_param(gnd,'Name'),'/','//');
                        add_line(curBlk,[gnd,'/1'],[out,'/1']);
                    end
                    addedPort=true;

                end
            end
            if addedPort&&~isShadowPort
                UpdatedList=[UpdatedList;curBlk];
            end

        end

        UnchangedList=setdiff(FailingObjs,UpdatedList);
        if~isempty(UpdatedList)
            parentList=get_param(UpdatedList,'Parent');
            ft=ModelAdvisor.FormatTemplate('TableTemplate');
            ft.setSubBar(0);
            ft.setInformation(DAStudio.message('ModelAdvisor:jmaab:na_0020_Action'));
            ft.setColTitles({DAStudio.message('ModelAdvisor:jmaab:na_0020_a_Col1'),DAStudio.message('ModelAdvisor:jmaab:na_0020_a_Col2')});
            ft.setTableInfo([parentList,UpdatedList]);
            result.addItem(ft.emitContent);
        end
        if~isempty(UnchangedList)
            parentList=get_param(UnchangedList,'Parent');
            ft1=ModelAdvisor.FormatTemplate('TableTemplate');
            ft1.setSubBar(0);
            ft1.setInformation(DAStudio.message('ModelAdvisor:jmaab:na_0020_Action_1'));
            ft1.setColTitles({DAStudio.message('ModelAdvisor:jmaab:na_0020_a_Col1'),DAStudio.message('ModelAdvisor:jmaab:na_0020_a_Col2')});
            ft1.setTableInfo([parentList,UnchangedList]);
            result.addItem(ft1.emitContent);

            ft2=ModelAdvisor.FormatTemplate('ListTemplate');
            ft2.setSubBar(0);
            ft2.setInformation(DAStudio.message('ModelAdvisor:jmaab:na_0020_Action_2'));
            result.addItem(ft2.emitContent)
        end

    end

    if length(inValidObj)>=1
        if length(inValidObj)<2


            inValidObj=cell2mat(inValidObj);
            inValidObj={Simulink.ID.getFullName(inValidObj)};
        else
            inValidObj=Simulink.ID.getFullName(inValidObj);
        end
        ft2=ModelAdvisor.FormatTemplate('ListTemplate');
        ft2.setSubBar(0);
        ft2.setInformation(DAStudio.message('ModelAdvisor:jmaab:na_0020_Invalid_warn'));
        ft2.setListObj(inValidObj);
        result.addItem(ft2.emitContent);
    end

end