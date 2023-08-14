function result=isCascadeMember(blockH)











    result=false;

    if cvi.CascMCDC.isValidBlock(blockH)

        dstH=cvi.CascMCDC.getDestinationBlock(blockH);
        if cvi.CascMCDC.isValidBlock(dstH)


            result=true;
            return
        end


        portHandles=get_param(blockH,'PortHandles');
        numInputs=length(portHandles.Inport);
        for i=1:numInputs
            srcH=cvi.CascMCDC.getSourceBlock(blockH,i);
            if cvi.CascMCDC.isValidBlock(srcH)&&...
                (cvi.CascMCDC.getDestinationBlock(srcH)==blockH)


                result=true;
                return
            end
        end
    end
