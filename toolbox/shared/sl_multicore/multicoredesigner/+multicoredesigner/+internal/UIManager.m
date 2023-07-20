classdef UIManager<handle





    properties
PerspectiveManager
MulticoreUIMap
    end

    methods(Access=private)
        function obj=UIManager()
            obj.MulticoreUIMap=containers.Map('KeyType','double','ValueType','any');
        end
    end

    methods(Static=true)


        function singleton=getInstance()
            mlock;
            persistent multicoreUiManager;
            if isempty(multicoreUiManager)||~isvalid(multicoreUiManager)
                multicoreUiManager=multicoredesigner.internal.UIManager;
            end
            singleton=multicoreUiManager;
        end
    end

    methods
        function initPerspective(obj)


            if isempty(obj.PerspectiveManager)
                obj.PerspectiveManager=multicoredesigner.internal.PerspectiveManager();

                addlistener(obj.PerspectiveManager,'MulticorePerspectiveChange',@obj.perspectiveChangeHandler);
            end
        end

        function openPerspective(obj,modelH)


            st=getStudio(obj,modelH);
            if isempty(st)

                return
            end

            if isempty(obj.PerspectiveManager)

                initPerspective(obj);
            end
            if~isPerspectiveEnabled(obj,modelH)
                togglePerspective(obj,modelH);
            end
        end

        function closePerspective(obj,modelH)


            if isempty(obj.PerspectiveManager)


                initPerspective(obj);
            end
            if isPerspectiveEnabled(obj,modelH)
                togglePerspective(obj,modelH);
            end
        end

        function createMulticorePerspective(obj,modelH)


            obj.MulticoreUIMap(modelH)=multicoredesigner.internal.MulticoreUI(modelH);
        end

        function destroyMulticorePerspective(obj,modelH)


            if isKey(obj.MulticoreUIMap,modelH)
                uiObj=obj.MulticoreUIMap(modelH);
                delete(uiObj);
                remove(obj.MulticoreUIMap,modelH);
            end

            if~isempty(obj.PerspectiveManager)
                removeFromPerspectiveMap(obj.PerspectiveManager,modelH);
            end
        end

        function tf=isPerspectiveEnabled(obj,modelH)


            if isempty(obj.PerspectiveManager)
                tf=false;
            else
                tf=getStatus(obj.PerspectiveManager,modelH);
            end
        end

        function togglePerspective(obj,modelH)


            if~isempty(obj.PerspectiveManager)
                togglePerspective(obj.PerspectiveManager,modelH);
            end
        end

        function perspectiveChangeHandler(obj,~,eventData)


            perspectiveOn=eventData.state;
            modelH=eventData.modelH;

            if perspectiveOn


                if isKey(obj.MulticoreUIMap,modelH)

                    destroyMulticorePerspective(obj,modelH);
                end
                createMulticorePerspective(obj,modelH);

            else

                destroyMulticorePerspective(obj,modelH);
            end
        end

        function p=getMulticoreUI(obj,modelH)


            p=[];
            if isKey(obj.MulticoreUIMap,modelH)
                p=obj.MulticoreUIMap(modelH);
            end
        end

        function st=getStudio(~,modelH)
            st=[];
            das=DAS.Studio.getAllStudios();


            for i=1:length(das)
                da=das{i};
                sa=da.App;
                if sa.blockDiagramHandle==modelH
                    st=da;
                    break;
                end
            end
        end
    end
end


