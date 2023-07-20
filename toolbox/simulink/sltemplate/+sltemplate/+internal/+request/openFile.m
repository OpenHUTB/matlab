function closeStartPage=openFile(filename)




    escapedFile=strrep(filename,'''','''''');


    [~,~,ext]=fileparts(filename);
    if strcmpi(ext,'.mat')
        functionName='load';
    else
        functionName='open';
    end
    evalin('base',[functionName,'(''',escapedFile,''');']);

    closeStartPage=~strcmp(ext,'.sltx');

end