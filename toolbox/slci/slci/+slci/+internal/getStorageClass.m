






























function sc=getStorageClass(config,blk_obj,sig_obj,sig_name)

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok
    sc=[];

    ws_vars=config.getWSVarInfoTable;
    if(isKey(ws_vars,sig_name))
        blk_full_name=blk_obj.getFullName;
        vars=ws_vars(sig_name);
        if(isKey(vars,blk_full_name))
            sc=vars(blk_full_name);
        else


            if(slci.internal.isSynthesized(blk_obj)...
                &&strcmp(blk_obj.BlockType,'DataStoreMemory'))
                users=blk_obj.DSReadWriteBlocks;
                if(~isempty(users))
                    user_obj=get_param(users(1).handle,'Object');
                    blk_full_name=user_obj.getFullName;
                    if isKey(vars,blk_full_name)
                        sc=vars(blk_full_name);
                    end




                end


            elseif isModelReferenceBlockSynthesized(blk_obj)
                parent_full_name=blk_obj.getParent.getFullName;
                if(isKey(vars,parent_full_name))
                    sc=vars(parent_full_name);
                end
            end
        end
    end


    if(isempty(sc)&&~isempty(sig_obj))
        sc=slci.internal.extractDataObjectInfo(...
        config.getModelName(),sig_obj,blk_obj.getFullName);
        sc.RTWName=sig_name;
    end


    isSCAutoMigrationOn=slfeature('AutoMigrationIM')==1;

    if isSCAutoMigrationOn
        if(isempty(sc)&&isempty(sig_obj))
            isInportBlock=~isempty(blk_obj)...
            &&strcmp(blk_obj.BlockType,'Inport');
            isMappedSignal=(config.hasModelMapping()...
            &&config.getModelMappingTable().hasSignal(sig_name));
            if isInportBlock&&~isMappedSignal
                mapName=blk_obj.getRTWName;
            else
                mapName=sig_name;
            end
            sc=slci.internal.extractCodeMappingInfo(...
            config,mapName,blk_obj);
            if~isempty(sc)
                sc.RTWName=sig_name;
            end
        end
        if(~isempty(sc)...
            &&strcmpi(sc.StorageClass,'Auto')...
            &&isempty(sig_obj))


            tmpSC=slci.internal.extractCodeMappingInfo(...
            config,sig_name,blk_obj);
            if~isempty(tmpSC)...
                &&~strcmpi(tmpSC.StorageClass,'Auto')
                sc.StorageClass=tmpSC.StorageClass;
            end

        end
        if(~isempty(sc))&&(isempty(sc.DataType))
            sc.DataType='auto';
        end
    end



    if~isempty(sc)
        try
            [sc.InitialValue,is_uniform_type]=slci.internal.flattenVariable(sc.InitialValue);
            if~is_uniform_type
                sc.InitialValue=0;
            end
        catch ME %#ok to not re-throw
            sc.InitialValue=0;
        end
    end
end

















function out=isModelReferenceBlockSynthesized(blk_obj)
    out=false;
    blk_name=get_param(blk_obj.Handle,'Name');
    parent_object=blk_obj.getParent;
    if~isempty(parent_object)
        parent_name=get_param(parent_object.Handle,'Name');

        out=strcmpi(get_param(blk_obj.Handle,'BlockType'),'ModelReference')...
        &&slci.internal.isSynthesized(blk_obj)...
        &&slci.internal.isSynthesized(parent_object)...
        &&strcmpi(blk_name,parent_name)...
        &&strcmpi(get_param(parent_object.Handle,'BlockType'),'SubSystem')...
        &&strcmpi(slci.internal.getSubsystemType(parent_object),'Function-call');
    end
end

