

classdef ConstraintManagerInterface



    properties
        m_MEData;
        m_CMDataLoaderObj;
    end

    methods
        function obj=ConstraintManagerInterface(aBlockHandle,aMF0Model,aMEData)
            obj.m_MEData=aMEData;



            obj.m_CMDataLoaderObj=constraint_manager.ConstraintManagerDataLoader(aMF0Model,aBlockHandle);
            obj.m_MEData.constraintManagerTopObject=obj.m_CMDataLoaderObj.getConstraintManagerModelData();
        end

        function onImportMask(this,aMaskObj)
            this.m_CMDataLoaderObj.onImportMask(aMaskObj);
            this.m_MEData.constraintManagerTopObject=this.m_CMDataLoaderObj.getConstraintManagerModelData();
        end

        function addMATFileAndConstraintsToModel(this,sharedConstraintList,product,matFileName,matFilePath)

            this.m_CMDataLoaderObj.addNewMATFileToModel(sharedConstraintList,product,matFileName,matFilePath);
        end

    end
end

