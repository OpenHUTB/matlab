



function codeTrFile=checkCodeCompile(modelName,simMode)


    codeTrFile='';

    persistent isRequiredProductInstalled;
    if isempty(isRequiredProductInstalled)
        isRequiredProductInstalled=license('test','RTW_Embedded_Coder');
    end
    if~isRequiredProductInstalled
        return
    end


    narginchk(2,2);
    validateattributes(modelName,{'char','string'},{'scalartext','nonempty'})
    modelName=char(modelName);
    simMode=validatestring(simMode,slcoverage.Selector.SupportedXILModes);


    if strcmpi(simMode,'sil')
        simModes={'SIL'};
        simMode=SlCov.Utils.SIM_SIL_MODE_STR;
    elseif strcmpi(simMode,'pil')
        simModes={'PIL'};
        simMode=SlCov.Utils.SIM_PIL_MODE_STR;
    elseif strcmpi(simMode,'xil')
        simModes={'SIL','PIL'};
        simMode=SlCov.Utils.SIM_SIL_MODE_STR;
    elseif strcmpi(simMode,'modelrefsil')
        simModes={'ModelRefSIL'};
        simMode=[];
    elseif strcmpi(simMode,'modelrefpil')
        simModes={'ModelRefPIL'};
        simMode=[];
    elseif strcmpi(simMode,'modelrefxil')
        simModes={'ModelRefSIL','ModelRefPIL'};
        simMode=[];
    end
    dbFiles=cell(1,numel(simModes));


    for ii=1:numel(simModes)
        moduleName=SlCov.coder.EmbeddedCoder.buildModuleName(modelName,simModes{ii});
        dbFiles{ii}=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);
        if isfile(dbFiles{ii})
            codeTrFile=dbFiles{ii};
            return
        end
    end




    if get_param(modelName,'IsERTTarget')~="on"||isempty(simMode)
        return
    end
    try
        cmd=sprintf('cvsim(''%s'', ''SimulationMode'', ''%s'', ''StopTime'', ''0'')',...
        modelName,simMode);
        [~,cvd,simOuts]=evalc(cmd);
        isOK=~isempty(cvd)&&(isa(cvd,'cvdata')||isa(cvd,'cv.cvdatagroup'));
        if~isOK&&~isempty(simOuts)&&...
            isa(simOuts(1),'Simulink.SimulationOutput')&&...
            ~isempty(simOuts(1).ErrorMessage)
            warning(simOuts(1).ErrorMessage);
        end
    catch


    end

    if isfile(dbFiles{1})
        codeTrFile=dbFiles{1};
    end

