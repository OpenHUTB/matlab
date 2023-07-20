classdef RTESynthesizerPluginCallbacks<handle





    methods(Static,Hidden)
        function validationPassed=validateSignalInvalidationBlockConnection(sigInvBlock)




            validationPassed=false;
            cLine=get_param(sigInvBlock,'LineHandles');
            currOutport=cLine.Outport;


            if currOutport<0
                return;
            end

            dataPortLineObj=get_param(currOutport,'Object');
            assert(dataPortLineObj.SrcPortHandle>=0);
            srcPortObj=get_param(dataPortLineObj.SrcPortHandle,'Object');

            dstPorts=autosar.mm.mm2sl.SLModelBuilder.getAllDestinationPortsThroughVirtualBlocks(srcPortObj.Parent);

            dstBlocks=cellfun(@(x)get_param(x,'Parent'),dstPorts,...
            'UniformOutput',false);
            isConnectedToOutport=any(...
            cellfun(@(x)autosar.arch.Utils.isBusOutPortBlock(x),dstBlocks));
            if~isConnectedToOutport





                assert(strcmp(get_param(sigInvBlock,'SimulateInvalidationFlag'),'on'),'Should only be here if SigInv flag is set');
                MSLDiagnostic('autosarstandard:validation:SigInvNotConnectedRootOutErrorStatusForwarding',getfullname(sigInvBlock)).reportAsWarning;
            else
                validationPassed=true;
            end
        end

        function rteSubsyName=createRteSubsysName(modelRefBlockName,portName,dataElementName)

            import autosar.composition.rte.RTESynthesizerPluginCallbacks
            rteSubsyName=['RTE_',modelRefBlockName,'_',portName,'_',dataElementName,'_AR_IsInvalid'];


            rteSubsyName=arxml.arxml_private('p_create_aridentifier',rteSubsyName,namelengthmax);
        end



        function outPortH=findSrcPortWalkThroughSubsystems(inPortH)
            import autosar.composition.rte.RTESynthesizerPluginCallbacks

            outPortH=-1;
            connectedLineH=get_param(inPortH,'Line');
            if(connectedLineH==-1)

                return;
            end

            srcPortH=get_param(connectedLineH,'SrcPortHandle');
            if(srcPortH==-1)

                return;
            end


            srcBlockHandle=get_param(connectedLineH,'SrcBlockHandle');
            if autosar.arch.Utils.isSubSystem(srcBlockHandle)
                srcPortBlock=autosar.arch.Utils.findSLPortBlock(srcPortH);
                assert(length(srcPortBlock)==1,'should only find one source port block');
                phs=get_param(srcPortBlock{1},'PortHandles');


                outPortH=RTESynthesizerPluginCallbacks.findSrcPortWalkThroughSubsystems(phs.Inport);
            elseif autosar.arch.Utils.isBusInPortBlock(srcBlockHandle)&&...
                autosar.arch.Utils.isSubSystem(get_param(srcBlockHandle,'Parent'))
                phs=get_param(get_param(srcBlockHandle,'Parent'),'PortHandles');
                inportHandles=phs.Inport;
                portNum=str2double(get_param(srcBlockHandle,'Port'));
                srcPortH=inportHandles(arrayfun(@(x)isequal(get_param(x,'PortNumber'),portNum),inportHandles));


                outPortH=RTESynthesizerPluginCallbacks.findSrcPortWalkThroughSubsystems(srcPortH);
            else
                outPortH=srcPortH;
            end
        end
    end
end


