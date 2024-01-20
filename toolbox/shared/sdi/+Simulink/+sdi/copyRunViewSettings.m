function[alignedSigs,unalignedSigs]=copyRunViewSettings(sourceRun,destinationRun,moveCheckboxes)

    if nargin<3
        moveCheckboxes=false;
    end
    if isa(sourceRun,'Simulink.sdi.Run')
        sourceRun=sourceRun.id;
    end
    if isa(destinationRun,'Simulink.sdi.Run')
        destinationRun=destinationRun.id;
    end


    eng=Simulink.sdi.Instance.engine;
    [alignedSigs,unalignedSigs,plottedSigs,removedSigs]=eng.sigRepository.copyRunViewSettings(...
    sourceRun,destinationRun,moveCheckboxes);
    eng.dirty=true;


    for idx=1:length(alignedSigs)
        clr=eng.sigRepository.getSignalLineColor(alignedSigs(idx));
        notify(eng,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',alignedSigs(idx),clr,'color'));

        style=eng.sigRepository.getSignalLineDashed(alignedSigs(idx));
        notify(eng,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',alignedSigs(idx),style,'linestyle'));
    end


    if~isempty(removedSigs)
        Simulink.sdi.clearSignalsFromCanvas(removedSigs);
        for idx=1:length(removedSigs)
            notify(eng,'treeSignalPropertyEvent',...
            Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',removedSigs(idx),false,'checked'));
        end
    end
    if~isempty(plottedSigs)
        for idx=1:length(plottedSigs)
            notify(eng,'treeSignalPropertyEvent',...
            Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',plottedSigs(idx),true,'checked'));
        end
    end
end
