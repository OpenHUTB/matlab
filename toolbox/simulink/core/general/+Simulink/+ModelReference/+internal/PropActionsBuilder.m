classdef PropActionsBuilder




    methods(Static=true)
        function actions=build(blkPath,argName,argValue,isFromDialog)



            resetAction=Simulink.ModelReference.internal.PropActionResetToDefault.build(...
            blkPath,argName,argValue,isFromDialog);


            navAction=Simulink.ModelReference.internal.PropActionNavToDefault.build(...
            blkPath,argName,argValue,isFromDialog);


            createAction=Simulink.ModelReference.internal.PropActionCreateVarFromDefault.build(...
            blkPath,argName,argValue,isFromDialog);

            actions=[navAction,createAction,resetAction];
        end

        function actions=buildAndPrepend(...
            blkPath,argName,argValue,isFromDialog,otherActions)



            locActions=Simulink.ModelReference.internal.PropActionsBuilder.build(...
            blkPath,argName,argValue,isFromDialog);
            actions=[locActions,otherActions];
        end

        function actions=buildAndAppend(...
            blkPath,argName,argValue,isFromDialog,otherActions)



            locActions=Simulink.ModelReference.internal.PropActionsBuilder.build(...
            blkPath,argName,argValue,isFromDialog);
            actions=[otherActions,locActions];
        end
    end
end
