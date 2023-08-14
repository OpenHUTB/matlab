classdef ExclusionEditorUIService













    properties(Access=private)
        m_modelFilterMap=containers.Map('KeyType','char','ValueType','any');
    end


    methods(Static)
        function instance=getInstance()

            persistent uniqueInstance;
            if isempty(uniqueInstance)
                uniqueInstance=Advisor.ExclusionEditorUIService();
            end
            instance=uniqueInstance;
        end
    end


    methods
        function exclusioneditorUI=getExclusionEditor(this,modelName)




            if this.m_modelFilterMap.isKey(modelName)
                exclusioneditorUI=this.m_modelFilterMap(modelName);
            else
                exclusioneditorUI=Advisor.ExclusionEditorWindow(modelName);
                exclusioneditorUI.initiate();
                this.m_modelFilterMap(modelName)=exclusioneditorUI;
            end

        end



        function remove(this,modelName)

            if this.m_modelFilterMap.isKey(modelName)
                this.m_modelFilterMap.remove(modelName);
            end
        end


        function removeAll(this)
            this.m_modelFilterMap.remove(this.m_modelFilterMap.keys());
        end



        function models=getModels(this)

            models=this.m_modelFilterMap.keys();
        end

        function status=isKey(this,key)

            status=this.m_modelFilterMap.isKey(key);
        end



        function url=getURL(this,relPath)

            connector.ensureServiceOn;

            url=connector.getUrl(relPath);
        end



    end

end
