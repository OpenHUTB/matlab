function addElementToPort(model,portName,elementStr)



















    if nargin~=3
        DAStudio.error('Simulink:tools:slbusInvalidNumInputs');
    end

    if~bdIsLoaded(model)
        DAStudio.error('Simulink:BusElPorts:ModelNotLoaded',model);
    end

    if isempty(portName)
        DAStudio.error('Simulink:BusElPorts:InvalidPort');
    end

    blocksOfThisInport=find_system(gcs,'BlockType','Inport','IsComposite','on','PortName',portName);

    if isempty(blocksOfThisInport)
        blocksOfThisOutport=find_system(gcs,'BlockType','Outport','IsComposite','on','PortName',portName);
        if~isempty(blocksOfThisOutport)
            DAStudio.error('Simulink:BusElPorts:CannotAddElementToOutputPort');
        else
            DAStudio.error('Simulink:BusElPorts:InvalidPort');
        end
    end

    blkOfThisPort=blocksOfThisInport{1,1};
    block=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(get_param(blkOfThisPort,'Handle'));
    tree=block.port.tree;

    try
        node=Simulink.internal.CompositePorts.TreeNode.findNode(tree,elementStr);
        if~isempty(node)
            DAStudio.error('Simulink:BusElPorts:CannotAddElementToPortSinceElementExists');
        end
    catch ex
        if strcmp(ex.identifier,'Simulink:BusElPorts:CannotAddElementToPortSinceElementExists')
            throw(ex);
        end

        if strcmp(ex.identifier,'Simulink:BusElPorts:TreeNodeNotFound')
            try
                thisDotStr="";
                dotStrs=split(elementStr,'.');
                dotStrs(end)=[];



                for i=1:numel(dotStrs)
                    thisDotStr=strcat(thisDotStr,dotStrs{i,1});
                    elemNode=[];%#ok<NASGU> 
                    try
                        elemNode=Simulink.internal.CompositePorts.TreeNode.findNode(tree,thisDotStr);
                    catch ex %#ok<NASGU> 



                        try
                            shouldDirtyModel=true;
                            n=Simulink.internal.CompositePorts.TreeNode.addNodeToTree(tree,elementStr,shouldDirtyModel);
                            return;
                        catch exception
                            DAStudio.error('Simulink:BusElPorts:CannotAddElementToPort');
                        end
                    end

                    if~isempty(elemNode)&&~isempty(elemNode.busTypeRootAttrs)||~isempty(elemNode.busTypeElementAttrs)
                        DAStudio.error('Simulink:BusElPorts:CannotAddElementUnderAnElementSpecifiedByBusObject');
                    end


                    thisDotStr=strcat(thisDotStr,'.');
                end

                try
                    shouldDirtyModel=true;
                    n=Simulink.internal.CompositePorts.TreeNode.addNodeToTree(tree,elementStr,shouldDirtyModel);
                catch exception
                    DAStudio.error('Simulink:BusElPorts:CannotAddElementToPort');
                end
                return;
            catch exception
                throw(exception);
            end
        end
    end
end
