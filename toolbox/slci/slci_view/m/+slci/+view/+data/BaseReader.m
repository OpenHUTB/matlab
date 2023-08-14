


classdef BaseReader<handle
    properties(Access=protected)

        fDD;

        fPathName;

        fDataPath;
    end


    methods(Access=protected)


        function this=BaseReader(aDDConn,aPathName)
            this.fDD=aDDConn;
            this.setPathName(aPathName);
            this.setDataPath([aPathName,'.Data']);
        end
    end


    methods(Abstract,Access=public,Hidden=true)


        dObject=getObject(this,aKey);


        dObjects=getObjects(this,aKeyList);


        hasObj=hasObject(this,aKey);


        keyList=getObjectKeys(this);

    end


    methods(Abstract,Access=public,Hidden=true)


        insertObject(this,aKey,aObject);


        replaceObject(this,aKey,aObject);


        deleteObject(this,aKey);

    end


    methods(Access=public,Hidden=true)


        function pathName=getPathName(this)
            pathName=this.fPathName;
        end


        function pathName=getDataPath(this)
            pathName=this.fDataPath;
        end

    end


    methods(Access=protected)


        function setPathName(this,aPathName)
            this.fPathName=aPathName;
        end


        function setDataPath(this,aDataPathName)
            this.fDataPath=aDataPathName;
        end

    end


end
