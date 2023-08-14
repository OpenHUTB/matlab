classdef(Hidden,Sealed)VMgrUITSContext<dig.CustomContext







    properties(Hidden,SetAccess=private)
        App(1,1)slvariants.internal.manager.ui.toolstrip.VMgrUITSApp;
    end

    properties(SetObservable=true)
        VarConfigsObjName char='';
        TempVarConfigsObjName char=' ';
    end

    methods(Hidden)
        function obj=VMgrUITSContext()
            app=struct;
            app.name='VMgrUITSContextApp';
            app.defaultContextType='VMgrUITSContext';
            app.defaultTabName='';
            app.priority=0;

            obj@dig.CustomContext(app);
            obj.TypeChain={app.defaultContextType};
        end

        function setApp(obj,aBDHandle)
            obj.App=slvariants.internal.manager.ui.toolstrip.VMgrUITSApp(aBDHandle);
        end

        function setNavigationInfo(obj,navInfo)
            obj.App.NavigationInfo=navInfo;
        end

        function setBlocksViewInfo(obj,blksViewInfo)
            obj.App.BlocksViewInfo=blksViewInfo;
        end

        function handle=getModelHandle(obj)
            handle=obj.App.ModelHandle;
        end

        function isVMOpen=getIsVMOpen(obj)
            isVMOpen=obj.App.IsVMOpen;
        end

        function setIsVMOpen(obj,isVMOpen)
            obj.App.IsVMOpen=isVMOpen;
        end

        function navInfo=getNavigationInfo(obj)
            navInfo=obj.App.NavigationInfo;
        end

        function blkInfo=getBlocksViewInfo(obj)
            blkInfo=obj.App.BlocksViewInfo;
        end

        function setVarConfigsObjName(obj,name)
            obj.VarConfigsObjName=name;
        end

        function setTempVarConfigsObjName(obj,name)
            obj.TempVarConfigsObjName=name;
        end

        function delete(obj)
            obj.App.delete();
        end

    end

    methods(Static)
        function callSetApp(aCtx,aBDHandle)
            setApp(aCtx,aBDHandle);
        end
    end

end


