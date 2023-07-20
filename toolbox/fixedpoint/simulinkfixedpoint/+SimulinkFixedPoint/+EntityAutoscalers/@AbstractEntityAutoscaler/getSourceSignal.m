function[srcBlkObj,srcPathItem,srcInfo]=getSourceSignal(h,portObj,isAlreadySrcPort)












    srcInfo=[];
    srcBlkObj=[];
    srcPathItem='';

    if nargin<3
        isAlreadySrcPort=false;
    end
    if isAlreadySrcPort
        [srcBlkObj,srcPathItem,srcInfo]=...
        getSrcSignalForSrcPortHandle(h,portObj.Handle);

        srcInfo=checkForVirtBusExpansionMdlRefSrc(h,portObj.Handle,srcInfo);
        return;
    end

    hSource=portObj.getActualSrc;


    for i=1:size(hSource,1)
        srcPortHandle=hSource(i,1);
        [srcBlkObj,srcPathItem,srcInfo]=...
        getSrcSignalForSrcPortHandle(h,srcPortHandle);
        if~isempty(srcBlkObj)&&~isempty(srcPathItem)





            if size(hSource(i,:),2)>3&&hSource(i,4)~=-1


                srcPortObj=get_param(srcPortHandle,'Object');
                attributes=srcPortObj.getCompiledAttributes(hSource(i,4));
                srcInfo.busObjectName=h.hCleanDTOPrefix(attributes.parentBusObjectName);
                srcInfo.busElementName=attributes.eName;
            else

                srcInfo=checkForVirtBusExpansionMdlRefSrc(h,srcPortHandle,srcInfo);
            end
            return;
        end
    end

    function srcInfo=checkForVirtBusExpansionMdlRefSrc(h,srcPortHandle,srcInfo_in)

        srcInfo=srcInfo_in;

        parentHandle=get_param(srcPortHandle,'ParentHandle');

        if isa(get_param(parentHandle,'Object'),'Simulink.ModelReference')

            portNumber=get_param(srcPortHandle,'PortNumber');
            virBusOutPortInfo=get_param(parentHandle,'VirtualBusOutportInformation');
            info=virBusOutPortInfo{portNumber};

            [isMdlRefVirBusExpansion,busObjectName,busElementName]=...
            getBusAndElementNameFromBusRelatedInfo(info,parentHandle);

            if isMdlRefVirBusExpansion
                srcInfo.busObjectName=h.hCleanDTOPrefix(busObjectName);
                srcInfo.busElementName=busElementName;
            end

        end


        function[isBusExpansionCase,busObjectName,busElementName]=getBusAndElementNameFromBusRelatedInfo(info,portBlkHandle)










            isBusExpansionCase=false;
            busObjectName='';
            busElementName='';

            if isempty(info)||(info.flatIndex==-1)||isempty(info.busPath)

                return;
            end


            isBusExpansionCase=true;
            if isfield(info,'busObjectName')
                busObjectName=info.busObjectName;
            else
                busObjectName=info.busName;
            end



            busPathElements=strsplit(info.busPath,'.');

            if length(busPathElements)==1


                busElementName=busPathElements{1};
                return;
            end











            modelName=get_param(bdroot(portBlkHandle),'Name');
            busCashedInfo=slInternal('busDiagnostics','getDFSElementsInBus',modelName,busObjectName,1);



            [flatIndices{1:length(busCashedInfo)}]=deal(busCashedInfo.flatIndex);
            matchingIndex=find((cell2mat(flatIndices))==info.flatIndex,1,'first');


            busObjectName=busCashedInfo(matchingIndex).parentBOName;
            busElementName=busCashedInfo(matchingIndex).eName;



            function[srcBlkObj,srcPathItem,srcInfo]=getSrcSignalForSrcPortHandle(h,srcPortHandle)





                srcInfo=[];
                try
                    sourceBlkHandle=get_param(srcPortHandle,'ParentHandle');
                    srcBlkObj=get_param(sourceBlkHandle,'Object');





                    if isa(srcBlkObj,'Simulink.Inport')&&srcBlkObj.isSynthesized&&...
                        isa(get_param(srcBlkObj.Parent,'Object'),'Simulink.BlockDiagram')





                        try

                            inInfo=slInternal('getModelReferenceVirtualBusRootPortInformation',sourceBlkHandle);
                        catch internalAPIError


                            if(strcmp(internalAPIError.identifier,'Simulink:modelReference:VirtualBusRootIOInfo_InvalidArg'))

                                srcBlkObj=[];
                                srcPathItem='';
                                return;
                            else

                                rethrow(internalAPIError);
                            end
                        end



                        [isBusExpansionCase,busObjectName,busElementName]=...
                        getBusAndElementNameFromBusRelatedInfo(inInfo,sourceBlkHandle);


                        if isBusExpansionCase

                            srcInfo.busObjectName=h.hCleanDTOPrefix(busObjectName);
                            srcInfo.busElementName=busElementName;
                        else


                            if~isempty(inInfo)&&isfield(inInfo,'originalBlock')
                                srcBlkObj=get_param(inInfo.originalBlock,'Object');
                            end
                        end
                    end








                    srcBlkParent=get_param(srcBlkObj.Parent,'Object');
                    if isa(srcBlkObj,'Simulink.SFunction')&&~isa(srcBlkParent,'Simulink.BlockDiagram')
                        if slprivate('is_stateflow_based_block',srcBlkParent.Handle)
                            portIndexSfun=find((srcBlkObj.PortHandles.Outport==srcPortHandle),1);

                            portIndexUpstream=portIndexSfun-1;

                            hData=srcBlkParent.find('-isa','Stateflow.Data','Scope','Output','Port',portIndexUpstream,'-depth',2);
                            if~isempty(hData)

                                srcBlkObj=hData;
                                srcPathItem='1';
                            else
                                srcBlkObj=[];
                                srcPathItem='';
                            end
                            return;
                        end
                    end




                    srcOutportHandle=srcBlkObj.PortHandles.Outport;


                    portIndexUpstream=find((srcOutportHandle==srcPortHandle),1);

                    if isempty(portIndexUpstream)



                        if isa(srcBlkParent,'Simulink.BlockDiagram')
                            srcPathItem='1';
                        else
                            srcPathItem='';
                        end
                    else
                        pathItemFromOutport=SimulinkFixedPoint.AutoscalerUtils.getBlkPathItemsFromPort(srcBlkObj,[],int2str(portIndexUpstream));
                        srcPathItem=pathItemFromOutport{1};
                    end
                    return;


                catch


                end


                srcBlkObj=[];
                srcPathItem='';



