function plotComparison(this,dsr)










    try
        validateattributes(dsr,{'Simulink.sdi.DiffSignalResult'},{'scalar'},'plotComparison','dsr');
    catch me
        me.throwAsCaller();
    end
    this.clearSignals();
    this.ComparisonSignalID=dsr.ComparisonSignalID;
end
