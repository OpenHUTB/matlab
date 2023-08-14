
classdef BaseReader_SLDD<handle



    properties(Access=protected)
        fdd;
        fPathName;
        fDataPath;
        fDescriptionPath;
    end

    methods(Access=protected)

        function obj=BaseReader_SLDD(add,aPathName)
            if(nargin<1)
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end
            obj.fdd=add;
            obj.setPathName(aPathName);
            obj.setDataPath([aPathName,'.Data']);
            obj.setDescriptionPath([aPathName,'.Description']);
        end
    end

    methods(Abstract,Access=public)

        dObject=getObject(obj,aKey);
        dObjects=getObjects(obj,keyList);
        hasObj=hasObject(obj,aKey);

    end

    methods(Abstract,Access=public,Hidden=true)

        insertObject(obj,aKey,aObject);
        replaceObject(obj,aKey,aObject);
        keyList=getKeys(obj);

    end

    methods(Access=public,Hidden=true)
        function parsedKey=parseKey(obj,aKey)%#ok
            parsedKey=regexprep(aKey,{'/','\.','<','>'},...
            {'&#47;','&#46;','&#60;','&#62;'});
        end

        function aKey=unParseKey(obj,parsedKey)%#ok
            aKey=regexprep(parsedKey,{'&#47;','&#46;','&#60;','&#62;'},...
            {'/','\.','<','>'});
        end

        function pathName=getPathName(obj)
            pathName=obj.fPathName;
        end

        function pathName=getDataPath(obj)
            pathName=obj.fDataPath;
        end

        function pathName=getDescriptionPath(obj)
            pathName=obj.fDescriptionPath;
        end

    end

    methods(Access=protected)

        function setPathName(obj,aPathName)
            obj.fPathName=aPathName;
        end

        function setDataPath(obj,aDataPathName)
            obj.fDataPath=aDataPathName;
        end

        function setDescriptionPath(obj,aDescPathName)
            obj.fDescriptionPath=aDescPathName;
        end

    end


end
