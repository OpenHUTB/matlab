function styleguide_jc_0221








    rec=ModelAdvisor.Check('mathworks.maab.jc_0221');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc0221Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc0221Tip');
    rec.setCallbackFcn(@jc_0221_StyleOneCallback,'None','StyleOne');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0221Title';
    rec.SupportLibrary=true;
    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function[ResultDescription]=jc_0221_StyleOneCallback(system)

    feature('scopedaccelenablement','off');
    ResultDescription={};

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);

    followlinkParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.LookUnderMasks');









    deviantSystems={};

    if(sLSGIsModelReference(system)==true)




    else



        blks=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followlinkParam.Value,...
        'LookUnderMasks',lookundermaskParam.Value,...
        'FindAll','on',...
        'Type','block');


        for i=1:length(blks)
            lineHandles=get_param(blks(i),'Linehandles');
            prochandles={};
            if~isempty(lineHandles.Outport)
                idxs=find(lineHandles.Outport~=-1);
                prochandles=lineHandles.Outport(idxs);%#ok<FNDSB>
            end
            if~isempty(prochandles)
                signalName=get_param(prochandles,'Name');
                if~isempty(signalName)
                    if isa(signalName,'cell')
                        for j=1:length(signalName)






                            propName=regexp(signalName{j},'^<(.*)>$','tokens','once');
                            if~isempty(propName)
                                signalName{j}=propName{1};
                            end

                            errStr=isProperName(signalName{j});
                            if~isempty(errStr)


                                node.name=signalName{j};
                                node.errStr=errStr;
                                node.handle=prochandles(j);
                                deviantSystems{end+1}=node;
                            end
                        end
                    else







                        propName=regexp(signalName,'^<(.*)>$','tokens','once');
                        if~isempty(propName)
                            signalName=propName{1};
                        end
                        errStr=isProperName(signalName);
                        if~isempty(errStr)


                            node.name=signalName;
                            node.errStr=errStr;
                            node.handle=prochandles;
                            deviantSystems{end+1}=node;
                        end
                    end
                end
            end
        end
    end
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': jc_0221'];
    ft.setCheckText({DAStudio.message('ModelAdvisor:styleguide:jc0221_Info')});


    if~isempty(deviantSystems)

        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jc0221FailMsg')});
        ft.setRecAction({DAStudio.message('ModelAdvisor:styleguide:jc0221_RecAct')});

        ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:jc0221_Reason'),...
        DAStudio.message('ModelAdvisor:styleguide:jc0221_Link')});

        for i=1:length(deviantSystems)
            col_1=DAStudio.message(['ModelAdvisor:styleguide:',deviantSystems{i}.errStr]);
            col_2=deviantSystems{i}.handle;
            ft.addRow({col_1,col_2});
        end
        modelAdvisorObject.setCheckResultStatus(false);

    else


        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jc0221_Pass')});

        modelAdvisorObject.setCheckResultStatus(true);
    end

    ft.setSubBar(0);
    ResultDescription{end+1}=ft;

end


