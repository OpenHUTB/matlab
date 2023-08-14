


classdef HdlParser<handle



    properties
        FileName;
        ModuleName;
        Lexer;
        ModuleInfo;
        ParserInfo;
CodeInfo
    end

    methods

        function obj=HdlParser(filename,modulename)
            obj.FileName=filename;
            obj.ModuleName=modulename;


        end
    end

    methods(Abstract=true);
        [moduleinfo,parserinfo,codeinfo]=parse(obj);
    end
end

