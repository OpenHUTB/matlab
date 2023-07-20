function writeVivadoXdc(obj)





    fname=obj.filepath;
    fid=fopen(fname,'w');


    msg=['Writing Vivado multicycle constraints XDC file ','<a href="matlab:edit(''',fname,''')">',fname,'</a>'];
    hdldisp(msg);

    clockInfo=struct.empty;




    for i=1:length(obj.mcpinfo)
        fprintf(fid,'# Multicycle constraints for clock enable: %s\n',obj.mcpinfo(i).attrValue);
        fprintf(fid,'set enbregcell [get_cells -hier -filter {mcp_info=="%s"}]\n',obj.mcpinfo(i).attrValue);
        fprintf(fid,'set enbregnet [get_nets -of_objects [get_pins -of_objects $enbregcell -filter {DIRECTION == OUT}]]\n');
        fprintf(fid,'set reglist%d [get_cells -of [filter [all_fanout -flat -endpoints_only $enbregnet] IS_ENABLE]]\n',i);
        fprintf(fid,'set_multicycle_path %d -setup -from $reglist%d -to $reglist%d -quiet\n',...
        obj.mcpinfo(i).setupMultiplier,i,i);
        fprintf(fid,'set_multicycle_path %d -hold -from $reglist%d -to $reglist%d -quiet\n',...
        obj.mcpinfo(i).holdMultiplier,i,i);
        fprintf(fid,'\n');
        clockInfo(end+1).reglistName=sprintf('$reglist%d',i);
        clockInfo(end).downRate=obj.mcpinfo(i).setupMultiplier;
        clockInfo(end).clockName=obj.mcpinfo(i).attrValue;
        clockInfo(end).offset=obj.mcpinfo(i).offset;

    end




    for i=1:length(clockInfo)
        for j=i+1:length(clockInfo)


            if clockInfo(j).downRate==clockInfo(i).downRate...
                &&clockInfo(j).offset~=clockInfo(i).offset

                constraintInfo=getconstraintInfoCase2(...
                clockInfo(j),clockInfo(i));


                fprintf(fid,'# Multicycle constraints from clock enable: %s to clock enable: %s\n',...
                constraintInfo.enableSignal1,constraintInfo.enableSignal2);
                fprintf(fid,'set_multicycle_path %d -setup -from %s -to %s -quiet\n',...
                constraintInfo.downRateSetup1,constraintInfo.reglist1,constraintInfo.reglist2);
                fprintf(fid,'set_multicycle_path %d -hold -from %s -to %s -quiet\n',...
                constraintInfo.downRateHold1,constraintInfo.reglist1,constraintInfo.reglist2);
                fprintf(fid,'\n');


                fprintf(fid,'# Multicycle constraints from clock enable: %s to clock enable: %s\n',...
                constraintInfo.enableSignal2,constraintInfo.enableSignal1);
                fprintf(fid,'set_multicycle_path %d -setup -from %s -to %s -quiet\n',...
                constraintInfo.downRateSetup2,constraintInfo.reglist2,constraintInfo.reglist1);
                fprintf(fid,'set_multicycle_path %d -hold -from %s -to %s -quiet\n',...
                constraintInfo.downRateHold2,constraintInfo.reglist2,constraintInfo.reglist1);
                fprintf(fid,'\n');

                continue;
            end




























































        end
    end
    fclose(fid);
end



function constraintInfo=getconstraintInfoCase2(clockInfo1,clockInfo2)

    constraintInfo.enableSignal1=clockInfo1.clockName;
    constraintInfo.enableSignal2=clockInfo2.clockName;
    constraintInfo.reglist1=clockInfo1.reglistName;
    constraintInfo.reglist2=clockInfo2.reglistName;

    if(clockInfo1.offset==0)
        constraintInfo.downRateSetup1=clockInfo1.downRate+1;
        constraintInfo.downRateHold1=clockInfo1.downRate-1;
        constraintInfo.downRateSetup2=clockInfo1.downRate-1;
        constraintInfo.downRateHold2=clockInfo1.downRate-1;
    else
        constraintInfo.downRateSetup1=clockInfo2.downRate-1;
        constraintInfo.downRateHold1=clockInfo2.downRate-1;
        constraintInfo.downRateSetup2=clockInfo2.downRate+1;
        constraintInfo.downRateHold2=clockInfo2.downRate-1;
    end
end



function constraintInfo=getconstraintInfoCase3(clockInfo1,clockInfo2)

    constraintInfo.enableSignal1=clockInfo1.clockName;
    constraintInfo.enableSignal2=clockInfo2.clockName;
    constraintInfo.reglist1=clockInfo1.reglistName;
    constraintInfo.reglist2=clockInfo2.reglistName;
    if(clockInfo1.downRate>clockInfo2.downRate)
        constraintInfo.downRateSetup=clockInfo1.downRate;
        constraintInfo.downRateHold=clockInfo1.downRate-1;

    else
        constraintInfo.downRateSetup=clockInfo2.downRate;
        constraintInfo.downRateHold=clockInfo2.downRate-1;
    end
end



function constraintInfo=getconstraintInfoCase4(clockInfo1,clockInfo2)

    constraintInfo.enableSignal1=clockInfo1.clockName;
    constraintInfo.enableSignal2=clockInfo2.clockName;
    constraintInfo.reglist1=clockInfo1.reglistName;
    constraintInfo.reglist2=clockInfo2.reglistName;
    if(clockInfo1.offset==0)
        if(clockInfo1.downRate>clockInfo2.downRate)


            constraintInfo.downRateSetup1=clockInfo1.downRate+1;
            constraintInfo.downRateHold1=clockInfo1.downRate-1;
            constraintInfo.downRateSetup2=clockInfo1.downRate-1;
            constraintInfo.downRateHold2=clockInfo1.downRate-1;

        else


            constraintInfo.downRateSetup1=clockInfo2.downRate+1;
            constraintInfo.downRateHold1=clockInfo2.downRate-1;
            constraintInfo.downRateSetup2=clockInfo2.downRate-1;
            constraintInfo.downRateHold2=clockInfo2.downRate-1;

        end
    else
        if(clockInfo1.downRate>clockInfo2.downRate)


            constraintInfo.downRateSetup1=clockInfo1.downRate-1;
            constraintInfo.downRateHold1=clockInfo1.downRate-1;
            constraintInfo.downRateSetup2=clockInfo1.downRate+1;
            constraintInfo.downRateHold2=clockInfo1.downRate-1;

        else


            constraintInfo.downRateSetup1=clockInfo2.downRate-1;
            constraintInfo.downRateHold1=clockInfo2.downRate-1;
            constraintInfo.downRateSetup2=clockInfo2.downRate+1;
            constraintInfo.downRateHold2=clockInfo2.downRate-1;

        end

    end
end




