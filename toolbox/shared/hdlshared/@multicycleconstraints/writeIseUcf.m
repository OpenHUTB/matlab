function writeIseUcf(obj)





    fname=obj.filepath;
    fid=fopen(fname,'w');


    msg=['Writing ISE multicycle constraints UCF file ','<a href="matlab:edit(''',fname,''')">',fname,'</a>'];
    hdldisp(msg);


    for i=1:length(obj.mcpinfo)
        tn=sprintf("TN_%s_%s",obj.mcpinfo(i).tcName,obj.mcpinfo(i).regName);
        ts=sprintf("TS_%s_%s",obj.mcpinfo(i).tcName,obj.mcpinfo(i).regName);
        fprintf(fid,'# Multicycle constraints for clock enable: %s\n',obj.mcpinfo(i).attrValue);
        fprintf(fid,'NET "*%s/%s" TNM_NET = FFS "%s";\n',obj.mcpinfo(i).tcName,obj.mcpinfo(i).regName,tn);
        fprintf(fid,'TIMESPEC "%s" = FROM "%s" TO "%s" TS_FPGA_CLK/%d;\n',ts,tn,tn,obj.mcpinfo(i).setupMultiplier);
        fprintf(fid,'\n');
    end
    fclose(fid);




end





