function datapathCopy(block)
    success=false;
    tree=serdes.internal.callbacks.getSerDesTree(block);
    if~isempty(tree)
        maskObj=Simulink.Mask.get(block);
        blockInstanceName=get_param(block,'Name');
        if~tree.containsBlock(blockInstanceName)
            systemObject=serdes.internal.callbacks.getSystemObject(block);
            if~isempty(systemObject)
                amiParameters=systemObject.getAMIParameters();
                tree.addBlock(blockInstanceName,amiParameters);
            end
        end
        libType=serdes.internal.callbacks.getLibraryBlockType(block);
        if~isempty(libType)
            success=true;
            set_param(block,'LinkStatus','none');

            if any(contains(["CTLE","DFECDR","FFE"],libType))
                modeGetMap=containers.Map(...
                [0,1,2],...
                {'Off','Fixed','Adapt'});
            else
                modeGetMap=containers.Map(...
                [0,1],...
                {'Off','On'});
            end

            savedNameIdx=0;
            parameterNames={maskObj.Parameters.Name};
            for idx=1:size(parameterNames,2)
                parameterName=char(cellstr(parameterNames{idx}));

                if strcmp(parameterName,'Mode')

                    newValue=modeGetMap(tree.getCurrentValue(blockInstanceName,parameterName));
                elseif strcmp(parameterName,'TapWeights')
                    newValue=tree.getTapWeightsFromBlock(blockInstanceName);
                elseif strcmp(parameterName,'SavedName')
                    savedNameIdx=idx;
                    continue
                else
                    newValue=tree.getCurrentValue(blockInstanceName,parameterName);
                end
                if~isempty(newValue)
                    if~ischar(newValue)
                        newValue=mat2str(newValue);
                    end
                    if~strcmp(maskObj.Parameters(idx).Value,newValue)

                        if strcmp(parameterName,'ConfigSelect')
                            configList=maskObj.Parameters(idx).TypeOptions;
                            if any(contains(configList,newValue))
                                maskObj.Parameters(idx).Value=newValue;
                            end
                        else
                            maskObj.Parameters(idx).Value=newValue;
                        end
                    end
                end
            end

            if savedNameIdx>0&&...
                ~strcmp(maskObj.Parameters(savedNameIdx).Value,blockInstanceName)
                serdes.internal.callbacks.datapathRename(block);
            end
        end
    end
    if~success
        serdes.internal.callbacks.deliverInfoNotification(block,...
        'serdes:callbacks:ModelWorkspaceMissingTree','SerDesTree');
    end
end
