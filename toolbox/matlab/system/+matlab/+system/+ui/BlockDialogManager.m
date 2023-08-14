classdef(Sealed)BlockDialogManager<handle




    methods(Access=private)
        function this=BlockDialogManager

            mlock;
        end
    end

    methods
        function hdm=create(this,blockHandle)



            hdm=this.createOrRemoveInstance(blockHandle,'create');
        end
        function remove(this,blockHandle)

            this.createOrRemoveInstance(blockHandle,'remove');
        end
        function hdm=get(this,blockHandle)
            hdm=this.createOrRemoveInstance(blockHandle,'get');
        end
    end

    methods(Access=private)
        function hdm=createOrRemoveInstance(~,blockHandle,action)
            persistent dynDialogMap;
            if isempty(dynDialogMap)
                dynDialogMap=containers.Map('KeyType','double','ValueType','any');
            end
            switch action

            case 'create'
                if dynDialogMap.isKey(blockHandle)&&isvalid(dynDialogMap(blockHandle))
                    hdm=dynDialogMap(blockHandle);
                else

                    hdm=matlab.system.ui.DynDialogManager('Simulink','DDG',blockHandle);
                    dynDialogMap(blockHandle)=hdm;
                end
            case 'get'

                if dynDialogMap.isKey(blockHandle)&&isvalid(dynDialogMap(blockHandle))
                    hdm=dynDialogMap(blockHandle);
                else
                    hdm=[];
                end
            case 'remove'

                hdm=[];
                if dynDialogMap.isKey(blockHandle)

                    dynDialogMap.remove(blockHandle);
                end
            end
        end
    end

    methods(Static)
        function this=getInstance
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=matlab.system.ui.BlockDialogManager;
            end
            this=localObj;
        end

        function removeInstance(blkHandle)
            dlgMgr=matlab.system.ui.BlockDialogManager.getInstance;
            dlgMgr.remove(blkHandle);
        end
    end
end