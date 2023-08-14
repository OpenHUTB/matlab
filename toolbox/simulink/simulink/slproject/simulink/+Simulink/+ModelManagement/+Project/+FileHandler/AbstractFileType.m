classdef AbstractFileType




    properties(GetAccess=public,SetAccess=private)
FileName
FilePath
JavaFile
Excluded
    end

    methods(Access=protected)
        function obj=AbstractFileType(javaFile)
            obj.JavaFile=javaFile;
            obj.FilePath=javaFile.toString().toCharArray()';

            obj.FileName=obj.generateFileName();
        end

        function obj=setExcluded(obj,parameterMapping)
            parameters=parameterMapping.keys();

            try
                matchesExpected=cellfun(@(x)obj.performQuery(obj.FileName,x,parameterMapping(x)),parameters);
                obj.Excluded=~all(matchesExpected);
            catch exception
                matlab.internal.project.logging.logException(exception);
                obj.Excluded=true;
            end
        end
    end

    methods(Access=protected,Abstract=true)
        fileName=generateFileName(obj);
    end

    methods(Access=protected,Abstract=true,Static=true)
        match=performQuery(fileName,key,value);
    end

end

