function openType=openRecordUI(blockId,blockHandle,openType,appId,varargin)





















    try
        opts=locParseInput(blockId,blockHandle,openType,appId,varargin{:});
        obj=Simulink.record.RecordUI(opts);
        openType=obj.OpenType;
    catch me
        msg=message('record_playback:errors:RecordBlockUILoadFailure',me.message);
        error(msg);
    end

end

function opts=locParseInput(blockId,blockHandle,openType,appId,varargin)
    p=inputParser;


    addRequired(p,'BlockId',@ischar);
    addRequired(p,'BlockHandle',@isnumeric);
    addRequired(p,'OpenType',@ischar);
    addRequired(p,'AppId',@ischar);



    addParameter(p,'Title','StreamOut Block',@ischar);
    addParameter(p,'Domain','StreamOut Block',@ischar);
    addParameter(p,'BlockPath','',@ischar);

    parse(p,blockId,blockHandle,openType,appId,varargin{:});
    opts=p.Results;
end