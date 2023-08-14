function out=getTolerance(this,signalID)
    out=this.defaultTolAndSyncOptions();
    out.absolute=this.getSignalAbsTol(signalID);
    out.relative=this.getSignalRelTol(signalID);
end