function rptFolder=getRptFolder()




    workFolder=Simulink.fileGenControl('get','CodeGenFolder');
    if isempty(workFolder)
        workFolder=pwd;
    end
    rptFolder=fullfile(workFolder,'rmirpt');

end