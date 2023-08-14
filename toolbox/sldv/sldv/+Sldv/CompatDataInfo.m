classdef(Hidden)CompatDataInfo



    properties
        sldvCachePath=[];
        dvoCachePath=[];
    end

    methods
        function obj=set.sldvCachePath(obj,aPath)
            if ischar(aPath)||isstring(aPath)
                if 2~=exist(aPath,'file')
                    MEx=MException('CompatDataInfo:InvalidPath','Path is invalid');
                    throw(MEx);
                end
                obj.sldvCachePath=aPath;
            else
                MEx=MException('CompatDataInfo:InvalidArg','Expecting a String or Char type');
                throw(MEx);
            end
        end

        function obj=set.dvoCachePath(obj,aPath)
            if ischar(aPath)||isstring(aPath)
                if 2~=exist(aPath,'file')
                    MEx=MException('CompatDataInfo:InvalidPath','Path is invalid');
                    throw(MEx);
                end
                obj.dvoCachePath=aPath;
            else
                MEx=MException('CompatDataInfo:InvalidArg','Expecting a String or Char type');
                throw(MEx);
            end
        end

        function status=isValid(obj)
            status=~isempty(obj.sldvCachePath)&&~isempty(obj.dvoCachePath);
        end
    end
end
