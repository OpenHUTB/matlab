classdef HDLImplementationTable<handle

    properties(Access=public)

        Sets;

        ImplDB;
    end

    methods
        function this=HDLImplementationTable(implDB)
            this.Sets=containers.Map;
            this.ImplDB=implDB;
        end

        addImplementation(this,slBlockPath,blockLibPath,classname,params,warnOnOverwrite)
        value=getForTag(this,slBlockPath)
        aSet=getImplementationSet(this,slBlockPath)
        setForTag(this,slBlockPath,value)
    end
end

