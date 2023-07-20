classdef TxtWriter<plccore.util.BaseWriter



    properties(Access=protected)
TxtBuffer
IndentStr
    end

    methods
        function obj=TxtWriter
            obj.Kind='TxtWriter';
            obj.TxtBuffer='';
            obj.IndentStr='    ';
        end

        function writeLine(obj,str)
            obj.TxtBuffer=[obj.TxtBuffer,str,10];
        end

        function writeNewline(obj)
            obj.TxtBuffer=[obj.TxtBuffer,10];
        end

        function indent(obj)
            obj.TxtBuffer=[obj.TxtBuffer,obj.IndentStr];
        end

        function new_code=fixCode(obj,code)
            new_code=obj.unix2dos(code);
        end

        function writeFile(obj,file_dir,file_name)
            obj.TxtBuffer=obj.fixCode(obj.TxtBuffer);
            obj.writeFileStr(file_dir,file_name,obj.TxtBuffer);
        end
    end
end
