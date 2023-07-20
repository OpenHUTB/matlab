function[runIDs,signalIDs]=verifyFileAndImport(this,repo,filename,runName,cmdLine,addToRunID,varargin)
    varParser={};
    importer='';


    appName='sdi';
    message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
    tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName)));


    Simulink.SimulationData.utValidSignalOrCompositeData([],true);
    tmp2=onCleanup(@()Simulink.SimulationData.utValidSignalOrCompositeData([],false));


    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.isImportCancelled(0);
    fw.beginCancellableOperation();
    tmp3=onCleanup(@()fw.endCancellableOperation());
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    wksParser.IsImportCancelled=false;


    numOpts=numel(varargin);
    opts={};
    if numOpts==1

        if~isstring(varargin{1})&&isobject(varargin{1})
            importer=class(varargin{1});
        else
            importer=char(varargin{1});
        end
    elseif numOpts>1

        p=inputParser;
        p.KeepUnmatched=true;
        p.addParameter('reader','');
        p.addParameter('parser',{});
        p.parse(varargin{:});
        params=p.Results;
        importer=params.reader;
        varParser=params.parser;
        opts=varargin;
    end


    if isempty(repo)
        repo=sdi.Repository(1);
    elseif isprop(repo,'sigRepository')
        repo=repo.sigRepository;
    end


    this.createPendingParsers();
    [fullFileName,parser]=verifyFileAndFindParser(this,filename,importer);
    parser.Filename=fullFileName;
    parser.RunName=runName;
    parser.CmdLine=cmdLine;



    if isempty(varParser)
        wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
        wksParser.resetParser();
        try
            varParser=parser.getVarParser(wksParser,filename,opts{:});
        catch me
            throwAsCaller(me);
        end
    end

    oldSignalIDs=[];
    if addToRunID>0
        oldSignalIDs=Simulink.sdi.getRun(addToRunID).getAllSignalIDs();
    end


    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    parser.ProgressTracker=fw.createProgressTrackerForImport(varParser);


    try
        runIDs=import(parser,varParser,repo,addToRunID,opts{:});
    catch me
        throwAsCaller(me);
    end
    runIDs(runIDs==0)=[];


    if wksParser.IsImportCancelled
        for idx=1:numel(runIDs)
            Simulink.sdi.deleteRun(runIDs(idx));
        end
        runIDs=[];
        wksParser.IsImportCancelled=false;
    end



    signalIDs=[];
    for idx=1:length(runIDs)
        signalIDs=...
        [signalIDs;...
        doPostRunCreate(parser,repo,runName,runIDs(idx))];%#ok<AGROW>
    end


    signalIDs=setdiff(signalIDs,oldSignalIDs);
end
