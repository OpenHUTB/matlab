



classdef cvdatagroup<handle

    properties(GetAccess=public)
        name=''
        uniqueId=''
        description=''
        tag=''
        aggregatedIds=''
    end

    properties(GetAccess=public,Hidden=true)
        m_data=[]
        fileRef(1,1)struct=struct('name','','datenum','','uuid','')
        isLoaded(1,1)logical=true
    end

    properties(Hidden=true,Transient=true)
        testRunInfo=[]
        traceOn=false
    end

    methods
        function copy(this,cvdg)
            this.name=cvdg.name;
            this.uniqueId=cvdg.uniqueId;
            this.description=cvdg.description;
            this.tag=cvdg.tag;
            this.aggregatedIds=cvdg.aggregatedIds;

            this.m_data=containers.Map('KeyType','char','ValueType','any');
            keys=cvdg.m_data.keys();
            for ii=1:numel(keys)
                this.m_data(keys{ii})=cvdg.m_data(keys{ii});
            end
        end

        function set.testRunInfo(this,value)
            this.setTestRunInfo(value)
        end

        function ver=dbVersion(this)
            ver='';
            cvds=this.m_data.values();
            if~isempty(cvds)
                ver=cvds{1}.dbVersion;
            end
        end

        function set.traceOn(this,value)
            this.setTraceOn(value)
        end

        display(this)
        res=minus(lhs,rhs)
        res=mtimes(lhs,rhs)
        res=plus(lhs,rhs)
    end

    methods(Abstract)
        this=add(this,cvd)
        load(this)
    end

    methods(Abstract,Access=protected,Hidden)
        qname=getCvDataGroupClassName(this)
        qname=getCvDataClassName(this)
    end

    methods(Hidden)
        [names,varargout]=allNames(this,mode)
        modes=allSimulationModes(this,name)
        cvds=getAll(this,mode)
        cvd=get(this,name,mode)
        init(this)
        res=isCompatible(this,cvd)
        setTestRunInfo(this,testRunIfno)
        setTraceOn(this,traceOn)
        setUniqueId(this)
        out=valid(this)
    end

    methods(Static,Hidden)
        mode=checkSimulationMode(mode,fcnName,argPos)
    end

end
