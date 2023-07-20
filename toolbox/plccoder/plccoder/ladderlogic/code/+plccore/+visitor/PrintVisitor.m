classdef PrintVisitor<plccore.visitor.AbstractVisitor



    properties
Indent
    end

    methods
        function obj=PrintVisitor
            obj.Kind='PrintVisitor';
            obj.Indent=0;
        end

        function visitContext(obj,host,input)
            fprintf('Context:\n');
            obj.Indent=obj.Indent+1;
            host.configuration.accept(obj,input);
            obj.Indent=obj.Indent-1;
        end

        function ret=visitConfiguration(obj,host,input)
            fprintf('%sConfiguration: %s\n',repmat('| ',1,obj.Indent),host.name);
            obj.Indent=obj.Indent+1;
            host.globalScope.accept(obj,input);
            fprintf('%sTaskList:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            taskList=host.taskList;
            if~isempty(taskList)
                for i=1:numel(taskList)
                    taskList{i}.accept(obj,host);
                end
            end
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitContinuousTask(obj,host,input)
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.kind);
            obj.Indent=obj.Indent+1;
            obj.visitTask(host,input);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitEventTask(obj,host,input)
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.kind);
            obj.Indent=obj.Indent+1;
            fprintf('%sRate: %s\n',repmat('| ',1,obj.Indent),num2str(host.rate));
            fprintf('%sTrigger: %s\n',repmat('| ',1,obj.Indent),host.trigger);
            obj.visitTask(host,input);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitPeriodicTask(obj,host,input)
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.kind);
            obj.Indent=obj.Indent+1;
            fprintf('%sRate: %s\n',repmat('| ',1,obj.Indent),num2str(host.rate));
            obj.visitTask(host,input);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitTask(obj,host,input)%#ok<INUSD>
            fprintf('%sName: %s\n',repmat('| ',1,obj.Indent),host.name);
            fprintf('%sPriority: %s\n',repmat('| ',1,obj.Indent),num2str(host.priority));
            fprintf('%sWatchdogTime: %s\n',repmat('| ',1,obj.Indent),num2str(host.watchdogTime));
            fprintf('%sTaskKlass: %s\n',repmat('| ',1,obj.Indent),host.taskClass);
            fprintf('%sProgList:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            progList=host.programList;
            if~isempty(progList)
                for i=1:numel(progList)
                    fprintf('%s%s\n',repmat('| ',1,obj.Indent),progList{i}.name);
                end
            end
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitGlobalScope(obj,host,input)%#ok<INUSD>
            obj.visitScope(host,'global');
            ret=[];
        end

        function ret=visitScope(obj,host,input)

            if~host.empty
                switch input
                case 'global'
                    fprintf('%sGlobalScope:\n',repmat('| ',1,obj.Indent));
                case 'input'
                    fprintf('%sInputScope:\n',repmat('| ',1,obj.Indent));
                case 'output'
                    fprintf('%sOutputScope:\n',repmat('| ',1,obj.Indent));
                case 'local'
                    fprintf('%sLocalScope:\n',repmat('| ',1,obj.Indent));
                case 'inout'
                    fprintf('%sInOutScope:\n',repmat('| ',1,obj.Indent));
                end
            end
            name_list=host.getSymbolNames;
            for i=1:numel(name_list)
                symbol=host.getSymbol(name_list{i});
                obj.Indent=obj.Indent+1;
                symbol.accept(obj,input);
                obj.Indent=obj.Indent-1;
            end
            ret=[];
        end

        function ret=visitFunction(obj,host,input)
            fprintf('%sFunction: %s\n',repmat('| ',1,obj.Indent),host.name);
            obj.Indent=obj.Indent+1;

            argList=host.argList;
            fprintf('%sArgList:\n',repmat('| ',1,obj.Indent));
            if~isempty(argList)
                obj.Indent=obj.Indent+1;
                for i=1:numel(argList)
                    fprintf('%s%s\n',repmat('| ',1,obj.Indent),argList{i});
                end
                obj.Indent=obj.Indent-1;
            end

            if~isempty(host.inputScope)
                host.inputScope.accept(obj,'input');
            end
            if~isempty(host.outputScope)
                host.outputScope.accept(obj,'output');
            end
            if~isempty(host.localScope)
                host.localScope.accept(obj,'local');
            end
            if~isempty(host.inOutScope)
                host.inOutScope.accept(obj,'inout');
            end
            if~isempty(host.impl)
                host.impl.accept(obj,input);
            end
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitFunctionBlock(obj,host,input)
            fprintf('%sFunctionBlock: %s\n',repmat('| ',1,obj.Indent),host.name);
            obj.Indent=obj.Indent+1;
            argList=host.argList;
            fprintf('%sArgList:\n',repmat('| ',1,obj.Indent));
            if~isempty(argList)
                obj.Indent=obj.Indent+1;
                for i=1:numel(argList)
                    fprintf('%s%s\n',repmat('| ',1,obj.Indent),argList{i});
                end
                obj.Indent=obj.Indent-1;
            end

            host.inputScope.accept(obj,'input');
            host.outputScope.accept(obj,'output');
            host.localScope.accept(obj,'local');
            host.inOutScope.accept(obj,'inout');
            if~isempty(host.impl)
                host.impl.accept(obj,input);
            end
            ret=[];
            obj.Indent=obj.Indent-1;
        end

        function ret=visitProgram(obj,host,input)%#ok<INUSD>
            fprintf('%sProgram: %s\n',repmat('| ',1,obj.Indent),host.name);
            obj.Indent=obj.Indent+1;
            fprintf('');
            if host.hasMainRoutine
                fprintf('%sMainRoutine: %s\n',repmat('| ',1,obj.Indent),host.mainRoutine.name);
            else
                fprintf('%sMainRoutine:\n',repmat('| ',1,obj.Indent));
            end
            argList=host.argList;
            fprintf('%sArgList:\n',repmat('| ',1,obj.Indent));
            if~isempty(argList)
                obj.Indent=obj.Indent+1;
                for i=1:numel(argList)
                    fprintf('%s%s\n',repmat('| ',1,obj.Indent),argList{i});
                end
                obj.Indent=obj.Indent-1;
            end

            host.inputScope.accept(obj,'input');
            host.outputScope.accept(obj,'output');
            host.localScope.accept(obj,'local');
            host.inOutScope.accept(obj,'inout');
            ret=[];
            obj.Indent=obj.Indent-1;
        end

        function ret=visitRoutine(obj,host,input)
            fprintf('%sRoutine: %s\n',repmat('| ',1,obj.Indent),host.name);
            obj.Indent=obj.Indent+1;
            host.impl.accept(obj,input);
            ret=[];
            obj.Indent=obj.Indent-1;
        end

        function ret=visitLadderDiagram(obj,host,input)%#ok<INUSD>
            rungs=host.rungs;
            fprintf('%sLadderDiagram:\n',repmat('| ',1,obj.Indent));
            if~isempty(rungs)
                for i=1:numel(rungs)
                    rung=rungs{i};
                    obj.Indent=obj.Indent+1;
                    rung.accept(obj,i);
                    obj.Indent=obj.Indent-1;
                end
            end
            ret=[];
        end

        function ret=visitLadderRung(obj,host,input)
            rungops=host.rungOps;
            fprintf('%sLadderRung %d:\n',repmat('| ',1,obj.Indent),input);
            if~isempty(rungops)
                for i=1:numel(rungops)
                    rungop=rungops{i};
                    obj.Indent=obj.Indent+1;
                    rungop.accept(obj,i);
                    obj.Indent=obj.Indent-1;
                end
            end
            ret=[];
        end

        function ret=visitRungOpFBCall(obj,host,input)%#ok<INUSD>
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.kind);
            obj.Indent=obj.Indent+1;
            fprintf('%sInstance:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            host.instance.accept(obj,host);
            obj.Indent=obj.Indent-1;
            fprintf('%sArgList:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            argList=host.argList;
            for i=1:numel(argList)
                argList{i}.accept(obj,host);
            end
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitRungOpAtom(obj,host,input)%#ok<INUSD>
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.instr.name);
            obj.Indent=obj.Indent+1;
            inputs=host.inputs;
            fprintf('%sInputs:\n',repmat('| ',1,obj.Indent));
            for i=1:numel(inputs)
                obj.Indent=obj.Indent+1;
                inputs{i}.accept(obj,i);
                obj.Indent=obj.Indent-1;
            end
            fprintf('%sOutputs:\n',repmat('| ',1,obj.Indent));
            outputs=host.outputs;
            if~isempty(outputs)
                for i=1:numel(outputs)
                    obj.Indent=obj.Indent+1;
                    outputs{i}.accept(obj,i);
                    obj.Indent=obj.Indent-1;
                end
            end
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitWildCardExpr(obj,host,input)%#ok<INUSD>
            fprintf('%sWildCardExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%sString: %s\n',repmat('| ',1,obj.Indent),host.str);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitRoutineExpr(obj,host,input)%#ok<INUSD>
            fprintf('%sRoutineExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%sRoutine: %s\n',repmat('| ',1,obj.Indent),host.routine.name);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitIntegerBitRefExpr(obj,host,input)%#ok<INUSD>
            fprintf('%sIntegerBitRefExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%sBitIndex:%d\n',repmat('| ',1,obj.Indent),host.bitIndex);
            fprintf('%sIntegerExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            host.integerExpr.accept(obj,host);
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitArrayRefExpr(obj,host,input)%#ok<INUSD>
            fprintf('%sArrayRefExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%sIndexExprList: [',repmat('| ',1,obj.Indent));
            numIndex=host.getIndexCount;
            if numIndex>1
                for i=1:numIndex-1
                    fprintf(' %s,',host.indexExpr(i).toString);
                end
            end
            fprintf('%s',host.indexExpr(numIndex).toString);
            fprintf(' ]\n');
            fprintf('%sArrayExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            host.arrayExpr.accept(obj,host);
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitStructRefExpr(obj,host,input)%#ok<INUSD>
            fprintf('%sStructRefExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%sFieldName: %s\n',repmat('| ',1,obj.Indent),host.fieldName);
            fprintf('%sStructExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            host.structExpr.accept(obj,host);
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitVarExpr(obj,host,input)%#ok<INUSD>
            fprintf('%sVarExpr:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%sVar: %s\n',repmat('| ',1,obj.Indent),host.var.name);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitVar(obj,host,input)%#ok<INUSD>
            fprintf('%s%s\n',repmat('| ',1,obj.Indent),host.name);
            obj.Indent=obj.Indent+1;
            type=strsplit(host.type.toString);
            fprintf('%sType: %s\n',repmat('| ',1,obj.Indent),type{1});
            fprintf('%sInitialValue:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            if~isempty(host.initialValue)
                host.initialValue.accept(obj,host);
            end
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD>
            fprintf('%sConstValue:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%s%s: %s\n',repmat('| ',1,obj.Indent),host.type.kind,host.value);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitArrayValue(obj,host,input)%#ok<INUSD>
            fprintf('%sArrayValue:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            elemValueList=host.elemValueList;
            for i=1:numel(elemValueList)
                elemValueList{i}.accept(obj,host);
            end
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            fprintf('%sConstTrue:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%s%s: %s\n',repmat('| ',1,obj.Indent),host.type.kind,host.value);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            fprintf('%sConstFalse:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            fprintf('%s%s: %s\n',repmat('| ',1,obj.Indent),host.type.kind,host.value);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitStructValue(obj,host,input)%#ok<INUSD>
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.kind);
            obj.Indent=obj.Indent+1;
            fieldNameList=host.fieldNameList;
            fprintf('%sFieldNames:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            if~isempty(fieldNameList)
                for i=1:numel(fieldNameList)
                    fprintf('%s%s\n',repmat('| ',1,obj.Indent),fieldNameList{i});
                end
            end
            obj.Indent=obj.Indent-1;
            fprintf('%sFieldValues:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            if~isempty(fieldNameList)
                for j=1:numel(fieldNameList)
                    host.fieldValue(fieldNameList{j}).accept(obj,host.fieldValue(fieldNameList{j}));
                end
            end
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitNamedType(obj,host,input)%#ok<INUSD>
            fprintf('%sNamedType: %s\n',repmat('| ',1,obj.Indent),host.name);
            obj.Indent=obj.Indent+1;
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.type.kind);
            obj.Indent=obj.Indent+1;
            host.type.accept(obj,host);
            obj.Indent=obj.Indent-2;
            ret=[];
        end

        function ret=visitStructType(obj,host,input)%#ok<INUSD>
            fprintf('%sFieldNames:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            for i=1:host.numFields
                fprintf('%s%s\n',repmat('| ',1,obj.Indent),host.fieldName(i));
            end
            obj.Indent=obj.Indent-1;
            fprintf('%sFieldTypes:\n',repmat('| ',1,obj.Indent));
            obj.Indent=obj.Indent+1;
            for i=1:host.numFields
                if strcmp(host.fieldType(i).kind,'NamedType')||strcmp(host.fieldType(i).kind,'ArrayType')
                    host.fieldType(i).accept(obj,host);
                else
                    fprintf('%s%s\n',repmat('| ',1,obj.Indent),host.fieldType(i).kind);
                end
            end
            obj.Indent=obj.Indent-1;
            ret=[];
        end

        function ret=visitArrayType(obj,host,input)%#ok<INUSD>
            fprintf('%s%s:\n',repmat('| ',1,obj.Indent),host.kind);
            obj.Indent=obj.Indent+1;
            fprintf('%sDimsList: [%s]\n',repmat('| ',1,obj.Indent),num2str(host.dims));
            fprintf('%sElemType: %s\n',repmat('| ',1,obj.Indent),host.elemType.kind);
            obj.Indent=obj.Indent-1;
            ret=[];
        end

    end
end


