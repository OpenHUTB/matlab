unlockAndClearItems;

lasterror('reset');
lastwarn('');


close all force;


reset(groot);
hgrc;
set(groot,'DefaultFigureColor',[1,1,1]);


format;


warning on all;
warning off MATLAB:uitable:DeprecatedFunction;
warning off MATLAB:uiflowcontainer:DeprecatedFunction;
warning off MATLAB:uigridcontainer:DeprecatedFunction;
warning off MATLAB:uitab:DeprecatedFunction;
warning off MATLAB:uitabgroup:DeprecatedFunction;
warning off MATLAB:uitree:DeprecatedFunction;
warning off MATLAB:uitreenode:DeprecatedFunction;
warning off MATLAB:mir_warning_unrecognized_pragma;
warning off MATLAB:subscripting:noSubscriptsSpecified;
warning off MATLAB:JavaComponentThreading;
warning off MATLAB:JavaEDTAutoDelegation;
warning off MATLAB:RandStream:ReadingInactiveLegacyGeneratorState;
warning off MATLAB:RandStream:ActivatingLegacyGenerators;
warning off MATLAB:class:DynPropDuplicatesMethod;
warning off MATLAB:audiovideo:audioplayer:noAudioOutputDevice;



managersMap=internal.matlab.legacyvariableeditor.peer.PeerManagerFactory.getManagerInstances();
managers=values(managersMap);
for i=1:length(managers)
    managers{i}.delete();
end



feature('hotlinks',1);


datetime.setLocalTimeZone('');


connector.internal.StoreGrootAppdata.loadAppdata();


deleteTimerObjects;


fclose('all');


set(0,'RecursionLimit',500);

rng('default');
rng('shuffle');



function unlockAndClearItems

    allInMem=inmem('-completenames');
    inmemItems=allInMem(~startsWith(allInMem,matlabroot));

    for i=1:length(inmemItems)
        if mislocked(inmemItems{i})
            munlock(inmemItems{i});
        end
    end



    clear(inmemItems{:});
end


function deleteTimerObjects
    allTimerObjects=timerfindall;
    if~isempty(allTimerObjects)
        stop(allTimerObjects);
        delete(allTimerObjects);
    end
end
