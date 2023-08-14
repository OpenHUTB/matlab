function flag=getUsePipelines(this,isSysObj)



    if(isSysObj)
        hdrv=hdlcurrentdriver();
        flag=hdrv.getParameter('UsePipelinedToolboxFunctions');
    else
        if(isempty(this.getImplParams('UsePipelinedKernel')))
            flag=true;
        else

            flag=strcmpi(this.getImplParams('UsePipelinedKernel'),'on');
        end
    end
    return
end
