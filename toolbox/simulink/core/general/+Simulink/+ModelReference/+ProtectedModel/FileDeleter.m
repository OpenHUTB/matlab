




classdef FileDeleter<handle
    properties(Access=private)
        fFileMap;
        fAddedListener={};
        fCurrentTop;
        fSecondaryTop='';
        fTopsList={};
        hModelCloseListener;
    end

    methods(Access=private)
        function obj=FileDeleter()
            obj.fFileMap=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods(Hidden)
        function out=getResettableProperties(obj)
            out.fFileMap=obj.fFileMap;
            out.fAddedListener=obj.fAddedListener;
            out.fCurrentTop=obj.fCurrentTop;
            out.fSecondaryTop=obj.fSecondaryTop;
            out.fTopsList=obj.fTopsList;

        end

        function setSecondaryTop(obj,topmodel)
            obj.fSecondaryTop=topmodel;
        end

        function setCurrentTopModel(obj,topmodel)
            obj.fCurrentTop=topmodel;
        end


        function addFileToDelete(obj,filename)
            if~slsvTestingHook('ProtectedModelCleanupTest')

                topmodel=obj.getTopModel();
                if isKey(obj.fFileMap,filename)
                    associatedTopModel=obj.fFileMap(filename);

                    if~any(strcmp(associatedTopModel,topmodel))
                        associatedTopModel{end+1}=topmodel;
                        obj.fFileMap(filename)=associatedTopModel;
                        obj.addListener(topmodel);
                    end
                else
                    obj.fFileMap(filename)={topmodel};
                    obj.addListener(topmodel);
                end
            end
        end


        function deleteFiles(obj,dbName)
            if~ishandle(dbName)

                bdh=get_param(dbName,'UDDObject');
            end

            allFiles=keys(obj.fFileMap);

            warnStatus=warning('off','MATLAB:DELETE:Permission');
            cleanup1=onCleanup(@()obj.cleanupAfterDelete(warnStatus,bdh,dbName));


            for i=1:length(allFiles)
                currentFile=allFiles{i};

                associatedTopModel=obj.fFileMap(currentFile);
                if any(strcmp(associatedTopModel,dbName))
                    associatedTopModel(ismember(associatedTopModel,dbName))=[];
                    obj.fFileMap(currentFile)=associatedTopModel;
                end
                if(isempty(obj.fFileMap(currentFile)))
                    obj.deleteFile(currentFile);
                end
            end
        end



        function cleanupAfterDelete(obj,warnStatus,bdh,dbName)
            warning(warnStatus.state,'MATLAB:DELETE:Permission');
            obj.fAddedListener(ismember(obj.fAddedListener,dbName))=[];
            obj.removeListeners(bdh);
            obj.fTopsList(ismember(obj.fTopsList,dbName))=[];
            if isempty(obj.fTopsList)
                obj.cleanupProperties();
            end
        end

        function cleanupProperties(obj)
            obj.fFileMap=containers.Map('KeyType','char','ValueType','any');
            obj.fAddedListener={};
            obj.fCurrentTop='';
            obj.fSecondaryTop='';
        end
    end

    methods(Access=private)

        function topmodel=getTopModel(obj)

            assert(~isempty(obj.fCurrentTop)||~isempty(obj.fSecondaryTop));
            topmodel=obj.fCurrentTop;
            if isempty(obj.fCurrentTop)
                topmodel=obj.fSecondaryTop;
            end
            obj.AddToTopsList(topmodel);
        end

        function blkDiagram=getTopModelBlockDigramHandle(~,topmodel)

            blkDiagram=get_param(topmodel,'Object');

        end

        function removeListeners(obj,bdh)
            obj.removeListener(bdh,@Simulink.ModelReference.ProtectedModel.FileDeleter.cleanup);
        end

        function removeListener(~,bdh,listenerCallback)
            bdh=handle(bdh);
            p=findprop(bdh,'Listener_Storage_');
            if isempty(p)


                return;
            end


            bdListeners=bdh.Listener_Storage_;
            neqIndex=ones(1,length(bdListeners));
            for i=1:length(bdListeners)
                callback=bdListeners(i).Callback;
                if~isequal(callback,listenerCallback)
                    neqIndex(i)=true;
                else
                    neqIndex(i)=false;
                end
            end

            cleanupListener=bdListeners(~logical(neqIndex));
            delete(cleanupListener);
            bdListeners=bdListeners(logical(neqIndex));
            bdh.Listener_Storage_=bdListeners;
        end
        function addListener(obj,topmodel)
            if any(ismember(obj.fAddedListener,topmodel))
                return;
            end

            obj.fAddedListener{end+1}=topmodel;





            blkDiagram=obj.getTopModelBlockDigramHandle(topmodel);


            h=@(srcObj,event)Simulink.ModelReference.ProtectedModel.FileDeleter.cleanup(topmodel);
            obj.hModelCloseListener=listener(blkDiagram,'CloseEvent',h);
        end
        function deleteFile(obj,fileName)
            if exist(fileName,'dir')
                slprivate('removeDir',fileName);
            elseif exist(fileName,'file')
                [~,fname,fext]=fileparts(fileName);
                if strcmp(fext,['.',mexext])
                    clear([fname,fext]);
                    try
                        builtin('delete',fileName);
                    catch

                    end
                else
                    try
                        builtin('delete',fileName);
                    catch

                    end
                end

            end
            remove(obj.fFileMap,fileName);

        end

        function AddToTopsList(obj,topmodel)
            if~any(strcmp(obj.fTopsList,topmodel))
                obj.fTopsList{end+1}=topmodel;
            end
        end
    end

    methods(Static)
        function obj=Instance()
            persistent deleter;
            if isempty(deleter)||~isvalid(deleter)
                deleter=Simulink.ModelReference.ProtectedModel.FileDeleter;
            end
            obj=deleter;
        end

        function cleanup(bdName,~)
            fDeleter=Simulink.ModelReference.ProtectedModel.FileDeleter.Instance();
            if exist(bdName,'builtin')==5
                return;
            end
            if(any(ismember(fDeleter.fTopsList,bdName)))
                fDeleter.deleteFiles(bdName);
            end
            if isempty(fDeleter.fTopsList)
                fDeleter.cleanupProperties();
            end
        end

        function cleanupMinimal(~)


            fDeleter=Simulink.ModelReference.ProtectedModel.FileDeleter.Instance();
            if isempty(fDeleter.fTopsList)
                fDeleter.cleanupProperties();
            end
        end
    end

end
