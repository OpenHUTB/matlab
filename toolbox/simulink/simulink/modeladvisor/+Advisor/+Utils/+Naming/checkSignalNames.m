






function[subStatus,subResult,violations]=checkSignalNames(system,regexpSignalNames,prefix,reservedNames,...
    FollowLinks,LookUnderMasks,conventionSignalNames)
    violations=[];

    subStatus=true;

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubBar(false);
    ft.setColTitles({...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Signal'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Name'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Reason')});



    signals=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FindAll','on',...
    'FollowLinks',FollowLinks,...
    'LookUnderMasks',LookUnderMasks,...
    'Type','line');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    signals=mdladvObj.filterResultWithExclusion(signals);


    for index=1:numel(signals)
        thisSignal=signals(index);
        if Advisor.Utils.Naming.verifySignal(thisSignal)
            signalName=get_param(thisSignal,'Name');
            [isValid,issue,reason]=Advisor.Utils.Naming.isNameValid(signalName,regexpSignalNames,...
            reservedNames,prefix,conventionSignalNames);
            if~isValid
                subStatus=false;
                ft.addRow({thisSignal,issue,reason});
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Signal',thisSignal);
                vObj.RecAction=issue;
                violations=[violations;vObj];%#ok<AGROW>
            end
        end
    end


    table=ft.TableInfo;
    if~isempty(table)
        srcHandles=get_param([table{:,1}],'SrcBlockHandle');


        if iscell(srcHandles)
            srcHandles=[srcHandles{:}];
        end
        [~,index]=unique(srcHandles);
        table=table(index,:);
        ft.TableInfo=table;
    end
    subResult=ft;
end

