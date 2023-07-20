function data=getSpectrumData(this,allFlag)





    if nargin<2
        allFlag=false;
    end

    if isempty(this.pCachedSpectrumData)

        this.pCachedSpectrumData=createEmptySpectrumDataTable(this,1);
    end

    allData=this.pCachedSpectrumData;
    enabledData=this.pCachedEnabledData;
    numSegments=this.NumSegments;
    if this.IsNewDataReady
        if size(allData,1)<numSegments

            allData=createEmptySpectrumDataTable(this,numSegments);
            allData.Properties.VariableUnits={
            's',...
            this.pSpectrumUnits,...
            this.pSpectrumUnits,...
            this.pSpectrumUnits,...
            this.pSpectrumUnits,...
            'Hz'};

        end


        allData.SimulationTime(1:numSegments)=this.SpectrumData.SimulationTime(1:numSegments).';
        isValidForSpectrum=any(strcmpi(this.pViewType,{'Spectrum','Spectrum and spectrogram'}));
        isValidForSpectrogram=any(strcmpi(this.pViewType,{'Spectrogram','Spectrum and spectrogram'}));

        allData.Spectrum(1:numSegments)=cell(numSegments,1);
        allData.Spectrogram(1:numSegments)=cell(numSegments,1);
        allData.MinHoldTrace(1:numSegments)=cell(numSegments,1);
        allData.MaxHoldTrace(1:numSegments)=cell(numSegments,1);

        if getPropertyValue(this,'NormalTrace')&&isValidForSpectrum
            allData.Spectrum(1:numSegments)=this.SpectrumData.Spectrum(1:numSegments);
            enabledData(2)=true;
        else
            enabledData(2)=false;
        end

        if isValidForSpectrogram
            allData.Spectrogram(1:numSegments)=this.SpectrumData.Spectrogram(1:numSegments);
            enabledData(3)=true;
        else
            enabledData(3)=false;
        end

        if getPropertyValue(this,'MinHoldTrace')&&isValidForSpectrum
            allData.MinHoldTrace(1:numSegments)=this.SpectrumData.MinHoldTrace(1:numSegments);
            enabledData(4)=true;
        else
            enabledData(4)=false;
        end

        if getPropertyValue(this,'MaxHoldTrace')&&isValidForSpectrum
            allData.MaxHoldTrace(1:numSegments)=this.SpectrumData.MaxHoldTrace(1:numSegments);
            enabledData(5)=true;
        else
            enabledData(5)=false;
        end

        allData.FrequencyVector(1:numSegments)=this.SpectrumData.FrequencyVector(1:numSegments).';


        if isempty(allData.Properties.VariableUnits)||~strcmpi(allData.Properties.VariableUnits{2},this.SpectrumData.SpectrumUnits)
            allData.Properties.VariableUnits={
            's',...
            this.SpectrumData.SpectrumUnits,...
            this.SpectrumData.SpectrumUnits,...
            this.SpectrumData.SpectrumUnits,...
            this.SpectrumData.SpectrumUnits,...
            'Hz'};
        end

        this.pCachedSpectrumData=allData;

        this.pCachedEnabledData=enabledData;

        allData=allData(1:numSegments,:);
        this.IsNewDataReady=false;
    else
        allData=this.pCachedSpectrumData(1:numSegments,:);
    end

    if~allFlag
        idx=enabledData;
        data=allData(:,idx);
    else
        data=allData;
    end
end