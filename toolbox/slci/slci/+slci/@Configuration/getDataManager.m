



function dmgr=getDataManager(obj,varargin)

    profiler=slci.internal.Profiler('SLCI','getDataManager','','');


    switch(nargin)
    case 2
        aModelName=varargin{1};
    case 1
        aModelName=obj.getModelName();
    otherwise
        DAStudio.error('Slci:slci:InvalidNumberOfArguments');
    end


    obj.createReportFolder();
    aReportFolder=obj.getReportFolder;

    profiler.stop();
    profiler=slci.internal.Profiler('SLCI','SLCIDataManager','','');

    dmgr=slci.results.SLCIDataManager(aModelName,aReportFolder);

    profiler.stop();
end
