function flag=isSpectrogramMode(this)





    flag=~isCCDFMode(this)&&strcmp(this.pViewType,'Spectrogram');
end
