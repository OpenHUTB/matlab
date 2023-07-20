classdef ExclusionBackwardCompatibilityService








    properties(Access=private)
        m_modelConversionStatusMap=containers.Map('KeyType','char','ValueType','any');
    end


    methods(Static)
        function instance=getInstance()

            persistent uniqueInstance;
            if isempty(uniqueInstance)
                uniqueInstance=slcheck.ExclusionBackwardCompatibilityService();
            end
            instance=uniqueInstance;
        end
    end


    methods
        function status=getForceConversionStatus(this,modelName)

            if this.m_modelConversionStatusMap.isKey(modelName)
                status=this.m_modelConversionStatusMap(modelName);
            else
                status=false;
                this.m_modelConversionStatusMap(modelName)=status;
            end
        end


        function setForceConversionStatus(this,modelName,inpStatus)

            this.m_modelConversionStatusMap(modelName)=inpStatus;

        end


    end

end
