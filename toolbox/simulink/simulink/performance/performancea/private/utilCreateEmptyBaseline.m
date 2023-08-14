function[baseline]=utilCreateEmptyBaseline(name)


    if nargin<1
        name='';
    end
    baseline=struct('time',struct('total',[],...
    'displayTime','',...
    'runID',[],...
    'timeBreakdown',struct([])),...
    'check',struct('name',name,...
    'passed','na',...
    'fixed','na',...
    'validationPassed','na'));
















