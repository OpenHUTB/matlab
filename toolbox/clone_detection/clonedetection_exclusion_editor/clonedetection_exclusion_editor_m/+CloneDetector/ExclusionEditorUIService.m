classdef ExclusionEditorUIService<handle









    properties(Constant,Access=protected)
        m_modelExclusionMap=containers.Map('KeyType','char','ValueType','any');
    end

    methods(Static)
        function instance=getInstance()

            persistent uniqueInstance;
            if isempty(uniqueInstance)
                uniqueInstance=CloneDetector.ExclusionEditorUIService();
            end
            instance=uniqueInstance;
        end
    end

    methods
        function exclusioneditorUI=getExclusionEditor(this,modelName)




            if this.m_modelExclusionMap.isKey(modelName)
                exclusioneditorUI=this.m_modelExclusionMap(modelName);
            else
                exclusioneditorUI=CloneDetector.ExclusionEditorWindow(modelName);
                exclusioneditorUI.initiate();
                this.m_modelExclusionMap(modelName)=exclusioneditorUI;
            end
        end

        function remove(this,modelName)

            if this.m_modelExclusionMap.isKey(modelName)
                this.m_modelExclusionMap.remove(modelName);
            end
        end

        function removeAll(this)
            this.m_modelExclusionMap.remove(this.m_modelExclusionMap.keys());
        end

        function models=getModels(this)

            models=this.m_modelExclusionMap.keys();
        end

        function isAvailable=isExclusionEditorAvailable(this,modelName)


            isAvailable=this.m_modelExclusionMap.isKey(modelName);
        end




        function url=getURL(~,relPath)
            connector.ensureServiceOn;
            url=connector.getUrl(relPath);
        end
    end
end


