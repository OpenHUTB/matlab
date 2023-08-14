function logOut=logCubeSatMission(Model,varargin)









    if~builtin('license','checkout','Aerospace_Blockset')||...
        ~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAero'));
    end


    try %#ok<TRYNC>

        if~isvarname(Model)
            Model=eval(Model);
        end
    end
    if~isempty(Model)&&iscell(Model)
        [Model{:}]=convertStringsToChars(Model{:});
    end
    [varargin{:}]=convertStringsToChars(varargin{:});

    p=inputParser;
    p.KeepUnmatched=true;
    p.PartialMatching=false;

    addRequired(p,'Model',@(x)validateattributes(x,{'cell','char','string'},{},'logCubeSatMission',...
    'Model'));
    addParameter(p,'JulianStartDate',[],@(x)validateattributes(x,{'numeric'},...
    {'real','finite','nonnan'},'logCubeSatMission','JulianStartDate'));
    addParameter(p,'AnalysisRunTime',[],@(x)validateattributes(x,{'numeric'},...
    {'real','finite','nonnan'},'logCubeSatMission','AnalysisRunTime'));
    addParameter(p,'PrintModel',false,@(x)validateattributes(x,{'logical'},...
    {'binary'},'logCubeSatMission','PrintModel'));
    addParameter(p,'promptTemplate',true,@(x)validateattributes(x,{'logical'},...
    {'binary'},'logCubeSatMission','promptTemplate'));
    parse(p,Model,varargin{:});
    Model=p.Results.Model;
    JulianStartDate=p.Results.JulianStartDate;
    AnalysisRunTime=p.Results.AnalysisRunTime;

    if~iscell(Model)
        if isempty(Model)
            if p.Results.promptTemplate
                createTemplate=questdlg(['Would you like to create a new CubeSat Orbit Propagation Model?'...
                ,' To use an existing model, provide a model name in the ''Mission Definition'' Section.'],...
                'Create New Template Model','Yes','No','Yes');
            else
                createTemplate='Yes';
            end
            if~isempty(createTemplate)&&strcmp(createTemplate,'Yes')
                Model={getfullname(Simulink.createFromTemplate('asbCubeSatVehicleTemplate.sltx'))};
                open_system(Model{1});
                set_param([Model{1},'/Simulink 3D Animation'],'enableVis','off');
                vrmfunc('FnClose',[Model{1},'/Simulink 3D Animation/VR Sink']);
            else
                return
            end
        else
            Model={Model};
        end
    end
    load_system(Model);


    vehicleBlocks=find_system(Model,...
    LookUnderMasks='all',...
    MatchFilter=@Simulink.match.activeVariants,...
    MaskType='CubeSat Vehicle');
    numCubeSats=numel(vehicleBlocks);
    if numCubeSats<1
        error('No CubeSat Vehicle blocks identified in model.')
    end


    cubesatFields=fieldnames(p.Unmatched);
    cubesatValues=struct2cell(p.Unmatched);


    if numCubeSats>1&&~all(cellfun(@isempty,cubesatValues))
        warning(['Varying orbital parameters is only allowed when one CubeSat Vehicle'...
        ,' block is present. Using parameter values from the block masks.']);
        cubesatFields={};
        cubesatValues={};
    else
        emptyValues=cellfun(@isempty,cubesatValues);
        cubesatFields(emptyValues)=[];
        cubesatValues(emptyValues)=[];

        cubesatValues=cellfun(@eval,cubesatValues,'UniformOutput',false);
    end


    if~isempty(JulianStartDate)
        cubesatFields{end+1}='sim_t0';
        cubesatValues{end+1}=JulianStartDate;
    end

    if numCubeSats==1

        orbitalElems={'a','ecc','incl','omega','argp','nu','truelon',...
        'arglat','lonper','sim_t0'};
        tableElems={'SemiMajorAxis_m','Eccentricity','Inclination_deg',...
        'RAAN_deg','ArgP_deg','TrueAnomoly_deg','TrueLon_deg',...
        'ArgLat_deg','LonOfPeriapsis_deg','JulianStartDate'};
        orbIdx=0;
        for currEl=orbitalElems
            orbIdx=orbIdx+1;
            if ismember(currEl,cubesatFields)
                eval(sprintf('%s = cubesatValues{ismember(cubesatFields,currEl{1})};',tableElems{orbIdx}));
            else
                eval(sprintf('%s = eval(get_param(vehicleBlocks{1}, currEl{1}));',tableElems{orbIdx}));
            end
        end
        if isempty(AnalysisRunTime)
            AnalysisRunTime=str2double(get_param(bdroot(vehicleBlocks{1}),'StopTime'));
        end
        format long
        t1=table(JulianStartDate,AnalysisRunTime,SemiMajorAxis_m,Eccentricity,Inclination_deg,...
        RAAN_deg,ArgP_deg,TrueAnomoly_deg,TrueLon_deg,ArgLat_deg,LonOfPeriapsis_deg);
        disp(t1(:,1:5))
        disp(t1(:,6:end))
    end

    for idx=1:numel(Model)

        in(idx)=Simulink.SimulationInput(bdroot(Model{idx}));%#ok<*AGROW>
        loggingSpec=Simulink.Simulation.LoggingSpecification();
        vehicle=vehicleBlocks(contains(vehicleBlocks,Model{idx}));

        cubesatParams=[repmat(vehicle,size(cubesatFields(:))),...
        repmat(cubesatFields(:),size(vehicle)),repmat(cellfun(@num2str,cubesatValues(:),...
        'UniformOutput',false),size(vehicle))]';
        cubesatParams=cubesatParams(:);

        for jdx=1:numel(vehicle)

            sgnl=Simulink.SimulationData.SignalLoggingInfo(vehicle{jdx},1);
            sgnl.LoggingInfo.DataLogging=true;
            sgnl.LoggingInfo.NameMode=true;
            sgnl.LoggingInfo.LoggingName=['pos_ecef_cubesat',num2str(jdx)];
            loggingSpec.addSignalsToLog(sgnl);



            if~isempty(cubesatParams)
                in(idx)=in(idx).setBlockParameter(cubesatParams{:});
            end
        end


        in(idx)=in(idx).setModelParameter('SignalLogging','on',...
        'SignalLoggingName','cubesatvehicle_log');

        if~isempty(p.Results.AnalysisRunTime)
            in(idx)=in(idx).setModelParameter('StopTime',num2str(AnalysisRunTime));
        end


        in(idx).LoggingSpecification=loggingSpec;
    end


    for idx=1:numel(Model)
        simOut(idx)=sim(in(strcmp(bdroot(Model{idx}),{in(:).ModelName})));
    end
    if numel(Model)>1
        logOut=concat(simOut(:).cubesatvehicle_log);
    else
        logOut=simOut.cubesatvehicle_log;
    end

    if numel(Model)==1&&p.Results.PrintModel
        try
figure
            print('-dpng',['-s',bdroot(Model{1})],fullfile(tempdir,'cubesat_tempcapture.png'))
            imshow(fullfile(tempdir,'cubesat_tempcapture.png'))
        catch
        end
    end

end
