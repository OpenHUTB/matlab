function cktFile=sparam2spice(tsFile,varargin)

    cktFile=[];
    validateattributes(tsFile,{'char','string'},{'nonempty'});
    tsFile=convertStringsToChars(tsFile);

    p=inputParser;
    p.FunctionName='sparam2spice';
    addParameter(p,'OutputFile',[char(tsFile),'_sparam2spice.ckt'],...
    @(x)~isempty(x)&&(ischar(x)||isstring(x)));
    addParameter(p,'LogFile',[],...
    @(x)~isempty(x)&&(ischar(x)||isstring(x)));
    addParameter(p,'Tolerance',-40,...
    @(x)~isempty(x)&&isnumeric(x)&&isscalar(x));
    addParameter(p,'NPoles',200,...
    @(x)~isempty(x)&&isnumeric(x)&&length(x)<=2);
    addParameter(p,'MakePassive',false,...
    @(x)~isempty(x)&&(islogical(x)||isnumeric(x))&&isscalar(x));
    addParameter(p,'ShowPassivity',false,...
    @(x)~isempty(x)&&(islogical(x)||isnumeric(x))&&isscalar(x));
    parse(p,varargin{:});

    if~isempty(p.Results.LogFile)
        logFile=fopen(p.Results.LogFile,'w');
        if logFile>=0
            fprintf(logFile,...
            "sparam2spice('%s',\n  OutputFile='%s',"+...
            "\n  Tolerance=%0.2f,\n  NPoles=%d,"+...
            "\n  MakePassive=%s,\n  ShowPassivity=%s)\n",...
            tsFile,p.Results.OutputFile,p.Results.Tolerance,...
            p.Results.NPoles,string(p.Results.MakePassive),...
            string(p.Results.ShowPassivity));
        else

            warning(...
            getString(message("si:sparam:LogFileWarn",p.Results.LogFile)));
            logFile=1;
        end
    else
        logFile=[];
    end

    if exist(tsFile,'file')==2

        sparamLogPrintf(logFile,"%s\n",...
        getString(message("si:sparam:LogReadInput")));
        try
            S=sparameters(tsFile);
        catch exception
            sparamLogPrintf(logFile,'%s: %s\n',...
            getString(message("si:sparam:LogSparamErr")),exception.message);
            if logFile>0
                fclose(logFile);
            end
            throw(exception);
        end
        sparamLogPrintf(logFile,'  %-25s : %d\n',...
        getString(message("si:sparam:LogNumPorts")),S.NumPorts);
        sparamLogPrintf(logFile,'  %-25s : %d\n',...
        getString(message("si:sparam:LogNumFreqs")),length(S.Frequencies));
        sparamLogPrintf(logFile,'  %-25s : %d\n',...
        getString(message("si:sparam:LogRefImp")),S.Impedance);

        sparamLogPrintf(logFile,'%s\n',...
        getString(message("si:sparam:LogFitSparam")));
        fit=sparamRationalFit(S,p.Results.Tolerance,...
        p.Results.NPoles,logFile);
        sparamLogPrintf(logFile,'  %-25s : %0.2fdB\n',...
        getString(message("si:sparam:LogFitAccuracy")),...
        fit.ErrDB);

        if p.Results.ShowPassivity
            figure(Name=getString(message("si:sparam:TitlePassBefore")));
            passivity(fit);
        end

        if p.Results.MakePassive
            sparamLogPrintf(logFile,'%s\n',...
            getString(message("si:sparam:LogPassFitStart")));
            pfit=sparamMakePassive(fit,logFile);
            sparamLogPrintf(logFile,'  %-25s : %0.2fdB\n',...
            getString(message("si:sparam:LogPassAccuracy")),...
            pfit.ErrDB);

            worstAllowableTolerance=-25;
            if pfit.ErrDB>p.Results.Tolerance&&...
                p.Results.Tolerance<worstAllowableTolerance
                toleranceIncr=floor((worstAllowableTolerance-...
                p.Results.Tolerance)/3);
                for newFitTol=p.Results.Tolerance+toleranceIncr:toleranceIncr:worstAllowableTolerance
                    sparamLogPrintf(logFile,'%s\n',...
                    getString(message("si:sparam:LogFitSparamRetry",...
                    newFitTol)));
                    fit=sparamRationalFit(S,newFitTol,p.Results.NPoles,...
                    logFile);
                    sparamLogPrintf(logFile,'  %-25s : %0.2fdB\n',...
                    getString(message("si:sparam:LogFitAccuracy")),...
                    fit.ErrDB);
                    sparamLogPrintf(logFile,'%s\n',...
                    getString(message("si:sparam:LogPassFitStart")));
                    pfit=sparamMakePassive(fit,logFile);
                    sparamLogPrintf(logFile,'  %-25s : %0.2fdB\n',...
                    getString(message("si:sparam:LogPassAccuracy")),...
                    pfit.ErrDB);

                    if pfit.ErrDB<p.Results.Tolerance
                        break;
                    end
                end
            end

            if p.Results.ShowPassivity
                figure(Name=getString(message("si:sparam:TitlePassAfter")));
                passivity(pfit);
            end
        else
            pfit=fit;
        end

        sparamLogPrintf(logFile,'%s\n',...
        getString(message("si:sparam:LogSpiceGen")));
        try
            generateSPICE(pfit,p.Results.OutputFile,S.Impedance);
            cktFile=p.Results.OutputFile;
        catch exception
            sparamLogPrintf(logFile,'%s: %s\n',...
            getString(message("si:sparam:LogSpiceErr")),...
            exception.message);
            if logFile>0
                fclose(logFile);
            end
            throw(exception);
        end
    else
        sparamLogPrintf(logFile,'%s\n',...
        getString(message("si:sparam:InputFileErr",tsFile)));
    end

    if~isempty(logFile)
        fclose(logFile);
    end
end


function fit=sparamRationalFit(S,tolerance,nPoles,logFile)%#ok<INUSL>
    cmd=char(strjoin(["rational(S,"...
    ,"'Tolerance',tolerance,"...
    ,"'MaxPoles',nPoles,"...
    ,"'Display','on')"]));
    try
        [text,fit]=evalc(cmd);
    catch exception
        sparamLogPrintf(logFile,'%s: %s\n',...
        getString(message("si:sparam:LogRatFitErr")),...
        exception.message);
        if logFile>0
            fclose(logFile);
        end
        throw(exception);
    end
    if~isempty(text)
        sparamLogPrintf(logFile,'%s',text);
    end
end


function pfit=sparamMakePassive(fit,logFile)%#ok<INUSL>
    cmd=char("makepassive(fit,'Display','on')");
    try
        [text,pfit]=evalc(cmd);
    catch exception
        sparamLogPrintf(logFile,': %s\n',...
        getString(message("si:sparam:LogPassFitErr")),...
        exception.message);
        if logFile>0
            fclose(logFile);
        end
        throw(exception);
    end
    if~isempty(text)
        sparamLogPrintf(logFile,'%s',text);
    end
end


function sparamLogPrintf(logFile,varargin)
    if~isempty(logFile)
        fprintf(logFile,varargin{:});
    end
end


