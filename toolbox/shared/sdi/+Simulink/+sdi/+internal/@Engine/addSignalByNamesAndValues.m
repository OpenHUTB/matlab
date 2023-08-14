function signalID=addSignalByNamesAndValues(this,varargin)
















    p=inputParser;


    p.addParamValue('runID',@isinteger);
    p.addParamValue('rootSource','',@ischar);
    p.addParamValue('timeSource','',@ischar);
    p.addParamValue('dataSource','',@ischar);
    p.addParamValue('dataValues',[],@(x)(isempty(x)||isa(x,'timeseries')));
    p.addParamValue('blockSource','',@ischar);
    p.addParamValue('modelSource','',@ischar);
    p.addParamValue('signalLabel','',@ischar);
    p.addParamValue('timeDimension',[],@(x)(isempty(x)||isinteger(x)));
    p.addParamValue('sampleDimension',[],@(x)(isempty(x)||isinteger(x)));
    p.addParamValue('portIndex',[],@(x)(isempty(x)||isinteger(x)));
    p.addParamValue('channel',[],@(x)(isempty(x)||isinteger(x)));
    p.addParamValue('SID','',@ischar);
    p.addParamValue('metaData',[]);
    p.addParamValue('parentID',[]);
    p.addParamValue('rootDataSrc','',@ischar);

    p.parse(varargin{:});
    results=p.Results;


    runID=results.runID;
    rootSource=results.rootSource;
    timeSource=results.timeSource;
    dataSource=results.dataSource;
    dataValues=results.dataValues;
    blockSource=results.blockSource;
    modelSource=results.modelSource;
    signalLabel=results.signalLabel;
    timeDimension=results.timeDimension;
    sampleDimension=results.sampleDimension;
    portIndex=results.portIndex;
    channel=results.channel;
    SID=results.SID;
    metaData=results.metaData;
    parentID=results.parentID;
    rootDataSrc=results.rootDataSrc;


    signalID=this.sigRepository.add(this,runID,rootSource,timeSource,...
    dataSource,dataValues,blockSource,...
    modelSource,signalLabel,...
    timeDimension,sampleDimension,...
    portIndex,channel,SID,metaData,...
    parentID,rootDataSrc);
end

