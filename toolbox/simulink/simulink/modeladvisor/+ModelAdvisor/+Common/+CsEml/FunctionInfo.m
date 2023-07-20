
classdef FunctionInfo<handle

    methods(Access=public)

        function this=FunctionInfo(irFunction,scriptInfo)
            this.privateInitializeType(irFunction,scriptInfo);
            this.privateInitializeName(irFunction);
            this.privateInitializeCode(irFunction,scriptInfo);
        end

        function name=getName(this)
            name=this.m_Name;
        end

        function type=getType(this)
            type=this.m_Type;
        end

        function code=getCode(this)
            code=this.m_Code;
        end

        function codeStart=getCodeStart(this)
            codeStart=this.m_CodeStart;
        end

        function codeEnd=getCodeEnd(this)
            codeEnd=this.m_CodeEnd;
        end

    end

    methods(Access=public)

        function privateInitializeType(this,irFunction,scriptInfo)
            functionName=string(irFunction.FunctionName);
            scriptType=scriptInfo.getType();
            this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.Invalid;
            switch scriptType
            case ModelAdvisor.Common.CsEml.ScriptType.File
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.Function;
            case ModelAdvisor.Common.CsEml.ScriptType.EMChart
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.Function;
            case ModelAdvisor.Common.CsEml.ScriptType.EMFunction
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.Function;
            case ModelAdvisor.Common.CsEml.ScriptType.State
                this.privateInitializeTypeOfState(functionName);
            case ModelAdvisor.Common.CsEml.ScriptType.Transition
                this.privateInitializeTypeOfTransition(functionName);
            end
        end

        function privateInitializeTypeOfState(this,functionName)
            namePrefix="sf_internal_entry_action_";
            if strncmp(functionName,namePrefix,namePrefix.strlength())
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.EntryAction;
                return;
            end
            namePrefix="sf_internal_activity_action_";
            if strncmp(functionName,namePrefix,namePrefix.strlength())
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.DuringAction;
                return;
            end
            namePrefix="sf_internal_exit_action_";
            if strncmp(functionName,namePrefix,namePrefix.strlength())
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.ExitAction;
                return;
            end
        end

        function privateInitializeTypeOfTransition(this,functionName)
            namePrefix="sf_internal_condition_action_";
            if strncmp(functionName,namePrefix,namePrefix.strlength())
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.ConditionAction;
                return;
            end
            namePrefix="sf_internal_transition_action_";
            if strncmp(functionName,namePrefix,namePrefix.strlength())
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.TransitionAction;
                return;
            end
            namePrefix="sf_internal_condition_notaction_";
            if strncmp(functionName,namePrefix,namePrefix.strlength())
                this.m_Type=ModelAdvisor.Common.CsEml.FunctionType.TransitionCondition;
                return;
            end
        end

        function privateInitializeName(this,irFunction)
            functionName=string(irFunction.FunctionName);
            switch this.m_Type
            case ModelAdvisor.Common.CsEml.FunctionType.Function
                this.m_Name=functionName;
            case ModelAdvisor.Common.CsEml.FunctionType.TransitionCondition
                this.m_Name="Transition Condition";
            case ModelAdvisor.Common.CsEml.FunctionType.ConditionAction
                this.m_Name="Condition action";
            case ModelAdvisor.Common.CsEml.FunctionType.TransitionAction
                this.m_Name="Transition action";
            case ModelAdvisor.Common.CsEml.FunctionType.EntryAction
                this.m_Name="Entry action";
            case ModelAdvisor.Common.CsEml.FunctionType.DuringAction
                this.m_Name="During action";
            case ModelAdvisor.Common.CsEml.FunctionType.ExitAction
                this.m_Name="Exit action";
            case ModelAdvisor.Common.CsEml.FunctionType.EntryDuringAction
                this.m_Name="Entry and during action";
            case ModelAdvisor.Common.CsEml.FunctionType.DuringExitAction
                this.m_Name="During and exit action";
            case ModelAdvisor.Common.CsEml.FunctionType.EntryDuringExitAction
                this.m_Name="Entry, during, and exit action"';
            end
        end

        function privateInitializeCode(this,irFunction,scriptInfo)
            this.m_CodeStart=0;
            this.m_CodeEnd=0;
            this.m_Code="";
            scriptCode=scriptInfo.getCode();
            if this.m_Type==ModelAdvisor.Common.CsEml.FunctionType.ConditionAction
                sid=scriptInfo.getPath();
                sfObject=ModelAdvisor.Common.CsEml.Utilities.getStateflowObjectFromSid(sid);
                ast=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfObject);

                if isempty(ast.conditionActionSection)
                    return;
                end

                section=ast.conditionActionSection{1};
                roots=section.roots;
                for i=1:numel(roots)
                    thisRoot=roots{i};
                    sourceSnippet=thisRoot.sourceSnippet;
                    treeStart=thisRoot.treeStart;
                    if treeStart>1
                        before=treeStart-1;
                        if scriptCode.extractBetween(before,before)=="{"
                            this.m_CodeStart=treeStart;
                            this.m_CodeEnd=treeStart+numel(sourceSnippet)-1;
                            this.m_Code=scriptCode.extractBetween(...
                            this.m_CodeStart,this.m_CodeEnd);
                            break;
                        end
                    end
                end
            else
                if~strcmp(scriptCode,'<unknown>')
                    CS=double(irFunction.TextStart+1);
                    CE=double(irFunction.TextStart+irFunction.TextLength);
                    SL=scriptCode.strlength();

                    if CS<=CE&&CS>=1&&CS<=SL&&CE>=1&&CE<=SL
                        this.m_CodeStart=CS;
                        this.m_CodeEnd=CE;
                        this.m_Code=scriptCode.extractBetween(CS,CE);
                    end
                end
            end
        end

    end

    properties
        m_Name;
        m_Type;
        m_Code;
        m_CodeStart;
        m_CodeEnd;
    end

end

