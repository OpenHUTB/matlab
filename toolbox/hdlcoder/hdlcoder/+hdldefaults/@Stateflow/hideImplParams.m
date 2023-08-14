function params=hideImplParams(this,blockHandle,implInfo)


    params=hideImplParams@hdlimplbase.SFBase(this,blockHandle,implInfo);

    if strcmp(hdlfeature('EnableClockDrivenOutput'),'on')&&(blockHandle>0)
        chartH=idToHandle(sfroot,sfprivate('block2chart',blockHandle));


        if~(this.isStateflowChart(chartH)&&strcmp(chartH.stateMachineType,'Moore'))
            params=[params,{'clockdrivenoutput'}];
        end
    end
end