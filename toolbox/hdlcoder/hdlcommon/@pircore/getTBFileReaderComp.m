function tbFileReaderComp=getTBFileReaderComp(hN,hInSigs,hOutSigs,...
    fileName,compName)


    narginchk(5,5);
    tbFileReaderComp=hN.addComponent2(...
    'kind','tb_filereader_comp',...
    'Name',compName,...
    'InputSignals',hInSigs,...
    'OutputSignals',hOutSigs,...
    'FileName',fileName);
end


