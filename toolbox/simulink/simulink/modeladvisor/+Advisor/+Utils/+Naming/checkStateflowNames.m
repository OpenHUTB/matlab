






function[subStatus,subResult,violations]=checkStateflowNames(system,regexpStateflowNames,...
    prefix,reservedNames,conventionStateflowNames)
    violations=[];

    subStatus=true;

    findArgs={...
    '-isa','Stateflow.State','-or',...
    '-isa','Stateflow.EMFunction','-or',...
    '-isa','Stateflow.Function','-or',...
    '-isa','Stateflow.SLFunction','-or',...
    '-isa','Stateflow.Box','-or',...
    '-isa','Stateflow.Data','-or',...
    '-isa','Stateflow.Event','-or',...
    '-isa','Stateflow.TruthTable'};

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubBar(false);
    ft.setColTitles({...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Stateflow'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Name')...
    ,Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Reason')});

    systemObject=get_param(system,'Object');
    modelObjects=systemObject.find(findArgs{:});



    linkCharts=systemObject.find('-isa','Stateflow.LinkChart');
    sfObjects=cell(size(linkCharts));
    sfPaths=cell(size(linkCharts));
    for index=1:length(linkCharts)
        lcHndl=sf('get',linkCharts(index).Id,'.handle');
        cId=sfprivate('block2chart',lcHndl);
        sfObjects{index}=idToHandle(sfroot,cId);
        sfPaths{index}=sfObjects{index}.Path;
    end
    [~,filter]=unique(sfPaths);
    sfObjects=sfObjects(filter);

    libraryObjects=[];
    for index=1:length(sfObjects)
        thisObject=sfObjects{index};
        newObjects=thisObject.find(findArgs{:});
        libraryObjects=[libraryObjects;newObjects];%#ok<AGROW>
    end

    allObjects=[modelObjects;libraryObjects];


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    allObjects=mdladvObj.filterResultWithExclusion(allObjects);

    for index=1:numel(allObjects)
        thisObject=allObjects(index);




        if isa(thisObject,'Stateflow.TruthTable')
            if isa(thisObject.getParent(),'Stateflow.TruthTableChart')
                continue;
            end
        end
        thisName=thisObject.Name;
        [isValid,issue,reason]=Advisor.Utils.Naming.isNameValid(thisName,regexpStateflowNames,...
        reservedNames,prefix,conventionStateflowNames);
        if~isValid
            subStatus=false;
            ft.addRow({thisObject,issue,reason});
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',thisObject);
            vObj.RecAction=issue;
            violations=[violations;vObj];%#ok<AGROW>
        end
    end

    subResult=ft;
end


