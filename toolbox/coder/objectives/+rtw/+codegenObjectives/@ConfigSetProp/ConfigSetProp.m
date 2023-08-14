


classdef ConfigSetProp<handle
    properties(SetAccess=public)
        Parameters=[];
        ParamHash=[];
        nOfCC=0;
        CtrlCond=[];
        DAGNode;
        totalParamNum;
        seated;
        objectives;
        objName;
        Dependencies;
        scriptList;
        lenOfList;
        scriptLists;
        lenOfLists;
        nOfStateOfCC;
        stateOfCC;
        error=0;
    end

    properties(Constant=true)
        dir=fullfile(matlabroot,'toolbox','rtw','rtw','private');
    end

    methods
        obj=driver(obj,objName,controlCode,cs)
        obj=construction(obj,objName,generate)
        obj=appendParameter(obj,cs)
        obj=reader(obj)
        process(obj,DAG,stateId)
        removeFlaggedRecommendations(obj,cs)
        objectiveReader(obj,objectives,includeCustomization,cs)


        controls=controlBuilder(obj)
        dependencies=dependencyBuilder(obj)
        objectives=objectiveBuilder(obj,objective,includeCustomization,cs)


        unmatched=compare(obj,cs)
    end
end
