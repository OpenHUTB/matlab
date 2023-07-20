function archElem=getArchitecturePeer(simulinkObjectHandle)









    archElem=[];

    if belongsToHarnessBD(simulinkObjectHandle)

        zcPeeHdl=systemcomposer.internal.harness.getZCPeerForHarnessBlock(simulinkObjectHandle);
        if~isempty(zcPeeHdl)
            simulinkObjectHandle=zcPeeHdl;
        end
    end

    switch get_param(simulinkObjectHandle,'Type')
    case 'block_diagram'
        app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(simulinkObjectHandle);
        archElem=app.getTopLevelCompositionArchitecture;
    case 'block'
        archElem=Simulink.SystemArchitecture.internal.ApplicationManager.getSystemComposerComponent(simulinkObjectHandle);
        if(isempty(archElem))
            archElem=Simulink.SystemArchitecture.internal.ApplicationManager.getSystemComposerArchPort(simulinkObjectHandle);
        end
    case 'port'
        archElem=Simulink.SystemArchitecture.internal.ApplicationManager.getSystemComposerPort(simulinkObjectHandle);
    case 'line'

        segObj=get_param(simulinkObjectHandle,'object');
        lineObj=segObj.getLine;
        linePorts=lineObj.getPorts;
        if(numel(linePorts)>1)
            if strcmpi(linePorts(1).PortType,'connection')
                archElem=Simulink.SystemArchitecture.internal.ApplicationManager.getSystemComposerConnector(...
                linePorts(1).Handle,linePorts(2).Handle);
            else
                srcPortHandle=get_param(simulinkObjectHandle,'SrcPortHandle');
                dstPortHandle=get_param(simulinkObjectHandle,'DstPortHandle');
                for m=1:numel(dstPortHandle)
                    currConn=Simulink.SystemArchitecture.internal.ApplicationManager.getSystemComposerConnector(srcPortHandle,dstPortHandle(m));
                    archElem=[archElem,currConn];
                end
            end
        end

    otherwise
        error('Invalid Composition Object Handle');
    end

end

function bool=belongsToHarnessBD(handle)
    bool=false;
    if strcmp(get_param(bdroot(handle),'isHarness'),'on')
        bool=true;
    end
end
