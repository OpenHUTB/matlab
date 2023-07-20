classdef HDLImplementationSet<handle

    properties(Access=public)

        ImplSet;
    end

    methods
        function this=HDLImplementationSet
            this.ImplSet={};
            this.ImplSet{end+1}='1dummy';
            this.ImplSet{end+1}='2dummy';
        end

        addImplementation(this,blockLibPath,archName,params,warnOnOverwrite)
        displaySet(this)
        disp(this)
        className=getImplementationClassName(this,blockLibPath,implDB)
        implObj=getImplementation(this,blockLibPath,configMgr)
        value=getImplInfoForBlockLibPath(this,blockLibPath)
        tags=getTags(this)
        here=isBlockInSet(this,block)
        setImplInfoForBlockLibPath(this,blockLibPath,value)
    end
end

