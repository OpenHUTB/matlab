

classdef CodeInfo<handle
    properties
        Functions(1,:)polyspace.internal.codeinsight.parser.FunInfo
        Variables(1,:)polyspace.internal.codeinsight.parser.VarInfo
        Types(1,:)polyspace.internal.codeinsight.parser.TypeInfo
        Files(1,:)polyspace.internal.codeinsight.parser.FileInfo
        Macros(1,:)polyspace.internal.codeinsight.parser.MacroInfo
    end

    properties(Access=private)
        functionMap containers.Map
        variableMap containers.Map
        typeMap containers.Map
        fileMap containers.Map
        macroMap containers.Map
    end

    methods
        function obj=CodeInfo()
            obj.functionMap=containers.Map('KeyType','char','ValueType','any');
            obj.variableMap=containers.Map('KeyType','char','ValueType','any');
            obj.typeMap=containers.Map('KeyType','char','ValueType','any');
            obj.fileMap=containers.Map('KeyType','char','ValueType','any');
            obj.macroMap=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods
        function[h,exists]=addFunction(obj,sig)
            [h,exists]=obj.addObject(sig,'functionMap','FunInfo');
        end

        function[h,exists]=addType(obj,name)
            [h,exists]=obj.addObject(name,'typeMap','TypeInfo');
        end

        function[h,exists]=addVariable(obj,name)
            [h,exists]=obj.addObject(name,'variableMap','VarInfo');
        end

        function[h,exists]=addFile(obj,name)
            [h,exists]=obj.addObject(name,'fileMap','FileInfo');
        end

        function[h,exists]=addMacro(obj,name)
            [h,exists]=obj.addObject(name,'macroMap','MacroInfo');
        end

        function print(self)
            functionsTable=arrayfun(@(x)x.unfold,self.Functions);
            fprintf("** FUNCTIONS **"+newline)
            if(~isempty(functionsTable))
                disp(struct2table(functionsTable));
            end
            variablesTable=arrayfun(@(x)x.unfold,self.Variables);
            fprintf("** VARIABLES **"+newline)
            if(~isempty(variablesTable))
                disp(struct2table(variablesTable));
            end
            typesTable=arrayfun(@(x)x.unfold,self.Types);
            fprintf("** TYPES **"+newline)
            if(~isempty(typesTable))
                disp(struct2table(typesTable));
            end
            filesTable=arrayfun(@(x)x.unfold,self.Files);
            fprintf("** FILES **"+newline)
            if(~isempty(filesTable))
                disp(struct2table(filesTable));
            end
            macrosTable=arrayfun(@(x)x.unfold,self.Macros);
            fprintf("** MACROS **"+newline)
            if(~isempty(macrosTable))
                disp(struct2table(macrosTable));
            end
        end
    end

    methods(Access=private)
        function[h,exists]=addObject(obj,key,objMap,objType)
            exists=obj.(objMap).isKey(key);
            if exists
                h=obj.(objMap)(key);
            else
                h=polyspace.internal.codeinsight.parser.(objType)(key);
                obj.(objMap)(key)=h;
            end
        end
    end

end

