function init(h)




    if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
        cm=DAStudio.CustomizationManager;

        if~cm.ObjectiveCustomizer.initialized
            cm.ObjectiveCustomizer.initialize();
        end

        objectives=cm.ObjectiveCustomizer.factoryObjectives;
        factoryObjLen=cm.ObjectiveCustomizer.factoryObjLen;
        customizedObj=cm.ObjectiveCustomizer.objective;

        tmpObj=objectives;
        objectives=cell(1,factoryObjLen-1);
        idx=0;

        for i=1:factoryObjLen
            if~strcmpi(tmpObj{i}.objectiveID,'Efficiency')
                idx=idx+1;
                objectives{idx}=tmpObj{i};
                objectives{idx}.objectiveName=loc_translation(tmpObj{i}.objectiveName);
            end
        end

        factoryObjLen=idx;
    else
        dirname=fullfile(matlabroot,'toolbox','coder','objectives','+rtw','+codegenObjectives','@ConfigSetProp','objective_*.m');
        d=dir(dirname);
        len=length(d);

        cspObj=rtw.codegenObjectives.ConfigSetProp;
        cspObj.paramBuilder;

        objectives=cell(len,1);
        actualLen=0;


        for i=1:len
            objName=loc_convert(d(i).name);
            actualLen=actualLen+1;
            thisObj=cspObj.objectiveBuilder(objName,false);
            objectives{i}=loc_objConvert(thisObj);
        end

        customizedObj=[];
        factoryObjLen=actualLen;
    end

    customizedLen=length(customizedObj);

    totalLen=factoryObjLen+customizedLen;

    objsLeft=ones(1,totalLen);
    unSelected=1:totalLen;
    objFiles=cell(totalLen,1);

    for i=1:factoryObjLen
        objFiles{str2double(objectives{i}.order)}.name=objectives{i}.objectiveName;
        objFiles{str2double(objectives{i}.order)}.order=objectives{i}.order;
    end

    for i=1:customizedLen
        objFiles{factoryObjLen+i}.name=customizedObj{i}.objectiveName;
        objFiles{factoryObjLen+i}.order=factoryObjLen+i;
    end

    h.objsLeft=objsLeft;
    h.unSelected=unSelected;
    h.unSelectedOld=unSelected;
    h.objsName=objFiles;
    h.numOfObjs=totalLen;
end


function result=loc_convert(filename)
    switch filename
    case 'objective_efficiency.m'
        result='Efficiency';
    case 'objective_efficiency_ram.m'
        result='RAM efficiency';
    case 'objective_efficiency_rom.m'
        result='ROM efficiency';
    case 'objective_efficiency_speed.m'
        result='Execution efficiency';
    case 'objective_traceability.m'
        result='Traceability';
    case 'objective_safetyprecaution.m'
        result='Safety precaution';
    case 'objective_debugging.m'
        result='Debugging';
    case 'objective_misrac.m'
        result='MISRA C:2012 guidelines';
    case 'objective_polyspace.m'
        result='Polyspace';
    end
end

function translated=loc_translation(filename)
    translated=filename;

    switch filename
    case 'Efficiency'
        translated=DAStudio.message('RTW:configSet:sanityCheckEfficiency');
    case 'Traceability'
        translated=DAStudio.message('RTW:configSet:sanityCheckTraceability');
    case{'Safety precaution'}
        translated=DAStudio.message('RTW:configSet:sanityCheckSafetyprecaution');
    case 'Debugging'
        translated=DAStudio.message('RTW:configSet:sanityCheckDebugging');
    case 'RAM efficiency'
        translated=DAStudio.message('RTW:configSet:sanityCheckEfficiencyRAM');
    case 'ROM efficiency'
        translated=DAStudio.message('RTW:configSet:sanityCheckEfficiencyROM');
    case 'Execution efficiency'
        translated=DAStudio.message('RTW:configSet:sanityCheckEfficiencyspeed');
    case 'MISRA C:2012 guidelines'
        translated=DAStudio.message('RTW:configSet:sanityCheckMisrac');
    case 'Polyspace'
        translated=DAStudio.message('RTW:configSet:sanityCheckPolyspace');
    end
end

function objective=loc_objConvert(factoryObj)
    objective.objectiveID=loc_convert(factoryObj.file.objectivename);
    objective.objectiveName=loc_translation(objective.objectiveID);
    objective.order=factoryObj.file.order;

    for i=1:length(factoryObj.params)
        objective.parameters{i}.name=factoryObj.params{i}.name;
        objective.parameters{i}.value=factoryObj.params{i}.setting;
    end

    index=1;
    fixedCheck=coder.advisor.internal.CGOFixedCheck;
    for i=1:length(factoryObj.checklist)
        if factoryObj.checklist{i}.value~=0
            checkID=fixedCheck.checkID{factoryObj.checklist{i}.id};
            objective.checks{index}.MAC=checkID;
            objective.checks{index}.MAC=factoryObj.checklist{i}.value;
            index=index+1;
        end
    end
end



