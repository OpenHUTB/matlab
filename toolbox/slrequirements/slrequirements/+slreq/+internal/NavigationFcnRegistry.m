classdef NavigationFcnRegistry<handle















    properties(Access=private)

userFile
callbacks

    end

    methods(Access=private)


        function this=NavigationFcnRegistry()
            this.userFile=fullfile(prefdir,'rmi_externalNavigation.mat');
            this.callbacks=containers.Map('KeyType','char','ValueType','char');
        end

        function init(this)
            if exist(this.userFile,'file')==2
                this.loadFromFile();
            else



                this.callbacks('IBM Rational Requirements')='oslc.navigateFromReference';


                this.callbacks('Polarion')='slreq.internal.navigateToPolarion';

                this.callbacks('IBM Rational DOORS')='slreq.internal.navigateToDOORS';
            end
        end

        function size=count(this)
            size=this.callbacks.Count;
        end

        function clear(this)
            allKeys=this.callbacks.keys();
            this.callbacks.remove(allKeys);
        end

        function loadFromFile(this)
            loaded=load(this.userFile);
            this.callbacks=loaded.mappedCallbacks;
        end

        function writeToFile(this)
            mappedCallbacks=this.callbacks;
            save(this.userFile,'mappedCallbacks');
        end

    end

    methods(Static)

        function result=getInstance()
            persistent registry
            if isempty(registry)
                registry=slreq.internal.NavigationFcnRegistry();
            end
            if registry.count()==0
                registry.init();
            end
            result=registry;
        end

        function reset()
            ncbMgr=slreq.internal.NavigationFcnRegistry.getInstance();
            ncbMgr.clear();
            ncbMgr.init();
        end

        function clearStoredMapping()

            ncbMgr=slreq.internal.NavigationFcnRegistry.getInstance();
            ncbMgr.clear();
            ncbMgr.writeToFile();
            ncbMgr.init();
        end
    end

    methods

        function out=get(this,sourceName)
            if isKey(this.callbacks,sourceName)
                out=this.callbacks(sourceName);
            else
                out='';
            end
        end

        function set(this,sourceName,callbackName)
            if isempty(callbackName)

            else

                callbackName=regexprep(callbackName,'\.m$','');

                errorMsg=slreq.internal.NavigationFcnRegistry.validateFcnName(callbackName);
                if~isempty(errorMsg)
                    error(errorMsg);
                end
            end

            this.callbacks(sourceName)=callbackName;
            this.writeToFile();
        end

        function out=list(this)
            myKeys=keys(this.callbacks);
            out=cell(length(myKeys),2);
            for i=length(myKeys):-1:1
                oneKey=myKeys{i};
                if isempty(this.callbacks(oneKey))
                    out(i,:)=[];
                else
                    out(i,:)={oneKey,this.callbacks(oneKey)};
                end
            end
        end

    end

    methods(Static,Access=private)

        function errorMsg=validateFcnName(callbackName)
            errorMsg=[];


            if~slreq.internal.NavigationFcnRegistry.isGoodName(callbackName)
                betterName=regexprep(callbackName,'[^\w\.\-]','');
                betterName=regexprep(betterName,'^\d+','');
                if isempty(betterName)

                    betterName='navToExtDoc';
                end
                errorMsg=message('Slvnv:slreq:UnsuitableName',callbackName,betterName);
            else

                onMatlabPath=which(callbackName);
                if isempty(onMatlabPath)
                    errorMsg=message('Slvnv:rmiml:FileNotFound',[callbackName,'.m']);
                else
                    [~,~,fExt]=fileparts(onMatlabPath);
                    if~any(strcmp(fExt,{'.m','.p'}))
                        errorMsg=message('Slvnv:rmiml:FileNotFound',[callbackName,'.m']);
                    end
                end
            end
        end

        function tf=isGoodName(callbackName)



            tf=~isempty(callbackName)&&...
            isempty(regexp(callbackName,'[^\w\.\-]','once'))&&...
            isstrprop(callbackName(1),'alpha');
        end

    end

end




