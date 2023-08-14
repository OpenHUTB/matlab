function onRapidAccelRunImport(this,varargin)
    assert(length(varargin)==3);
    runIDs=varargin{1};
    mdl=varargin{2};
    isMenuSim=varargin{3};


    runName=this.Engine_.getRunName(runIDs(end));
    this.Engine_.newRunIDs=runIDs;
    this.Engine_.updateFlag=runName;


    if numel(runIDs)==1
        Simulink.sdi.onNewRapidAccelRun(mdl,runIDs);
    end


    if isMenuSim
        fw=Simulink.sdi.internal.Framework.getFramework();
        fw.addNewDataNotification(mdl);
    end
end
