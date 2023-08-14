


classdef Manager<handle

    properties(Constant,Hidden)
        fIconPath=fullfile(matlabroot,...
        'toolbox','slci','slci_view',...
        'resources','icons','ReviewImage512.png');
        fContextRegistryRoot=fullfile(matlabroot,...
        'toolbox','slci','slci_view',...
        'resources','registry');
    end


    properties(Access=private)

        fInitialized=false;

fViews

fData

        fListeners={}


        fRegisteredContexts={};

        fDebugMode=false;
    end

    methods(Static)

        obj=getInstance
    end


    methods(Access=private)

        function obj=Manager()

            obj.init();
        end


        function configureContexts(obj)
            files=dir(fullfile(obj.fContextRegistryRoot,'*.json'));
            for i=1:numel(files)
                confFileName=fullfile(files(i).folder,files(i).name);
                obj.registerContext(confFileName);
            end
        end


        function registerContext(obj,filename)
            jsontext=fileread(filename);
            jsonStruct=jsondecode(jsontext);
            obj.fRegisteredContexts{end+1}=slci.view.ViewContext(jsonStruct);
        end
    end

    methods

        init(obj)


        turnOnView(obj,studio)
        turnOffView(obj,editor)


        vw=getView(obj,studio)


        flag=isAvailable(obj,studio);
    end

    methods(Hidden)

        open(obj,studio)


        close(obj,studio)
    end

    methods



        function out=getDebugMode(obj)
            out=obj.fDebugMode;
        end


        function setDebugMode(obj,aDebugMode)
            obj.fDebugMode=aDebugMode;
        end


        function out=hasData(obj,modelH)
            out=false;
            if~isempty(obj.fData)
                out=isKey(obj.fData,modelH);
            end
        end


        function out=getDatas(obj)
            out=obj.fData;
        end


        function out=getData(obj,modelH)
            assert(obj.hasData(modelH));
            out=obj.fData(modelH);
        end


        function addData(obj,modelH,data)
            assert(~obj.hasData(modelH));
            obj.fData(modelH)=data;
        end


        function clearData(obj,modelH)
            if obj.hasData(modelH)
                obj.getData(modelH).delete
                remove(obj.fData,modelH);
            end
        end


        function regContexts=getRegisteredContexts(obj)
            regContexts=obj.fRegisteredContexts;
        end


        function cleanup(obj,studio)
            studioT=studio.getStudioTag;
            if isKey(obj.fViews,studioT)
                remove(obj.fViews,studioT);
            end

        end


        function clearStudioData(obj,modelH)
            ks=keys(obj.fViews);
            removedKey={};
            for i=1:numel(ks)
                key=ks{i};
                ps=obj.fViews(key);
                if isequal(ps.getModelHandle,modelH)

                    removedKey{end+1}=key;%#ok
                end
            end

            remove(obj.fViews,removedKey);

        end

    end

end
