function generateHDLForNode(topModelName)





    if strcmp(get_param(topModelName,'EnableConcurrentExecution'),'off')||...
        strcmp(get_param(topModelName,'ExplicitPartitioning'),'off')||...
        (strcmp(get_param(topModelName,'EnableConcurrentExecution'),'on')&&...
        strcmp(get_param(topModelName,'ConcurrentTasks'),'off'))
        return;
    end

    mgr=get_param(topModelName,'MappingManager');

    if~isempty(mgr)
        mapping=mgr.getActiveMappingFor('DistributedTarget');
        if~isempty(mapping)

            blockToNodes=mapping.BlockToNodesMap;
            for idx=1:length(blockToNodes)

                if isa(blockToNodes(idx).MappingEntities(1),...
                    'Simulink.DistributedTarget.HardwareNode')
                    blk=blockToNodes(idx).Block;

                    assert(strcmp(get_param(blk,'BlockType'),'ModelReference'));



                    if isParentInactiveSubsystemVariant(blk,topModelName)||...
                        strcmp(get_param(blk,'Commented'),'on')
                        continue;
                    end

                    refMdlName=get_param(blk,'ModelNameInternal');
                    isProtectedRefModel=strcmp(get_param(blk,'ProtectedModel'),{'on'});
                    if~isProtectedRefModel
                        mdlsToClose=slprivate('load_model',refMdlName);
                        stf=get_param(refMdlName,'SystemTargetFile');
                    end

                    try
                        if~isHDLCoderInstalled()
                            MSLDiagnostic('Simulink:mds:HDLCoderLicenseUnavailable',refMdlName).reportAsWarning;
                            continue;
                        end

                        if isProtectedRefModel
                            makehdl(blk);
                            continue;
                        end

                        supportZynqBoards={'Xilinx Zynq ZC702 evaluation kit',...
                        'Xilinx Zynq ZC706 evaluation kit','ZedBoard'};

                        supportAlteraBoards={'Altera Cyclone V SoC development kit - Rev.C',...
                        'Altera Cyclone V SoC development kit - Rev.D',...
                        'Arrow SoCKit development board'};

                        if strcmp(stf,'slrealtime.tlc')


                            deviceIdx=...
                            Simulink.DistributedTarget.DistributedTargetUtils.getIndexOfHardwareNode(...
                            blockToNodes(idx).MappingEntities(1));
                            hdlBoardName=Simulink.DistributedTarget.getTargetSpecificName(...
                            'HDLNameForDeviceIdx',topModelName,deviceIdx);

                            targetInfoxPC=locGenerateTargetMappingInfo(...
                            blockToNodes(idx).MappingEntities(1),blk,mapping);

                            targetInfoxPC.deviceIdx=deviceIdx;
                            targetInfoxPC.hdlBoardName=hdlBoardName;

                            hdlce.generateHDLForxPCTurnkey(refMdlName,targetInfoxPC);

                        elseif strcmp(stf,'idelink_ert.tlc')||strcmp(stf,'idelink_grt.tlc')||...
                            any(strcmp(mapping.Architecture.Name,supportZynqBoards))

                            [iszynq,spName]=hdlturnkey.ishdlzynqspinstalled;
                            if~iszynq
                                MSLDiagnostic('hdlcommon:hdlturnkey:SupportPackageUninstalled',...
                                refMdlName,spName).reportAsWarning;
                            else
                                targetInfoZynq=locGenerateTargetMappingInfo(...
                                blockToNodes(idx).MappingEntities(1),blk,mapping);
                                hdlce.generateHDLForZynq(refMdlName,targetInfoZynq);
                            end

                        elseif any(strcmp(mapping.Architecture.Name,supportAlteraBoards))

                            [isaltera,spName]=hdlturnkey.ishdlalterasocspinstalled;
                            if~isaltera
                                MSLDiagnostic('hdlcommon:hdlturnkey:SupportPackageUninstalled',...
                                refMdlName,spName).reportAsWarning;
                            else
                                targetInfoAltera=locGenerateTargetMappingInfo(...
                                blockToNodes(idx).MappingEntities(1),blk,mapping);
                                hdlce.generateHDLForAltera(refMdlName,targetInfoAltera);
                            end

                        else
                            makehdl(refMdlName);
                        end

                    catch err
                        if~isProtectedRefModel
                            set_param(refMdlName,'Dirty','off');
                            slprivate('close_models',mdlsToClose);
                        end
                        rethrow(err);
                    end

                    set_param(refMdlName,'Dirty','off');
                    slprivate('close_models',mdlsToClose);

                end
            end

        end
    end


end



function retInfo=locGenerateTargetMappingInfo(nodeH,blkFullName,mapping)

    portNames=[];
    interfaceNames=[];
    portAddresses=[];

    signalMappings=mapping.SignalMappings;
    for k=1:length(signalMappings)
        signalMappingH=signalMappings(k);

        if isequal(signalMappingH.Connection.SourceNode,nodeH)||...
            isequal(signalMappingH.Connection.DestinationNode,nodeH)

            if isequal(blkFullName,signalMappingH.SourceBlock)
                portName=signalMappingH.SourcePortName;
            else
                portName=signalMappingH.DestinationPortName;
            end
            interfaceName=signalMappingH.Connection.InterfaceType.Name;
            portAddress=signalMappingH.Address;

            portNames=[portNames,{portName}];%#ok
            interfaceNames=[interfaceNames,{interfaceName}];%#ok
            portAddresses=[portAddresses,{portAddress}];%#ok
        end
    end

    retInfo=struct('ArchitectureName',mapping.Architecture.Name,...
    'ExecutionMode',nodeH.ExecutionMode,'ClockFrequency',...
    nodeH.ClockFrequency,'PortNames',{portNames},...
    'InterfaceNames',{interfaceNames},'PortAddresses',{portAddresses});

end




function retVal=isParentInactiveSubsystemVariant(block,topmdl)
    parent=get_param(block,'Parent');

    if strcmp(parent,topmdl)
        retVal=false;
    else
        assert(strcmp(get_param(parent,'BlockType'),'SubSystem'));
        if strcmp(get_param(parent,'Variant'),'on')

            if~strcmp(get_param(parent,'ActiveVariantBlock'),block)
                retVal=true;
            else

                retVal=isParentInactiveSubsystemVariant(parent,topmdl);
            end
        else
            retVal=isParentInactiveSubsystemVariant(parent,topmdl);
        end
    end

end

function retVal=isHDLCoderInstalled()
    retVal=license('test','Simulink_HDL_Coder')&&...
    ~isempty(ver('hdlcoder'));
end





