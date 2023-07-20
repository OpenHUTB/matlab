function inheritInitialOutputsToParentConditionalSS(origSysH,refMdlToMdlBlk,mdl,mdlCopy,sliceXfrmr)









    import Transform.*

    if strcmp(get(origSysH,'type'),'block_diagram')
        if refMdlToMdlBlk.isKey(origSysH)
            origSysH=refMdlToMdlBlk(origSysH);
        else
            return;
        end
    end



    ph=get_param(origSysH,'PortHandles');
    hasNonEmptyInitOut=false;
    thisInitialOutput=cell(1,length(ph.Outport));
    thisActSrc=zeros(1,length(ph.Outport));
    for i=1:length(ph.Outport)
        outBH=Transform.getOutportBlock(origSysH,i);
        initOut=get(outBH,'InitialOutput');
        if~isempty(modelslicerprivate('evalinModel',bdroot(mdl),initOut))
            hasNonEmptyInitOut=true;
        end
        thisInitialOutput{i}=initOut;



        thisActSrc(i)=getActSrcPortH(outBH);
    end

    if~hasNonEmptyInitOut


        return;
    end


    parentConditionalSysH=[];
    parentH=get_param(get(origSysH,'Parent'),'Handle');
    sysO=get_param(parentH,'Object');
    while true
        if isa(sysO,'Simulink.BlockDiagram')
            if refMdlToMdlBlk.isKey(sysO.Handle)
                sysO=get(refMdlToMdlBlk(sysO.Handle),'Object');
            else
                break;
            end
        elseif isa(sysO,'Simulink.SubSystem')...
            &&(~isempty(sysO.PortHandle.Enable)...
            ||~isempty(sysO.PortHandle.Trigger)...
            ||~isempty(sysO.PortHandle.Ifaction)...
            ||~isempty(sysO.PortHandle.Reset))
            parentConditionalSysH=sysO.Handle;
            break;
        elseif isa(sysO,'Simulink.ModelReference')&&sysO.isSynthesized





            parentH=sysO.getCompiledParent();
            if strcmp(get_param(parentH,'virtual'),'on')
                parentfullname=getfullname(parentH);
                sysO=get_param(parentfullname,'Object');
            else
                sysO=get(parentH,'Object');
            end
        else
            sysO=get(sysO.getParent,'Object');
        end
    end

    if~isempty(parentConditionalSysH)


        msObj=sliceXfrmr.ms;
        if~isempty(msObj.SimState)
            parentIniOut=getInitialValueFromSimState(parentConditionalSysH,refMdlToMdlBlk,msObj.SimState);
        else
            parentIniOut=getInitialValueOfConditionalSS(parentConditionalSysH,refMdlToMdlBlk);
        end

        sliceCondSysH=getCopyHandles(parentConditionalSysH,refMdlToMdlBlk,mdl,mdlCopy);
        pph=get_param(sliceCondSysH,'PortHandles');
        for i=1:length(pph.Outport)
            outBHOrig=Transform.getOutportBlock(parentConditionalSysH,i);
            srcPH=getActSrcPortH(outBHOrig);
            if ismember(srcPH,thisActSrc)

                outBH=Transform.getOutportBlock(sliceCondSysH,i);
                if ischar(parentIniOut{i})
                    set_param(outBH,'SourceOfInitialOutputValue','Dialog')
                    set_param(outBH,'InitialOutput',parentIniOut{i})
                end
            end
        end
    end
    function srcPH=getActSrcPortH(blk)
        bo=get(blk,'Object');
        aSrc=bo.getActualSrc;
        srcPH=aSrc(1,1);
    end
end