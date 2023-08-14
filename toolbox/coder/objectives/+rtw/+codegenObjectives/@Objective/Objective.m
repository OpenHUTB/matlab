




classdef Objective<handle
    properties(SetAccess=public)
        objectiveName=[];
        objectiveID=[]
        parameters=[];
        checks=[];
        baseObjective=[];
    end


    properties(SetAccess=private,Hidden=true)
        order=[];
        paramHash=[];
        paramHashPos=[];
        checkHash=[];
        checkHashPos=[];
    end

    properties(SetAccess=public,Hidden=true)
        customizationFileLocation=[];
    end

    methods
        function obj=Objective(ID,baseObjective)
            obj.paramHash=coder.advisor.internal.HashMap;
            obj.paramHashPos=coder.advisor.internal.HashMap;
            obj.checkHash=coder.advisor.internal.HashMap;
            obj.checkHashPos=coder.advisor.internal.HashMap;

            obj.initializeCustomizer;

            if nargin<1
                ID='';
            end

            obj.setObjectiveID(ID);

            if nargin>1
                obj.setBaseObjective(baseObjective);
            end

            obj.addCheck('mathworks.codegen.CodeGenSanity');
        end
    end

    methods
        addParam(obj,param,value)
        modifyParam(obj,param,value)
        removeParam(obj,param)
        modifyInheritedParam(obj,param,value)
        removeInheritedParam(obj,param)
        addCheck(obj,check)
        excludeCheck(obj,check)
        associate(obj,check,arg)
        removeCheck(obj,check)
        removeInheritedCheck(obj,check)
        setOrder(obj,order)
        setObjectiveID(obj,ID)
        setObjectiveName(obj,name)
        setBaseObjective(obj,baseObjective)
        register(obj)
        report(obj)
    end

    methods(Static=true)
        isObjNameDuplicated(obj,name)
        isObjIDDuplicated(obj,ID)
    end

    methods(Static=true)
        function result=isValidID(ID)
            result=false;
            exp='[a-zA-Z0-9_]+';

            [ret,s,e]=regexp(ID,exp,'match','start','end');

            if length(ret)==1&&s==1&&e==strlength(ID)
                result=true;
            end
        end

        function initializeCustomizer()







            cm=DAStudio.CustomizationManager;
            if~isprop(cm,'ObjectiveCustomizer')
                throw(MSLException([],message(...
                'Simulink:tools:ObjectiveCustomizerNotInitialized')));
            end



            if~cm.ObjectiveCustomizer.initialized
                cm.ObjectiveCustomizer.initialize;
            end
        end
    end

end


