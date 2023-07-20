


























function prop=extractCodeMappingInfo(config,sigName,blk_obj)

    prop=[];


    status=false;

    if~config.hasModelMapping()
        return;
    end


    aModelName=config.getModelName();


    modelMapping=config.getModelMappingTable();


    sigBlkName=slci.internal.extractSigToBlockNameMappingInfo(config,sigName);


    if~isempty(sigBlkName)...
        &&(any(strcmpi(sigBlkName,getfullname(blk_obj.Handle)))...
        ||hasSameDestination(blk_obj,sigBlkName{1}))
        [status,prop]=extractSignalMapping(modelMapping,sigName,aModelName);
    end

    if~status

        [status,prop]=extractStateMapping(modelMapping,sigName,aModelName);
    end

    if~status...
        &&any(strcmpi(blk_obj.BlockType,...
        {'DataStoreMemory','DataStoreRead','DataStoreWrite'}))

        [status,prop]=extractDataStoreMapping(modelMapping,sigName,aModelName);
    end

    if~status

        [status,prop]=extractModelParameterMapping(modelMapping,sigName,aModelName);
    end

    if~status

        [status,prop]=extractInportMapping(modelMapping,sigName,aModelName);
    end

    if~status&&strcmpi(blk_obj.BlockType,'Outport')

        [status,prop]=extractOutportMapping(modelMapping,sigName,aModelName);%#ok
    end

end


function[tf,prop]=extractSignalMapping(aModelMapping,aSigName,aModelName)
    tf=false;
    prop=[];

    if aModelMapping.hasSignal(aSigName)
        value=aModelMapping.getSignalInfo(aSigName);
        scName=value.StorageClass;
        prop=slci.internal.setStorageClassProperties(aModelName,scName);
        assert(isa(prop,'slci.WSVarInfo'));
        prop.InitialValue='';
        prop.IsStruct=false;
        prop.DataType=value.DataType;
        tf=true;
    end
end


function[tf,prop]=extractStateMapping(aModelMapping,aStateName,aModelName)
    tf=false;
    prop=[];
    if aModelMapping.hasState(aStateName)
        value=aModelMapping.getStateInfo(aStateName);
        scName=value.StorageClass;
        prop=slci.internal.setStorageClassProperties(aModelName,scName);
        assert(isa(prop,'slci.WSVarInfo'));
        prop.InitialValue='';
        prop.IsStruct=false;
        prop.DataType=value.DataType;
        tf=true;
    end
end


function[tf,prop]=extractDataStoreMapping(aModelMapping,aDataStoreName,aModelName)
    tf=false;
    prop=[];
    if aModelMapping.hasDataStore(aDataStoreName)
        value=aModelMapping.getDataStoreInfo(aDataStoreName);
        scName=value.StorageClass;
        prop=slci.internal.setStorageClassProperties(aModelName,scName);
        assert(isa(prop,'slci.WSVarInfo'));
        prop.InitialValue='';
        prop.IsStruct=false;
        prop.DataType=value.DataType;
        tf=true;
    end
end


function[tf,prop]=extractModelParameterMapping(aModelMapping,aModelParameterName,aModelName)
    tf=false;
    prop=[];
    if aModelMapping.hasModelParameter(aModelParameterName)
        value=aModelMapping.getModelParameterInfo(aModelParameterName);
        scName=value.StorageClass;
        prop=slci.internal.setStorageClassProperties(aModelName,scName);
        assert(isa(prop,'slci.WSVarInfo'));
        prop.DataType='';
        prop.InitialValue='';
        prop.IsStruct=false;
        tf=true;
    end
end


function[tf,prop]=extractInportMapping(aModelMapping,aInportName,aModelName)
    tf=false;
    prop=[];
    if aModelMapping.hasInport(aInportName)
        value=aModelMapping.getInportInfo(aInportName);
        scName=value.StorageClass;
        prop=slci.internal.setStorageClassProperties(aModelName,scName);
        assert(isa(prop,'slci.WSVarInfo'));
        prop.InitialValue='';
        prop.IsStruct=false;
        prop.DataType=value.DataType;
        tf=true;
    end
end


function[tf,prop]=extractOutportMapping(aModelMapping,aOutportName,aModelName)
    tf=false;
    prop=[];
    if aModelMapping.hasOutport(aOutportName)
        value=aModelMapping.getOutportInfo(aOutportName);
        scName=value.StorageClass;
        prop=slci.internal.setStorageClassProperties(aModelName,scName);
        assert(isa(prop,'slci.WSVarInfo'));
        prop.InitialValue='';
        prop.IsStruct=false;
        prop.DataType=value.DataType;
        tf=true;
    end
end



function tf=hasSameDestination(aBlkObj,aSigBlkName)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    tf=false;
    if isempty(aSigBlkName)
        return;
    end
    sigBlkObj=get_param(aSigBlkName,'Object');
    if~strcmpi(sigBlkObj.BlockType,'Inport')
        return;
    end
    if~strcmpi(aBlkObj.BlockType,'Inport')
        return;
    end
    try
        sigBlkDst=slci.internal.getActualDst(sigBlkObj.Handle,0);




        if isempty(sigBlkDst)
            portObj=get_param(sigBlkObj.PortHandles.Outport,'Object');
            sigDstPort=portObj.getGraphicalDst();
            sigBlkDstName=get_param(sigDstPort,'Parent');
            sigBlkDst=get_param(sigBlkDstName,'Handle');


            if iscell(sigBlkDst)
                sigBlkDst=cell2mat(sigBlkDst);
            end
        else

            sigBlkDst=sigBlkDst(:,1);
        end

        blkDst=slci.internal.getActualDst(aBlkObj.Handle,0);


        if~isempty(blkDst)
            blkDst=blkDst(:,1);
        end



        for i=1:numel(blkDst)
            if~isempty(find(sigBlkDst==blkDst(i),1))
                tf=true;
                return;
            end
        end
    catch
    end
end