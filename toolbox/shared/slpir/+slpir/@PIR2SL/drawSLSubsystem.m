
function slBlockName=drawSLSubsystem(this,slBlockName,hC)



    slHandle=hC.SimulinkHandle;
    hRefNtwk=hC.ReferenceNetwork;




    if hRefNtwk.NumberOfPirGenericPorts>0
        hRefNtwk.prepareNetworkForModelGen(slHandle,hC);
    end

    [slBlockName,newslHandle]=addBlock(this,hC,'built-in/SubSystem',slBlockName);
    setProperties(this,hC,newslHandle);
    addSubSystemPorts(this,slBlockName,hRefNtwk);




    if~shouldDrawMask(hC)
        return;
    end


    if isDynamicStateSpaceBlock(hC)
        return;
    end

    if~this.isSFNetwork(hC.SimulinkHandle)&&~isMatlabSystemBlk(hC.SimulinkHandle)
        handleMaskParams(this,slBlockName,slHandle,hRefNtwk,false)
    end
end


function isMLSysBlk=isMatlabSystemBlk(slbh)
    isMLSysBlk=strcmp(get_param(slbh,'BlockType'),'MATLABSystem');
end


function drawMask=shouldDrawMask(hNic)
    slbh=hNic.SimulinkHandle;
    drawMask=hasmaskdlg(slbh);



    if drawMask||~isempty(get_param(slbh,'MaskInitialization'))

        drawMask=true;

        if strncmp(get_param(slbh,'MaskType'),'PID 1dof',8)
            drawMask=false;
        end
    else

        hRef=hNic.ReferenceNetwork;
        drawMask=drawMask&&(hRef.isMaskedSubsystem||hRef.isMaskedSubsystemLibBlock);
    end
end


function flag=isDynamicStateSpaceBlock(hC)

    slHandle=hC.SimulinkHandle;
    if strcmp(get_param(slHandle,'ReferenceBlock'),'hdlssclib/Dynamic State-Space')
        flag=true;
    else
        flag=false;
    end
end


