function getCurrentSpectrumData(obj,~,~)




    obj.IsNewDataReady=true;
    obj.IsNewMeasurementsDataReady=true;
    numSegments=obj.NumSegments;

    simulationTime={obj.SimulationTime};


    if~isFrequencyInputMode(obj)

        if numSegments~=1

            segmentTime=obj.pRawInputTotalSimTime/numSegments;
            simulationTime=(obj.SimulationTime:...
            segmentTime:...
            obj.SimulationTime+obj.pRawInputTotalSimTime-segmentTime);
            simulationTime=num2cell(simulationTime,1);

            frequencyVector=cell(numSegments,1);
        end

        obj.SpectrumData.SimulationTime=simulationTime;


        if obj.Plotter.NormalTraceFlag
            obj.SpectrumData.Spectrum=obj.ScaledPSD;
        end


        if isSpectrogramMode(obj)||isCombinedViewMode(obj)
            obj.SpectrumData.Spectrogram=obj.ScaledSpectrogram;
        end


        if obj.Plotter.MinHoldTraceFlag
            obj.SpectrumData.MinHoldTrace=obj.ScaledMinHoldTrace;
        end


        if obj.Plotter.MaxHoldTraceFlag
            obj.SpectrumData.MaxHoldTrace=obj.ScaledMaxHoldTrace;
        end

        frequencyVector(:)={obj.CurrentFVector+obj.Plotter.FrequencyOffset};

        obj.SpectrumData.FrequencyVector=frequencyVector;
    else


        obj.SpectrumData.SimulationTime=simulationTime;


        if obj.Plotter.NormalTraceFlag
            obj.SpectrumData.Spectrum={obj.ScaledFrequencyInputData};
        end


        if isSpectrogramMode(obj)||isCombinedViewMode(obj)
            obj.SpectrumData.Spectrogram=obj.ScaledSpectrogram;
        end

        if obj.Plotter.MinHoldTraceFlag

            obj.SpectrumData.MinHoldTrace={obj.CurrentMinHoldPSD};
        end


        if obj.Plotter.MaxHoldTraceFlag

            obj.SpectrumData.MaxHoldTrace={obj.CurrentMaxHoldPSD};
        end


        obj.SpectrumData.FrequencyVector={obj.CurrentFVector+obj.Plotter.FrequencyOffset};
    end

    obj.SpectrumData.SpectrumUnits=obj.pSpectrumUnits;
end