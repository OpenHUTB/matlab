





















classdef HDLTargetDriver<hdlturnkey.ip.HDLTargetDriverBase

    properties(GetAccess=public,SetAccess=protected)


        isGenericIPPlatform=false;

    end

    methods

        function obj=HDLTargetDriver(hDIDriver,workflowName)



            obj=obj@hdlturnkey.ip.HDLTargetDriverBase(hDIDriver,workflowName);

        end

    end

    methods


        function initIPPlatform(obj)








            obj.hRDList=hdlturnkey.plugin.ReferenceDesignList(obj);
            obj.hRDList.buildRDList;



            obj.hRDList.setDefaultReferenceDesign;


            lockCurrentDir(obj);
        end

    end



    methods


        function validateCell=validateTargetReferenceDesign(obj)

            validateCell={};




            validateCellReloadRD=obj.reloadReferenceDesignPlugin;
            validateCell=[validateCell,validateCellReloadRD];


            validateCellRDP=obj.validateRDPlugin;
            validateCell=[validateCell,validateCellRDP];


            validateCellCallback=hdlturnkey.plugin.runCallbackPostTargetReferenceDesign(obj.hD);
            validateCell=[validateCell,validateCellCallback];

        end
        function validateCell=reloadReferenceDesignPlugin(obj)
            if obj.isRDListLoaded



                validateCell=obj.hRDList.reloadRDPlugin;



                obj.hRDList.refreshReferenceDesign;

            end
        end

        function refreshProgrammingMethod(obj)


        end
        function refreshDefaultUseIPCache(obj)


        end
        function setHostTargetInterfaceOptions(obj,enableJTAGOption,enableEthernetAXIModelOption,enableEthernetOption)


        end


    end




end





