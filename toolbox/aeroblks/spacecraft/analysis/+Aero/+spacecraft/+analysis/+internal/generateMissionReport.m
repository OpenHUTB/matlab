function filesave=generateMissionReport(blk,varargin)






    if~builtin('license','checkout','Aerospace_Blockset')||...
        ~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAero'));
    end

    p=inputParser;
    p.PartialMatching=false;

    addRequired(p,'blk');
    addOptional(p,'Filename','',@(x)validateattributes(x,{'char','string'},...
    {}));
    addOptional(p,'GroundStation','',@(x)validateattributes(x,{'char','string'},...
    {}));
    addParameter(p,'RuntimeSource','Dialog',@(x)validateattributes(x,{'char','string'},...
    {}));
    addParameter(p,'Runtime','',@(x)validateattributes(x,{'char','string'},...
    {}));
    addParameter(p,'EnableTOI','on',@(x)validateattributes(x,{'char','string'},...
    {}));
    addParameter(p,'TOI','',@(x)validateattributes(x,{'char','string'},...
    {}));
    addParameter(p,'Eta','',@(x)validateattributes(x,{'char','string'},...
    {}));
    parse(p,blk,varargin{:});
    blk=p.Results.blk;
    GroundStation=p.Results.GroundStation;

    assignin('base','cubesatModel',blk);
    if strcmp(p.Results.RuntimeSource,'Dialog')&&~isempty(evalin('base',p.Results.Runtime))
        assignin('base','AnalysisRunTime',evalin('base',p.Results.Runtime));
    else
        assignin('base','AnalysisRunTime',evalin('base',get_param(bdroot(blk),'StopTime')));
    end

    if~isempty(evalin('base',GroundStation))
        GroundStation=evalin('base',GroundStation);
        if numel(GroundStation)<2
            GroundStation(2)=GroundStation(1);
        end
        assignin('base','groundStationLat',GroundStation(1));
        assignin('base','groundStationLon',GroundStation(2));
    else

        evalin('base','clear groundStationLat groundStationLon');
    end

    if strcmp(p.Results.EnableTOI,'on')
        if~isempty(evalin('base',p.Results.TOI))
            assignin('base','timeOfInterest',...
            datetime(evalin('base',p.Results.TOI),'ConvertFrom','juliandate'));
        else

            assignin('base','timeOfInterest',...
            datetime(str2double(get_param(blk,'sim_t0')),'ConvertFrom','juliandate'));
        end
    else

        evalin('base','clear timeOfInterest');
    end
    if~isempty(evalin('base',p.Results.Eta))
        assignin('base','eta_toi',evalin('base',p.Results.Eta));
    else

        evalin('base','clear eta_toi');
    end

    if~isempty(p.Results.Filename)
        [fpath,fname,~]=fileparts(p.Results.Filename);
        if~isvarname(fname)
            fname=matlab.lang.makeValidName(fname);
        end
        filesave=fullfile(fpath,[fname,'.mlx']);
        if isfile(filesave)
            overwrite=questdlg(['There is already a file with the same name in this location.'...
            ,' Would you like to overwrite the existing file?'],...
            'Overwrite Existing file','Yes','No','Yes');
            if isempty(overwrite)||strcmp(overwrite,'No')
                return
            end
        end
    else
        filesave="CubeSatMissionReport_"+string(datetime("now"),'yyyyMMdd''T''HHmmSS')+".mlx";
    end

    copyfile(...
    fullfile(fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))))),...
    'templates','asbCubeSatMissionReportTemplate.mlx'),filesave,'f');
    open(filesave);
end
