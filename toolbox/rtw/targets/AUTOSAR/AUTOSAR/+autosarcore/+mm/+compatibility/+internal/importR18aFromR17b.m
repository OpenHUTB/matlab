function importR18aFromR17b(transformer)



    function m3iModel=postModelTransform(m3iModel)




        childSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(m3iModel,...
        Simulink.metamodel.arplatform.interface.FlowData.MetaClass,true);
        for id=1:childSeq.size()
            dataElement=childSeq.at(id);
            extToolInfo=dataElement.getExternalToolInfo('ARXML_HandleInvalidInfo');
            if~isempty(extToolInfo.tool)


                handleInvalidExtToolInfo=regexp(extToolInfo.externalId,'handleInvalid#(\w*)','tokens');
                if~isempty(handleInvalidExtToolInfo)
                    invalidationPolicyString=handleInvalidExtToolInfo{1}{1};

                    switch invalidationPolicyString
                    case 'KEEP'
                        dataElement.InvalidationPolicy=...
                        Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.Keep;
                    case 'REPLACE'
                        dataElement.InvalidationPolicy=...
                        Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.Replace;
                    case 'DONT'
                        dataElement.InvalidationPolicy=...
                        Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.DontInvalidate;
                    otherwise
                        dataElement.InvalidationPolicy='None';
                    end
                end
            end
        end
    end

    transformer.setPostModelTransform(@postModelTransform);
    transformer.renameAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','aliveTimeOut','AliveTimeout');
    transformer.renameAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','handleNeverReceived','HandleNeverReceived');
    transformer.renameAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','enableUpdate','EnableUpdate');
end


