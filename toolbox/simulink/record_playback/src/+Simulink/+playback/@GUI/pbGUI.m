function playbackGUI=pbGUI(blockId,blockHandle,appId,varargin)

    opts=locParseInput(blockId,blockHandle,appId,varargin{:});


    playbackGUI=Simulink.playback.GUI.getSetGUI(opts.BlockId);

    if isempty(playbackGUI)
        playbackGUI=Simulink.playback.mainApp(opts);
        Simulink.playback.GUI.getSetGUI(opts.BlockId,playbackGUI);
    elseif~strcmp(playbackGUI.Config.BlockPath,opts.BlockPath)
        playbackGUI.Config.BlockPath=opts.BlockPath;
        playbackGUI.AddDataUi.Config.BlockPath=opts.BlockPath;
    end
end

function opts=locParseInput(viewId,blockHandle,appId,varargin)
    p=inputParser;


    addRequired(p,'BlockId',@ischar);
    addRequired(p,'BlockHandle',@isnumeric);
    addRequired(p,'AppId',@isnumeric);


    addParameter(p,'Title','Playback Block',@ischar);
    addParameter(p,'Position',[],@isnumeric);
    addParameter(p,'OpenType','default',@ischar);
    addParameter(p,'BlockPath','',@ischar);

    parse(p,viewId,blockHandle,appId,varargin{:});
    opts=p.Results;
end
