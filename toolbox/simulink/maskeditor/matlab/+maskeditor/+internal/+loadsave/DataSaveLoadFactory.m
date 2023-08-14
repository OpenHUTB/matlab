

classdef DataSaveLoadFactory<handle



    properties
        m_MEInstance;
        m_ConfigManager;
        m_Loader;
        m_ParameterPromotionLoader;
    end

    methods

        function obj=DataSaveLoadFactory(aMEInstance)
            obj.m_MEInstance=aMEInstance;
            obj.m_ConfigManager=aMEInstance.m_ConfigLoader.m_ConfigManager;
            obj.m_Loader=[];
        end

        function loadAppData(this)
            aLoadSourceFile=this.m_ConfigManager.getLoadSourceFile();
            this.m_Loader=eval([aLoadSourceFile,'(this.m_MEInstance)']);
        end

        function loadParameterPromotionData(this,args)
            if this.m_ConfigManager.isParameterPromotionSupported()
                aPPLoadSourceFile=this.m_ConfigManager.getPPLoadSourceFile();
                this.m_ParameterPromotionLoader=eval([aPPLoadSourceFile,'(this.m_MEInstance,args)']);
            end
        end

        function bSuccess=saveAppData(this)
            aSaveSourceFile=this.m_ConfigManager.getSaveSourceFile();
            bSuccess=eval([aSaveSourceFile,'(this.m_MEInstance)']);
        end

        function importMask(this,aMaskObjToImport)
            this.m_Loader.importMask(aMaskObjToImport);
        end

        function createMaskOnLink(this)
            this.m_Loader.createMaskOnLink();
        end

        function evaluateBlock(this)
            this.m_Loader.evaluateBlock();
        end

        function refreshModelMaskEditor(this,aSystemHandle,aData)
            this.m_Loader.refreshModelMaskEditor(aSystemHandle,aData);
        end

        function loadParameterPromotionDataForASubsystem(this,args)
            this.m_ParameterPromotionLoader.addPromotionDataForASubsystem(args);
        end

        function loadAllParameterPromotionData(this)
            this.m_ParameterPromotionLoader.loadAllParameterPromotionData();
        end

    end
end

