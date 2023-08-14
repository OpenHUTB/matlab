function[ValidFFTWindow,Ywindow,twindow,StartTime,TotalCycles,DT,SamplesPerCycle,npoints]=verifyFFTAnalyzerSettings(t,Y,WarnMsg,StartTime,NumberOfCycles,Fundamental)






    ValidFFTWindow=1;
    Ywindow=1;
    twindow=1;

    TotalCycles=1;
    DT=1;
    SamplesPerCycle=1;
    npoints=1;
    switch WarnMsg
    case 'Warnings'
        DisplayWarnings=1;
        PopupWarn=1;
    case 'CmdLine'
        DisplayWarnings=1;
        PopupWarn=0;
    otherwise
        DisplayWarnings=0;
        PopupWarn=0;
    end


    CheckStartTime=1;
    if ischar(StartTime)
        if isequal(StartTime,'last')
            CheckStartTime=0;
        end
    end
    if CheckStartTime
        StartTime=StartTime(1);
        if StartTime<0||StartTime==Inf
            ValidFFTWindow=0;
            if DisplayWarnings
                Erreur.message='The start time must be a positive and finite value';
                Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
                if PopupWarn
                    psberror(Erreur.message,Erreur.identifier);
                else
                    psberror(Erreur)
                end
            end
            return
        end
    end

    NumberOfCycles=NumberOfCycles(1);
    if NumberOfCycles<=0||NumberOfCycles==Inf
        ValidFFTWindow=0;
        if DisplayWarnings
            Erreur.message='The number of cycles must be greater than zero and have a finite value.';
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end

    if~isequal(floor(NumberOfCycles),NumberOfCycles)
        ValidFFTWindow=0;
        if DisplayWarnings
            Erreur.message='The number of cycles must be an integer';
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end

    if Fundamental<=0||Fundamental==Inf
        ValidFFTWindow=0;
        if DisplayWarnings
            Erreur.message='The Fundamental frequency must be greater than zero and have a finite value.';
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end

    if CheckStartTime
        if StartTime<t(1)
            ValidFFTWindow=0;
            if DisplayWarnings
                Erreur.message=sprintf('The Start Time must be greater than %g sec. and have a finite value.',t(1));
                Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
                if PopupWarn
                    psberror(Erreur.message,Erreur.identifier);
                else
                    psberror(Erreur)
                end
            end
            return
        end
    end


    if isempty(t)||length(t)==1
        ValidFFTWindow=0;
        if DisplayWarnings
            Erreur.message='The selected signal contains no data.';
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end

    Tsimulation=t(end);

    deltasTs=t(1:end-1)-t(2:end);
    FixedStepSampled=all(abs(deltasTs-deltasTs(1))<1e-10);

    DT=t(2)-t(1);
    TotalSamples=length(Y);
    if~FixedStepSampled
        old_t=t;

        DT=Tsimulation/TotalSamples;
        t=(0:DT:Tsimulation)';
        Y=interp1(old_t,Y,t,'linear','extrap');
        TotalSamples=length(Y);
    end
    if DT>=1/(2*Fundamental)


        ValidFFTWindow=0;
        if DisplayWarnings
            Erreur.message='The sampling period of the selected signal is not small enough for the given fundamental frequency.';
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end

    SamplesPerCycle=1/Fundamental/DT;
    TotalCycles=Tsimulation*Fundamental;
    MinimumSimulationTime=NumberOfCycles/Fundamental;
    if TotalCycles<1
        ValidFFTWindow=0;
        if DisplayWarnings
            message=sprintf('The selected signal must contain at least 1 cycle of specified fundamental frequency (%gHz).',Fundamental);
            message=sprintf([message,'\n\nThe selected signal contains %g cycle of Fundamental Frequency.'],TotalCycles);
            message=sprintf([message,'\n\nThe minimum simulation time is defined as follow:\n(Number of cycles) / (Fundamental Frequency).\n\nSimulation time of the selected signal must be >=  %g sec.'],MinimumSimulationTime);
            message=sprintf([message,'\n\nSimulation time of the selected signal is = %g sec.'],Tsimulation);
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end


    if NumberOfCycles>TotalCycles
        ValidFFTWindow=0;
        if DisplayWarnings
            if TotalCycles==1
                message=sprintf('The specified number of cycles must be equal to 1');
            else
                message=sprintf('The specified number of cycles must be lower than or equal to the total number of cycles of selected signal (%g)',floor(TotalCycles));
            end
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end

    npoints=round(NumberOfCycles*SamplesPerCycle);
    if npoints>TotalSamples
        ValidFFTWindow=0;
        if DisplayWarnings
            Erreur.message='Simulation time of the signal is not enough long for the given fundamental frequency.';
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end
    MaxStartTimeValue=t(end-npoints+1);
    if CheckStartTime==0
        StartTime=MaxStartTimeValue;
    end
    StartSample=find((t<=StartTime),1,'last');
    StopSample=StartSample+npoints-1;
    if StopSample>TotalSamples
        ValidFFTWindow=0;
        if DisplayWarnings
            message='The specified Start time and Number of cycles is not set correctly. Reduce either the Start time value or the number of cycles.';
            MaxNumberOfCycles=floor((TotalSamples-StartSample)/SamplesPerCycle);
            if MaxNumberOfCycles>0
                message=sprintf([message,'\n\nThe maximum number of cycles for the specified start time is: %g.'],MaxNumberOfCycles);
            end
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end
    if StartTime>MaxStartTimeValue
        ValidFFTWindow=0;
        if DisplayWarnings
            Erreur.message=sprintf('The StartTime value must be less than or equal to %g sec. when the fundamental frequency is %gHz and specified number of cycles is %g ',MaxStartTimeValue,Fundamental,NumberOfCycles);
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            if PopupWarn
                psberror(Erreur.message,Erreur.identifier);
            else
                psberror(Erreur)
            end
        end
        return
    end
    twindow=t(StartSample:StopSample);
    Ywindow=Y(StartSample:StopSample);