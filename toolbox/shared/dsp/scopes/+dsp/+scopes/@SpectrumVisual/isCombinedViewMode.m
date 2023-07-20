function flag=isCombinedViewMode(this)





    flag=~isCCDFMode(this)&&strcmp(this.pViewType,'Spectrum and spectrogram');
end
