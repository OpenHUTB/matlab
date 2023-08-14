function generateHdlCoreLibero(fid,topModuleFile)




    [~,fileName,~]=fileparts(topModuleFile);



    fprintf(fid,'# Create HDL Core to Instiantiate in SmartDesign\n');
    fprintf(fid,'create_hdl_core -file %s -module %s \n\n',[hdlturnkey.ip.IPEmitterLibero.HDLFolder,'/',topModuleFile],fileName);

end

