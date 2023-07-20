


classdef ObjectiveCustomizer<handle
    properties(SetAccess=public)
        objective=[];
        currentCustomizationFile=[];
        initialized=[];
    end

    properties(SetAccess=private,Hidden=true)
        callbackFcn=[];
        additionalCheck=[];
        factoryObjLen=[];
        factoryObjectives=[];
    end

    properties(SetAccess=public,Hidden=true)
        setObjButtonVisible=[]
        nameToIDHash=[];
        IDToNameHash=[];
        cs=[];
    end

    methods
        function obj=ObjectiveCustomizer()
            obj.initialized=false;
        end
    end

    methods
        function initialize(obj)
            obj.setObjButtonVisible=true;
            obj.IDToNameHash=coder.advisor.internal.HashMap('KeyType','char','ValueType','char');
            obj.nameToIDHash=coder.advisor.internal.HashMap('KeyType','char','ValueType','char');
            obj.currentCustomizationFile=[];
            obj.additionalCheck=[];
            obj.cs=Simulink.ConfigSet;
            obj.cs.switchTarget('ert.tlc','');

            len=length(obj.factoryObjectivesNames);
            obj.factoryObjLen=len;

            cspObj=rtw.codegenObjectives.ConfigSetProp;
            cspObj.paramBuilder;
            cspObj.appendParameter(obj.cs);

            objectives=cell(len,1);


            for i=1:len
                thisObj=cspObj.objectiveBuilder(obj.factoryObjectivesNames{i},false);
                objectives{i}=rtw.codegenObjectives.ObjectiveCustomizer.objConvert(thisObj);
                obj.nameToIDHash.put(objectives{i}.objectiveName,objectives{i}.objectiveID);
                obj.IDToNameHash.put(objectives{i}.objectiveID,objectives{i}.objectiveName);
            end

            obj.factoryObjectives=objectives;
            obj.initialized=true;
        end
    end

    properties(Constant=true,Hidden=true)
        factoryObjectivesNames={
'RAM efficiency'
'ROM efficiency'
'Execution efficiency'
'Traceability'
'Safety precaution'
'Debugging'
'MISRA C:2012 guidelines'
'Polyspace'
        };
    end

    methods(Static=true)
        function WarningMsg(args)
            msgId=['Simulink:tools:',args{1}];
            MSLDiagnostic(msgId,args{2:end}).reportAsWarning;
        end

        function throwError(args)
            msgId=['Simulink:tools:',args{1}];
            DAStudio.error(msgId,args{2:end});
        end
    end

    methods(Static=true)
        function objective=objConvert(factoryObj)
            objective.objectiveID=factoryObj.file.objectivename;
            objective.objectiveName=objective.objectiveID;
            objective.order=factoryObj.file.order;

            for i=1:length(factoryObj.params)
                objective.parameters{i}=rtw.codegenObjectives.Parameter(factoryObj.params{i}.name,...
                factoryObj.params{i}.setting,...
                objective.objectiveName,false);
            end

            index=1;
            for i=1:length(factoryObj.checklist)
                if factoryObj.checklist{i}.value~=0
                    staticv=rtw.codegenObjectives.ObjectiveCustomizer.staticVar();
                    fixedCheck=staticv.fixedCheck;
                    checkID=fixedCheck.checkID{factoryObj.checklist{i}.id};
                    objective.checks{index}=rtw.codegenObjectives.Check(checkID,factoryObj.checklist{i}.value);
                    index=index+1;
                end
            end
        end
    end

    methods(Static=true)
        function r=staticVar()
            persistent fixedCheck;

            if isempty(fixedCheck)
                fixedCheck=coder.advisor.internal.CGOFixedCheck;
            end

            r.fixedCheck=fixedCheck;
        end

        function objName=getObjectiveEnglishName(objectiveName)
            switch objectiveName.order
            case '1'
                objName='Execution efficiency';
            case '2'
                objName='ROM efficiency';
            case '3'
                objName='RAM efficiency';
            case '4'
                objName='Traceability';
            case '5'
                objName='Safety precaution';
            case '6'
                objName='Debugging';
            case '7'
                objName='MISRA C:2012 guidelines';
            case '8'
                objName='Polyspace';
            otherwise
                objName=objectiveName.name;
            end
        end
    end

    methods
        clear(obj)
        clearChecks(obj)
        addObjective(obj,objective)
        resetObjective(obj)
        idx=addCallbackObjFcn(obj,func)
        addAdditionalCheck(obj,check)
        showSetObjButton(obj,arg)
        rtn=isSetObjButtonVisible(obj)
        report(obj,objname)
    end
end


