function[classList,defItemIndx]=findValidClasses(class,selVar,index)




    typeNames={
'Parameter'
'Signal'
'LookupTable'
    };

    baseClassNames={
'Simulink.Parameter'
'Simulink.Signal'
'Simulink.LookupTable'
'Simulink.Breakpoint'
    };

    defItemIndx=0;

    if(nargin==1)&&(isequal(class,'InitializePreferenceSettings'))
        classList=l_AddCustomObjectClassesToSetting;
        return;
    end

    allClasses=get_param(0,'CustomObjectClasses');


    if isempty(allClasses.(typeNames{1}))||isempty(allClasses.(typeNames{2}))||~isfield(allClasses,typeNames{3})
        slsettings=l_GetSimulinkSettings;
        allClasses=l_ResetCustomObjectListInSetting(slsettings);
        set_param(0,'CustomObjectClasses',allClasses);
    end

    switch nargin


    case 1

        classList=allClasses.(class)(1:end-1);
        defItemIndx=str2double(allClasses.(class){end});

    case 2

        if iscell(selVar)
            setList(allClasses,class,selVar,0);


        elseif isnumeric(selVar)
            setList(allClasses,class,allClasses.(class)(1:end-1),selVar);
        end


    case 3
        setList(allClasses,class,selVar,index);




    case 0
        newListStruct=struct;

        globalWS=true;
        allClasses=find_valid_user_classes(true,globalWS);
        lutIndex=ismember(typeNames,'LookupTable');
        newListStruct.(typeNames{lutIndex})=[];

        for i=1:numel(baseClassNames)
            if~(isequal(baseClassNames{i},'Simulink.LookupTable')||...
                isequal(baseClassNames{i},'Simulink.Breakpoint'))

                newListStruct.(typeNames{i})=...
                filterClassList(allClasses,baseClassNames{i});
                sort(newListStruct.(typeNames{i}));
            else
                newListStruct.(typeNames{lutIndex})=...
                [newListStruct.(typeNames{lutIndex})...
                ,filterClassList(allClasses,baseClassNames{i})];
            end
        end
        classList=newListStruct;
    end

end



function setList(listStruct,class,newList,default)

    newList{end+1}=num2str(default);
    listStruct.(class)=newList;
    saveList(listStruct);
end


function saveList(objectClassList)

    set_param(0,'CustomObjectClasses',objectClassList);
    p=Simulink.Preferences.getInstance;
    p.Save;

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('DataObjectListChangedEvent',[],'AllList');
end


function outList=filterClassList(allClassNames,baseClass)


    outList={};
    for pIdx=1:length(allClassNames)
        clsPkgName=strsplit(allClassNames{pIdx},'.');
        pkgName=clsPkgName{1};
        clsName=clsPkgName{2};
        hPackage=meta.package.fromName(pkgName);
        hClass=Simulink.data.findClass(hPackage,clsName);
        try
            if Simulink.data.isDerivedFrom(hClass,baseClass)
                outList{end+1,1}=allClassNames{pIdx};%#ok
            end
        catch X
            disp(X.message)
        end
    end
end


function defList=l_GetDefaultList
    defaultParameterList={'Simulink.Parameter','0'};
    defaultSignalList={'Simulink.Signal','0'};
    defaultLookupTableList={'Simulink.LookupTable','Simulink.Breakpoint','0'};
    defList=struct;
    defList.Parameter=defaultParameterList;
    defList.Signal=defaultSignalList;
    defList.LookupTable=defaultLookupTableList;
end


function slSettings=l_GetSimulinkSettings


    s=matlab.settings.internal.settings;
    if~s.hasGroup('Simulink')
        s.addGroup('Simulink');
    end
    slSettings=s.Simulink;
end


function defList=l_ResetCustomObjectListInSetting(slSettings,groupSetting)



    paramName='CustomObjectClasses';
    defList=l_GetDefaultList;




    if nargin==1
        slSettings.(paramName).('Parameter').PersonalValue={};
        slSettings.(paramName).('Parameter').PersonalValue=defList.Parameter;

        slSettings.(paramName).('Signal').PersonalValue={};
        slSettings.(paramName).('Signal').PersonalValue=defList.Signal;

        slSettings.(paramName).('LookupTable').PersonalValue={};
        slSettings.(paramName).('LookupTable').PersonalValue=defList.LookupTable;

    elseif nargin==2
        slSettings.(paramName).(groupSetting).PersonalValue={};
        slSettings.(paramName).(groupSetting).PersonalValue=defList.(groupSetting);
    end
end


function defList=l_AddCustomObjectClassesToSetting


    slsettings=l_GetSimulinkSettings;
    paramName='CustomObjectClasses';
    if~slsettings.hasGroup(paramName)
        slsettings.addGroup(paramName);
    end
    groupSettingsList={'Parameter','Signal','LookupTable'};
    for i=1:numel(groupSettingsList)
        if~slsettings.(paramName).hasSetting(groupSettingsList{i})
            slsettings.(paramName).addSetting(groupSettingsList{i});

            l_ResetCustomObjectListInSetting(slsettings,groupSettingsList{i});
        end
    end




    defList=l_GetDefaultList;
end

