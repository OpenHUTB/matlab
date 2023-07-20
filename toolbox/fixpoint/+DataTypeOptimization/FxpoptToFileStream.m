classdef FxpoptToFileStream<matlab.unittest.plugins.ToFile






    methods
        function this=FxpoptToFileStream(fileName)
            this@matlab.unittest.plugins.ToFile(fileName);
        end

        function print(this,formatStr,varargin)
            str=string(datetime)+sprintf('\t')+formatStr;
            print@matlab.unittest.plugins.ToFile(this,str);
        end
    end
end