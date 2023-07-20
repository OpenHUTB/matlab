function generateVivadoTclInsertIP(fid,ipName,ipZipName,ipVersion,ipRepo,instName)



    ipComp=fullfile(ipRepo,ipZipName,'component.xml');
    fprintf(fid,'update_ip_catalog -delete_ip {%s} -repo_path {%s} -quiet\n',ipComp,ipRepo);


    ipZip=fullfile(ipRepo,[ipZipName,'.zip']);
    fprintf(fid,'update_ip_catalog -add_ip {%s} -repo_path {%s}\n',ipZip,ipRepo);
    fprintf(fid,'update_ip_catalog\n');



    fprintf(fid,'set HDLCODERINSERTVLNV [get_property VLNV [get_ipdefs -filter {NAME==%s && VERSION==%s}]]\n',...
    ipName,ipVersion);


    fprintf(fid,'create_bd_cell -type ip -vlnv $HDLCODERINSERTVLNV %s\n',instName);

end