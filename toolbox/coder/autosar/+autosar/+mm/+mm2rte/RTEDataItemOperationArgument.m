classdef RTEDataItemOperationArgument<handle




    properties(SetAccess='private',GetAccess='public')
        ArgName;
        TypeInfo;
        Direction;
        IsServer;
    end

    methods(Access='public')
        function this=RTEDataItemOperationArgument(argName,direction,typeInfo,isServer)
            this.ArgName=argName;
            this.Direction=direction;
            this.TypeInfo=typeInfo;
            this.IsServer=isServer;
        end

        function argStr=getInArgStr(this)
            typeInfo=this.TypeInfo;

            addConstIfNeeded=true;
            argType=autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
            typeInfo.UsePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
            typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);
            argStr=sprintf('%s %s',argType,this.ArgName);
        end

        function argStr=getOutOrInOutArgStr(this)
            typeInfo=this.TypeInfo;

            usePointerIO=true;

            addConstIfNeeded=false;
            argType=autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
            usePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
            typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);
            argStr=sprintf('%s %s',argType,this.ArgName);
        end
    end
end
