classdef DataSourceUtils




    methods(Static)

        function appendExternalDataSourceReferences(srcModel,destModel,copyImplicitExternalSourcesDataSources)
            load_system(srcModel);
            load_system(destModel);


            srcDD=get_param(srcModel,'DataDictionary');

            if strcmp(get_param(destModel,'DataDictionary'),'')
                set_param(destModel,'DataDictionary',srcDD);
            else
                error('appendExternalDataSourceReferences:DestHasLinkedDataDictionary','The destination model already has a data dictionary linked to it.');
            end


            if strcmp(get_param(destModel,'EnableAccessToBaseworkspace'),'off')
                bwsSetting=get_param(srcModel,'EnableAccessToBaseworkspace');
                set_param(destModel,'EnableAccessToBaseworkspace',bwsSetting);
            end


            if slfeature('SLModelBroker')>0
                srcBrokerConfig=Simulink.data.DataSourceUtils.getBrokerConfig(srcModel);
                destBrokerConfig=Simulink.data.DataSourceUtils.getBrokerConfig(destModel);

                Simulink.data.DataSourceUtils.appendBrokerExternalSources(srcBrokerConfig,destBrokerConfig,copyImplicitExternalSourcesDataSources);
            end
        end

        function copyExternalDataSourceReferences(srcModel,destModel,copyImplicitExternalSourcesDataSources)
            load_system(srcModel);
            load_system(destModel);


            srcDD=get_param(srcModel,'DataDictionary');
            set_param(destModel,'DataDictionary',srcDD);


            bwsSetting=get_param(srcModel,'EnableAccessToBaseworkspace');
            set_param(destModel,'EnableAccessToBaseworkspace',bwsSetting);


            if slfeature('SLModelBroker')>0
                srcBrokerConfig=Simulink.data.DataSourceUtils.getBrokerConfig(srcModel);
                destBrokerConfig=Simulink.data.DataSourceUtils.getBrokerConfig(destModel);

                Simulink.data.DataSourceUtils.resetBrokerExternalSources(destBrokerConfig);

                Simulink.data.DataSourceUtils.appendBrokerExternalSources(srcBrokerConfig,destBrokerConfig,copyImplicitExternalSourcesDataSources);
            end
        end

        function appendDictionarySources(dictionarySources,destModel)
            load_system(destModel);

            if slfeature('SLModelBroker')>0
                destBrokerConfig=Simulink.data.DataSourceUtils.getBrokerConfig(destModel);


                tmpModel=mf.zero.Model.createTransientModel();

                for idx=1:length(dictionarySources)
                    dictionarySource=which(dictionarySources{idx});
                    report=Simulink.data.DataSourceUtils.addExplicitExternalSource(destBrokerConfig,dictionarySource,tmpModel);
                    assert(report.Success,report.Message);
                end
            else
                ddName=get_param(destModel,'DataDictionary');

                if~isempty(ddName)



                    ddObj=Simulink.data.dictionary.open(ddName);
                    for i=1:numel(dictionarySources)
                        ddObj.addDataSource(dictionarySources{i});
                    end
                else



                    if numel(dictionarySources)>1
                        error('appendDictionarySources:multipleDDNotSupported','Multiple data dictionaries are not supported for one model');
                    elseif numel(dictionarySources)==1
                        set_param(destModel,'DataDictionary',dictionarySources{1});
                    end
                end
            end
        end
    end

    methods(Static)
        function dictionarySource=getBrokeredSLDDSource(dictionarySource)
            if~contains(dictionarySource,'#BROKEREDSLDD')
                dictionarySource=[dictionarySource,'#BROKEREDSLDD'];
            end
        end

        function report=addExplicitExternalSource(brokerConfig,dictionarySource,tmpModel)
            dictionarySource=Simulink.data.DataSourceUtils.getBrokeredSLDDSource(dictionarySource);
            report=brokerConfig.addExplicitExternalSource(dictionarySource,tmpModel);
        end

        function report=addImplicitExternalSource(brokerConfig,dictionarySource,tmpModel)
            dictionarySource=Simulink.data.DataSourceUtils.getBrokeredSLDDSource(dictionarySource);
            report=brokerConfig.addImplicitExternalSource(dictionarySource,tmpModel);
        end

        function appendBrokerExternalSources(srcBrokerConfig,destBrokerConfig,copyImplicitExternalSourcesDataSources)
            srcExplicitExternalSources=srcBrokerConfig.getExplicitExternalSourceList();
            srcImplicitExternalSources=srcBrokerConfig.getImplicitExternalSourceList();


            tmpModel=mf.zero.Model.createTransientModel();

            for idx=1:length(srcExplicitExternalSources)
                dictionarySource=which(srcExplicitExternalSources{idx});
                report=Simulink.data.DataSourceUtils.addExplicitExternalSource(destBrokerConfig,dictionarySource,tmpModel);
                assert(report.Success,report.Message);
            end

            if copyImplicitExternalSourcesDataSources
                for idx=1:length(srcImplicitExternalSources)
                    dictionarySource=which(srcImplicitExternalSources{idx});
                    report=Simulink.data.DataSourceUtils.addImplicitExternalSource(destBrokerConfig,dictionarySource,tmpModel);
                    assert(report.Success,report.Message);
                end
            end
        end

        function resetBrokerExternalSources(brokerConfig)
            brokerConfig.resetExplicitExternalSources();
            brokerConfig.resetImplicitExternalSources();
        end

        function brokerConfig=getBrokerConfig(model)
            bdMCOSObj=get_param(model,'slobject');
            broker=bdMCOSObj.getBroker();
            brokerConfig=broker.getActiveBrokerConfig;
        end
    end
end
