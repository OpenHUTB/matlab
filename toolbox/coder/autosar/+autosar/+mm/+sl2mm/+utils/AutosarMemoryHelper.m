classdef AutosarMemoryHelper<handle






    methods(Static)

        function[isArTypedPIM,isStatic]=isAutosarMemoryVariable(var)
            isArTypedPIM=false;
            isStatic=false;

            implementation=var.Implementation;
            if isempty(implementation)||~isa(implementation,'coder.descriptor.AutosarMemoryExpression')
                return
            end

            if strcmp(implementation.DataAccessMode,'StaticMemory')
                isStatic=true;
            elseif strcmp(implementation.DataAccessMode,'ArTypedPerInstanceMemory')
                isArTypedPIM=true;
            end
        end

        function[name,variantInfo]=extractInformationFromMemoryExpr(var,memExpr)
            name=memExpr.VariableName;
            variantInfo=var.VariantInfo;
        end



        function[region,name,variantInfo]=getAutosarVariableInfo(var)
            variantInfo=[];

            region=var.Implementation;
            if isa(region,'coder.descriptor.AutosarMemoryExpression')&&isa(region.BaseRegion,'coder.descriptor.Variable')




                [name,variantInfo]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.extractInformationFromMemoryExpr(var,region);
                return;
            end
            while~isempty(region.BaseRegion)&&isa(region.BaseRegion,'coder.descriptor.StructExpression')
                region=region.BaseRegion;
            end

            if isa(region.BaseRegion,'coder.descriptor.Variable')
                region=region.BaseRegion;
            end


            if isa(region,'coder.descriptor.AutosarMemoryExpression')
                [name,variantInfo]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.extractInformationFromMemoryExpr(var,region);
            else
                name=region.Identifier;
            end
        end

        function out=getBlockBySID(bhm,sid)
            blks=bhm.getBlocksBySID(sid);
            out=coder.descriptor.GraphicalBlock.empty;
            if~isempty(blks)
                out=blks(1);
            end
        end






        function[dataType,handle]=getHandleForAutosarMemoryMapping(codeDesc,var)
            handle=-1;
            dataType=[];
            bhm=codeDesc.getBlockHierarchyMap;
            blk=autosar.mm.sl2mm.utils.AutosarMemoryHelper.getBlockBySID(bhm,var.SID);
            if isempty(blk)

                return;
            end



            if isequal(blk.Type,'DataStoreRead')||...
                isequal(blk.Type,'DataStoreWrite')



                dataStoreName=get_param(blk.Path,'DataStoreName');
                [~,signalObj,isModelWorkspace]=autosar.utils.Workspace.objectExistsInModelScope(codeDesc.ModelName,dataStoreName);
                if~isempty(signalObj)&&isModelWorkspace
                    dataType='SynthesizedDataStore';
                    handle=get_param(blk.Path,'handle');
                    return
                end
            elseif isequal(blk.Type,'DataStoreMemory')
                dataType='DSM';
                handle=get_param(blk.Path,'handle');
                return
            end

            isSignal=false;
            idx=-1;

            for i=1:blk.DataOutputPorts.Size
                if~isempty(blk.DataOutputPorts(i).DataInterfaces)&&...
                    (blk.DataOutputPorts(i).DataInterfaces.Size>0)
                    if isequal(var,blk.DataOutputPorts(i).DataInterfaces(1))
                        isSignal=true;
                        idx=i;
                        break;
                    end
                end
            end

            if isSignal
                dataType='Signal';
                portHs=get_param(blk.Path,'PortHandles');
                handle=portHs.Outport(idx);
                return
            end


            isState=false;
            for i=1:blk.DiscreteStates.Size
                if isequal(var,blk.DiscreteStates(i))
                    isState=true;
                    break;
                end
            end

            if isState
                dataType='State';
                handle=get_param(blk.Path,'handle');
                return
            end
        end



        function sigObj=getSignalObjectForAutosarMemory(modelName,dataType,portOrBlkH)
            sigObj=[];

            if portOrBlkH<0
                return;
            end

            switch dataType
            case 'Signal'
                sigName=get_param(portOrBlkH,'Name');
                if~isempty(sigName)&&strcmp(get_param(portOrBlkH,'MustResolveToSignalObject'),'on')
                    [~,sigObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,sigName);
                else
                    sigObj=get_param(portOrBlkH,'SignalObject');
                end
            case 'State'
                if strcmp(get_param(portOrBlkH,'BlockType'),'S-Function')



                    return
                end
                stateName=get_param(portOrBlkH,'StateName');
                if~isempty(stateName)&&strcmp(get_param(portOrBlkH,'StateMustResolveToSignalObject'),'on')
                    [~,sigObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,stateName);
                else
                    sigObj=get_param(portOrBlkH,'StateSignalObject');
                end
            case 'DSM'
                dsmName=get_param(portOrBlkH,'DataStoreName');
                if strcmp(get_param(portOrBlkH,'StateMustResolveToSignalObject'),'on')
                    [~,sigObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,dsmName);
                else
                    sigObj=get_param(portOrBlkH,'StateSignalObject');
                end
            case 'SynthesizedDataStore'
                dsmName=get_param(portOrBlkH,'DataStoreName');
                [~,sigObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,dsmName);
            otherwise
                assert(false,'Unhandled model data type for autosar variable');
            end
        end
    end
end


