function generateVivadoTclFindAndDeleteConstant(fid,connectionPin)




    fprintf(fid,...
    'delete_bd_objs [get_bd_cells -of_objects [get_bd_nets -of_objects [get_bd_pins %s]] -filter {VLNV =~ "xilinx.com:ip:xlconstant:*" }]\n',...
    connectionPin);

end