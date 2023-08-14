function writeQuartusSdc(obj)





    fname=obj.filepath;
    fid=fopen(fname,'w');


    msg=['Writing Quartus multicycle constraints SDC file ','<a href="matlab:edit(''',fname,''')">',fname,'</a>'];
    hdldisp(msg);


    for i=1:length(obj.mcpinfo)
        fprintf(fid,'# Multicycle constraints for clock enable: %s\n',obj.mcpinfo(i).attrValue);
        fprintf(fid,'set enbreg [get_registers *%s|%s]\n',obj.mcpinfo(i).tcName,obj.mcpinfo(i).regName);
        fprintf(fid,'set_multicycle_path %d -to [get_fanouts $enbreg -through [get_pins -hier *|ena]] -end -setup\n',obj.mcpinfo(i).setupMultiplier);
        fprintf(fid,'set_multicycle_path %d -to [get_fanouts $enbreg -through [get_pins -hier *|ena]] -end -hold\n',obj.mcpinfo(i).setupMultiplier-1);
        fprintf(fid,'\n');
    end
    fclose(fid);

end




