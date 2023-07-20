classdef ComponentToVariantConverter<handle









    properties(Access=protected)
        BlockHandle;
    end

    methods(Access=public)
        function obj=ComponentToVariantConverter(blockHandle)
            obj.BlockHandle=blockHandle;
        end

        function varCompHdl=convert(obj)
            if(systemcomposer.sync.transaction.model.TransactionFeature.isOn)
                varCompHdl=pluginTransactionConvert(obj);
            else
                varCompHdl=pluginDetachReattachConvert(obj);
            end
        end
    end

    methods(Access=private)
        function varCompHdl=pluginDetachReattachConvert(obj)



            archPluginTxn=systemcomposer.internal.arch.internal.ArchitecturePluginTransaction(get_param(bdroot(obj.BlockHandle),'Name'));

            varCompHdl=systemcomposer.internal.arch.internal.ComponentToVariantConverter.synchronizeSimulink(obj.BlockHandle);
            systemcomposer.internal.arch.internal.ComponentToVariantConverter.synchronizeSystemComposer(obj.BlockHandle,varCompHdl);

            delete(archPluginTxn);
        end

        function varCompHdl=pluginTransactionConvert(obj)








            bdHandle=bdroot(obj.BlockHandle);
            pluginTxn=systemcomposer.internal.SLPluginTransaction(bdHandle,...
            systemcomposer.sync.transaction.model.VariantComponentConversionEvent.StaticMetaClass);
            pluginTxn.addEventData('p_ComponentHandle',obj.BlockHandle);



            varCompHdl=systemcomposer.internal.arch.internal.ComponentToVariantConverter.synchronizeSimulink(obj.BlockHandle);



            pluginTxn.addEventData('p_VariantComponentHandle',varCompHdl,...
            'p_IsProcessed',true);


            pluginTxn.commitTransaction;
        end
    end

    methods(Static,Access=public)
        function varCompHdl=synchronizeSimulink(blockHandle)

            portPlacementSchema=get_param(blockHandle,'PortSchema');










            oldAllowedBlockH=get_param(bdroot(blockHandle),'AllowedBlockHandlesForConvertToVariant');
            newAllowedBlockH=[oldAllowedBlockH,blockHandle];
            set_param(bdroot(blockHandle),'AllowedBlockHandlesForConvertToVariant',newAllowedBlockH);
            c=onCleanup(@()set_param(bdroot(blockHandle),'AllowedBlockHandlesForConvertToVariant',oldAllowedBlockH));





            txn=systemcomposer.internal.SubdomainBlockValidationSuspendTransaction(bdroot(blockHandle));
            prunerDisabler=systemcomposer.internal.ScopedUnconnectedBusPortBlockPrunerDisabler(bdroot(blockHandle));
            varCompHdl=Simulink.VariantManager.convertToVariant(blockHandle);
            prunerDisabler.delete();
            txn.commit();


            set_param(varCompHdl,'PortSchema',portPlacementSchema);
        end

        function synchronizeSystemComposer(blockHandle,varCompHdl)
            zcTxnInfoModel=systemcomposer.sync.transaction.model.TransactionInfo.createTransactionInfoModel;
            zcTxnInfo=systemcomposer.sync.transaction.model.TransactionInfo.getTransactionInfo(zcTxnInfoModel);

            varCompTxnEvent=zcTxnInfo.addNewEvent(systemcomposer.sync.transaction.model.VariantComponentConversionEvent.StaticMetaClass);
            varCompTxnEvent.p_ComponentHandle=blockHandle;
            varCompTxnEvent.p_VariantComponentHandle=varCompHdl;
            varCompTxnEvent.p_IsProcessed=true;

            modelName=get_param(bdroot(varCompHdl),'Name');
            builtin('_run_zc_sync_transaction_operation',modelName,zcTxnInfoModel);
        end
    end
end


