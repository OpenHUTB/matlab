function spectrumData=createEmptySpectrumDataTable(this,numSegments)





    if numSegments==1
        spectrumData=table({[]},{[]},{[]},{[]},{[]},{[]},'VariableNames',this.SpectrumDataFieldNames);
    else
        data=cell(numSegments,numel(this.SpectrumDataFieldNames));
        spectrumData=cell2table(data);
        spectrumData.Properties.VariableNames=this.SpectrumDataFieldNames;
    end
end