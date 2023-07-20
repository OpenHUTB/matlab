function candidateSignals=getInvalidSignalObjectStorageClass(sys)





    candidateSignals=[];


    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(sys,'findall','on','RegExp','On','Type','Block');
    if slfeature('AutoMigrationIM')<1
        for ii=1:numel(blocks)
            portHandles=get_param(blocks(ii),...
            'PortHandles');
            outportHandles=portHandles.Outport;

            for j=1:length(outportHandles)
                sigHandle=outportHandles(j);
                sigName=get_param(sigHandle,'Name');
                if~isempty(sigName)
                    sigScope=get_param(sigHandle,'StorageClass');
                    if invalidScope(sigScope)
                        candidateSignals(end+1)=sigHandle;%#ok<AGROW>
                    end
                end
            end
        end
    else
        modelMapping=Simulink.CodeMapping.getCurrentMapping(bdroot);
        if~isempty(modelMapping)
            defaultMapping=modelMapping.DefaultsMapping;
            if~isempty(modelMapping.Signals)
                signals=modelMapping.Signals;

                namesCell=cellstr(char(signals.OwnerBlockPath));
                [~,order]=sort(namesCell);
                signals=signals(order);
                for i=1:length(signals)
                    signalMapping=signals(i);
                    if~isempty(signalMapping.MappedTo.StorageClass)
                        storageClassUUID=signalMapping.MappedTo.StorageClass.UUID;
                        scName=defaultMapping.getGroupNameFromUuid(storageClassUUID);
                        if invalidScope(scName)
                            candidateSignals(end+1)=signalMapping.PortHandle;%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end

function val=invalidScope(scope)



    val=false;
    if strcmpi(scope,'ExportedGlobal')||...
        strcmpi(scope,'ImportedExtern')||...
        strcmpi(scope,'ImportedExternPointer')
        val=true;
    end
end
