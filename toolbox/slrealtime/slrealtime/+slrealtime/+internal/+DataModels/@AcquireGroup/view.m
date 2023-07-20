function view(this)





    fprintf('               tid = %d\n',this.tid);
    fprintf('  DiscreteInterval = %5.3f\n',this.discreteInterval);
    fprintf('  SampleTimeString = %s\n',this.sampleTimeString);
    fprintf('  Decimation       = %d\n',this.decimation);
    fprintf('  signals:\n');

    for i=1:this.nSignals
        [str,bppi,sn]=slrealtime.Instrument.getSignalStringToDisplay(this.xcpSignals(i));
        if isempty(sn)
            fprintf('    %s\n',bppi);
        else
            fprintf('    %s  (%s)\n',bppi,sn);
        end
    end

end
