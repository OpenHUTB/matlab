




classdef DataDictionary<handle
    properties(SetAccess=private,GetAccess=public)
DataSource
    end

    properties(SetAccess=private,GetAccess=public)
DataDictionaryFile
    end

    properties(SetAccess=private,GetAccess=private)
DataDictionaryIsDirty
    end

    properties(Constant,Access=private)
        DictionarySection='Global';
    end

    properties(Hidden,Constant,Access=public)
        IsConnectedToDataDictionary=true;
    end

    properties(Hidden,Transient=true)
        Client='';
    end


    methods(Access=public)
        function this=DataDictionary(dataFile,varargin)
            if isempty(varargin)
                this.DataSource=Simulink.dd.open(dataFile);
            else
                this.DataSource=Simulink.dd.open(dataFile,varargin{:});
            end
            this.DataDictionaryIsDirty=this.DataSource.hasUnsavedChanges;
            this.DataDictionaryFile=dataFile;
        end

        function save(this,~,~)
            if~this.DataDictionaryIsDirty&&this.DataSource.hasUnsavedChanges
                this.DataSource.saveChanges;
            end
        end

        function varargout=evalin(this,command)


            oc=[];%#ok
            if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
                (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
                isequal(this.Client,'BusEditor')
                Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,true);
                oc=onCleanup(@()Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,false));
            end

            [varargout{1:nargout}]=this.DataSource.evalin(command,this.DictionarySection);
        end

        function assignin(this,varName,value)


            oc=[];%#ok
            if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
                (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
                isequal(this.Client,'BusEditor')
                Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,true);
                oc=onCleanup(@()Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,false));
            end

            this.DataSource.assignin(varName,value,this.DictionarySection);
        end

        function status=exist(this,varName)


            oc=[];%#ok
            if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
                (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
                isequal(this.Client,'BusEditor')
                Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,true);
                oc=onCleanup(@()Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,false));
            end

            status=this.DataSource.entryExists(sprintf('Global.%s',varName),true);
        end

        function results=whos(this,classType)


            oc=[];%#ok
            if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
                (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
                isequal(this.Client,'BusEditor')
                Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,true);
                oc=onCleanup(@()Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,false));
            end

            results=this.DataSource.getEntriesWithClass(this.DictionarySection,classType);
        end

        function val=get(this,varName)


            oc=[];%#ok
            if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
                (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
                isequal(this.Client,'BusEditor')
                Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,true);
                oc=onCleanup(@()Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,false));
            end

            val=this.DataSource.getEntry(sprintf('Global.%s',varName));
        end

        function val=getEntryLastModDateTime(this,varName)


            oc=[];%#ok
            if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
                (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
                isequal(this.Client,'BusEditor')
                Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,true);
                oc=onCleanup(@()Simulink.dd.private.setSingleTopModelInClosure(this.DataSource,false));
            end

            val=this.DataSource.getEntryLastModDateTime(sprintf('Global.%s',varName));
        end
    end
end
