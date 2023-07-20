function setBlockSampleTime(~,hC,blkpath,onlyIfSynthetic,paramname)



    if nargin<5
        paramname='SampleTime';
    end

    if nargin<4
        onlyIfSynthetic=true;
    end

    if onlyIfSynthetic&&~hC.Synthetic
        return;
    end

    if hC.isParentTriggeredSubsystem()

        set_param(blkpath,paramname,'-1');
    else
        out=hC.PirOutputSignals(1);
        st=out.SimulinkRate;
        if~isinf(st)
            set_param(blkpath,paramname,sprintf('%16.15g',st));
        end
    end
end
