classdef A2LWriter<handle




    properties(Access=private)
        FileWriter rtw.connectivity.Writer=rtw.connectivity.FileWriter.empty;
    end

    methods
        function obj=A2LWriter(fileWriter)
            className=mfilename('class');
            validateattributes(fileWriter,{'rtw.connectivity.Writer'},{'scalar'},className,'fileWriter');
            obj.FileWriter=fileWriter;
        end

        function wLine(obj,inStr)



            obj.FileWriter.write([char(inStr),newline]);
        end
    end
end