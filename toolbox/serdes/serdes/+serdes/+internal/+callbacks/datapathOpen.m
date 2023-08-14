





function datapathOpen(block,varargin)
    tree=serdes.internal.callbacks.getSerDesTree(block);
    if~isempty(tree)
        maskObj=Simulink.Mask.get(block);
        blockInstanceName=get_param(block,'Name');



        libType=serdes.internal.callbacks.getLibraryBlockType(block);
        if~isempty(libType)




            if any(contains(["CTLE","DFECDR","FFE"],libType))
                modeGetMap=containers.Map(...
                [0,1,2],...
                {'Off','Fixed','Adapt'});
            else
                modeGetMap=containers.Map(...
                [0,1],...
                {'Off','On'});
            end



            parameterNames={maskObj.Parameters.Name};
            for idx=1:size(parameterNames,2)
                parameterName=char(cellstr(parameterNames{idx}));

                if strcmp(parameterName,'Mode')

                    newValue=modeGetMap(tree.getCurrentValue(blockInstanceName,parameterName));
                elseif strcmp(parameterName,'TapWeights')
                    newValue=tree.getTapWeightsFromBlock(blockInstanceName);
                elseif strcmp(parameterName,'SavedName')
                    continue
                elseif endsWith(parameterName,'AMI')



                    nodeName=parameterName(1:end-3);
                    if strcmp(nodeName,'TapWeights')
                        node=tree.getTapNode(blockInstanceName);
                    else
                        node=tree.getParameterFromBlock(blockInstanceName,nodeName);
                    end
                    if isempty(node)
                        continue
                    end
                    if node.Hidden
                        newValue='off';
                    else
                        newValue='on';
                    end
                else
                    newValue=tree.getCurrentValue(blockInstanceName,parameterName);
                end
                if~isempty(newValue)
                    if~ischar(newValue)
                        newValue=mat2str(newValue);
                    end
                    if~strcmp(maskObj.Parameters(idx).Value,newValue)
                        maskObj.Parameters(idx).Value=newValue;
                    end
                end
            end
        end
    end
    if nargin<2
        open_system(block,'mask');
    end
end