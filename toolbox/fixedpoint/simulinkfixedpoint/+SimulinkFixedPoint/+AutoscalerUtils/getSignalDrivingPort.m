function curListPorts=getSignalDrivingPort(entityAutoscaler,blkObj,inportSet,outportSet)





    hPorts=get_param(blkObj.Handle,'PortHandles');

    inportSet=cleanPortSet(inportSet,hPorts.Inport);
    outportSet=cleanPortSet(outportSet,hPorts.Outport);

    nIn=length(inportSet);
    nOut=length(outportSet);

    curListPorts={};




    for iIn=1:nIn

        iInport1=inportSet(iIn);

        hInportCur1=hPorts.Inport(iInport1);

        portObj=get_param(hInportCur1,'Object');

        [sourceBlkObj,sourcePathItem,srcInfo]=entityAutoscaler.getSourceSignal(portObj);
        structSignalID.blkObj=sourceBlkObj;
        structSignalID.pathItem=sourcePathItem;
        structSignalID.srcInfo=srcInfo;

        if~isempty(structSignalID.blkObj)&&~isempty(structSignalID.pathItem)
            curListPorts=[curListPorts,structSignalID];%#ok
        end
    end

    for iOut1=1:nOut
        structSignalID=[];
        iOutport1=outportSet(iOut1);
        structSignalID.blkObj=blkObj;
        structSignalID.pathItem=int2str(iOutport1);
        if~isempty(structSignalID.blkObj)
            curListPorts=[curListPorts,structSignalID];%#ok
        end
    end

    function portSet=cleanPortSet(portSet,actualPortInfo)

        if isequal(-1,portSet)

            portSet=1:length(actualPortInfo);

        elseif ischar(portSet)



            temp=1:length(actualPortInfo);%#ok used in call to eval 

            try
                portSet=eval(sprintf('temp(%s)',portSet));
            catch

                portSet=[];
            end
        end


