classdef ConfigurationContainer<handle

    properties(Access=private)

        fileName;
    end

    properties(Access=public)
        defaults;
        HDLTopLevel;

        settings;
        statements;
    end

    methods
        function this=ConfigurationContainer(fName)
            if nargin<1
                this.fileName='';
            else
                this.fileName=fName;
            end
            this.HDLTopLevel='';
        end

        addBinding(this,scope,block,blockparams,impl,implparams)
        defaultFor(this,block,blockparams,impl,implparams)
        dumpConfigStmtInfo(this,filename,implDB)
        str=dumpConfigStr(this,implDB)
        dumpText(this,filename,implDB,nondefault)
        forAll(this,scope,block,blockparams,impl,implparams)
        forEach(this,scopes,block,blockparams,impl,implparams)
        generateHDLFor(this,block)
        merge(this,other)
        set(this,varargin)
    end
end
