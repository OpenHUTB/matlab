function waveletNumbers=getWaveletNumbers(waveletName)



    waveletNumbers=cellstr(wavemngr("tabnums",waveletName));
    waveletNumbers(strcmpi(waveletNumbers,"**"))=[];
    waveletNumbers=waveletNumbers(:);
end