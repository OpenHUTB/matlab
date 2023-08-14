function initialize(this,...
    name,blockpath,portindex,signame,parentname,...
    data,time,starttimes,interval,endtimes,framesize,...
    regionInfo,valueDims)


    this.tsValue=initialize(SimTimeseries,...
    name,blockpath,portindex,signame,parentname,...
    data,time,starttimes,interval,endtimes,framesize,...
    regionInfo);




    this.blockpath=blockpath;
    this.portindex=portindex;
    this.parentname=parentname;
    this.SignalName=signame;
    this.RegionInfo=Simulink.RegionInfo(regionInfo);
    if exist('valueDims')
        if~isempty(valueDims)
            this.ValueDimensions=valueDims;
        end
    end

