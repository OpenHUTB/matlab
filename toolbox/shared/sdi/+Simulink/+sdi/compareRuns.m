function diff=compareRuns(runID1,runID2,varargin)
















    try
        validateattributes(runID1,{'numeric'},{'scalar','>',0},'Simulink.sdi.compareRuns','runID1');
        validateattributes(runID2,{'numeric'},{'scalar','>',0},'Simulink.sdi.compareRuns','runID2');

        [alignment,selectedSig,tolerance,options]=locGetOptions(varargin{:});
        engine=Simulink.sdi.Instance.engine;
        comparisonRunID=Simulink.sdi.internal.compareRunsWithTolerance(engine.sigRepository,runID1,runID2,alignment,selectedSig,tolerance,options);
        engine.setDiffRunResult(comparisonRunID);
        diff=engine.DiffRunResult;
    catch me
        me.throwAsCaller();
    end
end


function[alignment,selectedSig,tolerance,options]=locGetOptions(varargin)
    alignment=[];
    selectedSig=[];
    tolerance=[];
    options=struct();

    [varargin{:}]=convertStringsToChars(varargin{:});


    if~isempty(varargin)
        if isa(varargin{1},'Simulink.sdi.AlignType')||isempty(varargin{1})
            alignment=int32(varargin{1});
            varargin(1)=[];
        end
    end


    if~isempty(varargin)
        if~ischar(varargin{1})||isempty(varargin{1})
            selectedSig=varargin{1};
            varargin(1)=[];
        end
    end

    if isempty(varargin)
        return
    end


    expectedConstraintsValues="MustMatch";
    expectedStopOnFirstMismatchValues=["Metadata","Any"];


    p=inputParser;
    p.addParameter('abstol',0,@(x)validateattributes(x,{'numeric'},{'scalar','>=',0}));
    p.addParameter('reltol',0,@(x)validateattributes(x,{'numeric'},{'scalar','>=',0}));
    p.addParameter('timetol',0,@(x)validateattributes(x,{'numeric'},{'scalar','>=',0}));
    p.addParameter('align',[],@(x)validateattributes(x,{'Simulink.sdi.AlignType'},{}));
    p.addParameter('selectedsig',0);
    p.addParameter('datatype','',@(x)~isempty(validatestring(x,expectedConstraintsValues)));
    p.addParameter('time','',@(x)~isempty(validatestring(x,expectedConstraintsValues)));
    p.addParameter('startstop','',@(x)~isempty(validatestring(x,expectedConstraintsValues)));
    p.addParameter('stoponfirstmismatch','',@(x)~isempty(validatestring(x,expectedStopOnFirstMismatchValues)));
    p.addParameter('ExpandChannels',logical.empty,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('KeepExpanded',logical.empty,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});
    params=p.Results;


    if~isempty(params.align)
        alignment=int32(params.align);
    end



    selectedSig=params.selectedsig;


    tolerance=struct('absolute',0,'relative',0,'lagging',0,'leading',0);
    if params.abstol>0
        tolerance.absolute=params.abstol;
    end
    if params.reltol>0
        tolerance.relative=params.reltol;
    end
    if params.timetol>0
        tolerance.lagging=params.timetol;
        tolerance.leading=params.timetol;
    end

    if~isempty(params.datatype)
        options.DataType=params.datatype;
    end
    if~isempty(params.time)
        options.Time=params.time;
    end
    if~isempty(params.startstop)
        options.StartStop=params.startstop;
    end
    if~isempty(params.stoponfirstmismatch)
        options.StopOnFirstMismatch=params.stoponfirstmismatch;
    end
    if~isempty(params.ExpandChannels)
        options.ExpandChannels=params.ExpandChannels;
    end
    if~isempty(params.KeepExpanded)
        options.KeepExpanded=params.KeepExpanded;
    end
end
