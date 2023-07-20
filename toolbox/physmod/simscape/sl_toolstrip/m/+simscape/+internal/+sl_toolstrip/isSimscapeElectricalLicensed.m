function[value,msg]=isSimscapeElectricalLicensed(~)




    value=~isempty(ver('sps'))&&license('test','Power_System_Blocks');
    msg='';
end