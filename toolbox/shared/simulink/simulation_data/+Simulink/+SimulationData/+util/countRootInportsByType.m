function[numExternalInputPorts,rootInports,numInports,...
    enablePort,numEnablePorts,enablePortIdx,...
    triggerPort,numTriggerPorts,triggerPortIdx,...
    numFcnCallTriggerPorts,containsBusElPorts]=...
    countRootInportsByType(model)









    rootInports=...
    find_system(model,'SearchDepth',1,'BlockType','Inport');
    numInports=length(rootInports);


    modelHandle=get_param(model,'Handle');
    containsBusElPorts=Simulink.BlockDiagram.Internal.hasCompositePorts(modelHandle);

    if containsBusElPorts
        bepElementNames=...
        Simulink.internal.CompositePorts.TreeNode.getLeafDotStrsForDataInputInterface(...
        modelHandle);












        compiledPorts=cell.empty;
        bepNameAndElement=containers.Map;




        for idx=1:numel(rootInports)
            bepElement=[get_param(rootInports{idx},'PortName')...
            ,'.',get_param(rootInports{idx},'Element')];
            if~isKey(bepNameAndElement,bepElement)
                bepNameAndElement(bepElement)=rootInports{idx};
            end
        end

        foundPortNames=string.empty;
        bepElementNamesIdx=1;
        numCompiledPorts=0;
        for idx=1:numel(rootInports)
            if isequal(get_param(rootInports{idx},'IsBusElementPort'),'off')

                compiledPorts=[compiledPorts;rootInports{idx}];%#ok<AGROW>
                bepElementNamesIdx=bepElementNamesIdx+1;
                numCompiledPorts=numCompiledPorts+1;
            else

                portName=get_param(rootInports{idx},'PortName');
                if~any(strcmp(foundPortNames,portName))


                    foundPortNames=[foundPortNames,portName];%#ok<AGROW>
                    if isempty(get_param(rootInports{idx},'Element'))



                        blockPath=bepNameAndElement([portName,'.']);
                        numEl=numel(bepElementNames{bepElementNamesIdx});

                        if isempty(bepElementNames{bepElementNamesIdx})
                            numEl=1;
                        end
                        for jdx=1:numEl
                            compiledPorts=[compiledPorts;blockPath];%#ok<AGROW>
                            numCompiledPorts=numCompiledPorts+1;
                        end
                    else
                        for jdx=1:numel(bepElementNames{bepElementNamesIdx})
                            oneNameAndElement=[portName,'.',bepElementNames{bepElementNamesIdx}{jdx}];
                            if isKey(bepNameAndElement,oneNameAndElement)
                                compiledPorts=[compiledPorts;bepNameAndElement(...
                                oneNameAndElement)];%#ok<AGROW>
                            else


                                compiledPorts=[compiledPorts;rootInports{idx}];%#ok<AGROW>
                            end
                            numCompiledPorts=numCompiledPorts+1;
                        end
                    end
                    bepElementNamesIdx=bepElementNamesIdx+1;
                end
            end
        end

        numInports=numCompiledPorts;
        rootInports=compiledPorts;
    end

    enablePort=...
    find_system(model,'SearchDepth',1,'BlockType','EnablePort');
    numEnablePorts=length(enablePort);
    assert(numEnablePorts<=1);
    if numEnablePorts>0
        enablePortIdx=numInports+1;
    else
        enablePortIdx=0;
    end

    numFcnCallTriggerPorts=0;
    triggerPort=...
    find_system(model,'SearchDepth',1,'BlockType','TriggerPort');
    numTriggerPorts=length(triggerPort);
    assert(numTriggerPorts<=1);
    if numTriggerPorts>0
        if strcmp(get_param(triggerPort,'TriggerType'),'function-call')
            numFcnCallTriggerPorts=numTriggerPorts;


            numTriggerPorts=0;
            triggerPortIdx=0;
        else
            if numEnablePorts>0
                triggerPortIdx=numInports+2;
            else
                triggerPortIdx=numInports+1;
            end
        end
    else
        triggerPortIdx=0;
    end

    numExternalInputPorts=numInports+numEnablePorts+numTriggerPorts;
end


