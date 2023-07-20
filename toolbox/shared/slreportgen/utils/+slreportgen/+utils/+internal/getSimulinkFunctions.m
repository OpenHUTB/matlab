function simulinkFcns=getSimulinkFunctions(mdl)






























    simulinkFcns=[];

    compFcns=get_param(mdl,'CompiledSimulinkFunctions');
    if~isempty(compFcns)
        nFcns=compFcns.compFunctions.Size;

        if nFcns>0

            for fcnIdx=nFcns:-1:1
                fcnInfo=compFcns.compFunctions(fcnIdx);
                fcnBlk=fcnInfo.functionBlock;

                simulinkFcns(fcnIdx).FunctionName=fcnInfo.functionName;
                simulinkFcns(fcnIdx).FullPathToFunction=fcnInfo.fullPathToFunction;
                simulinkFcns(fcnIdx).FunctionBlock=fcnBlk;
                simulinkFcns(fcnIdx).CallerBlocks=fcnInfo.callerBlocks.toArray;
                simulinkFcns(fcnIdx).Visibility=fcnInfo.visibility;
                simulinkFcns(fcnIdx).PortGroup=[];

                if~isempty(fcnBlk)&&strcmp(get_param(fcnBlk,"BlockType"),"ModelReference")


                    portGroupInfo=get_param(fcnBlk,"PortGroupInfo");
                    fcnPortInfo=portGroupInfo.FcnCallPortGroups;





                    if~isempty(fcnInfo.fullPathToFunction)
                        fullFcnName=strcat(fcnInfo.fullPathToFunction,'.',fcnInfo.functionName);
                    else
                        fullFcnName=fcnInfo.functionName;
                    end
                    portInfoIdx=strcmp(fullFcnName,{fcnPortInfo.SimulinkFunction});
                    portGroupIdx=find(portInfoIdx);

                    if~isempty(portGroupIdx)
                        simulinkFcns(fcnIdx).PortGroup=portGroupIdx-1;
                    end
                end

            end
        end
    end