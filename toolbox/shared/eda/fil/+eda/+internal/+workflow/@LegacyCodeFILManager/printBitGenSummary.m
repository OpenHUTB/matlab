function printBitGenSummary(h)



    s1=l_addPathQuote(h.BitFile.FileName);
    s2=l_addPathQuote(h.BitFile.FullPath);

    if strcmpi(h.mBuildInfo.BoardObj.Component.PartInfo.FPGAVendor,'Altera')&&contains(h.mBuildInfo.BoardObj.Component.Communication_Channel,'SGMII','IgnoreCase',true)
        [a,b,c]=fileparts(s1);
        s3=l_addPathQuote(fullfile(a,[b,'_time_limited',c]));
        [a,b,c]=fileparts(s2);
        s4=l_addPathQuote(fullfile(a,[b,'_time_limited',c]));

        expfile={...
'if [file exists %s3] {'...
        ,'    set expected_file %s3'...
        ,'    set copied_file %s4'...
        ,'    lappend log "Generated time-limited FPGA programming file."'...
        ,'} else {'...
        ,'    set expected_file %s1'...
        ,'    set copied_file %s2'...
        ,'}'};
        expfile=strrep(expfile,'%s3',s3);
        expfile=strrep(expfile,'%s4',s4);

    else
        expfile={...
'set expected_file %s1'...
        ,'set copied_file %s2'};
    end
    expfile=strrep(expfile,'%s1',s1);
    expfile=strrep(expfile,'%s2',s2);

    if ispc
        expfile=strrep(expfile,'\','/');
    end

    tcl=[...
'set log ""'...
    ,'lappend log "\n\n------------------------------------"'...
    ,'lappend log "   FPGA-in-the-Loop build summary"'...
    ,'lappend log "------------------------------------\n"'...
    ,expfile...
    ,'if [catch {file copy -force $expected_file ..}] {'...
    ,'   file delete ../$expected_file'...
    ,'   lappend log "Expected programming file not generated."'...
    ,'   lappend log "FPGA-in-the-Loop build failed.\n"'...
    ,'} else {'...
    ,'   if {[string length $timing_err] > 0} {'...
    ,'      lappend log "$timing_err\n"'...
    ,'      set warn_str " with warning"'...
    ,'   } else {'...
    ,'      set warn_str ""'...
    ,'   }'...
    ,'   lappend log "Programming file generated:"'...
    ,'   lappend log "$copied_file\n"'...
    ,'   lappend log "FPGA-in-the-Loop build completed$warn_str."'...
    ,'   lappend log "You may close this shell.\n"'...
    ,'}'...
    ,'foreach j $log {puts $j}'...
    ,'if { [catch {open fpgaproj.log w} log_fid] } {'...
    ,'} else {'...
    ,'    foreach j $log {puts $log_fid $j}'...
    ,'}'...
    ,'close $log_fid'];
    h.mProjMgr.runCustomTclCommand(sprintf('%s\n',tcl{:}));

end

function newstr=l_addPathQuote(str)

    newstr=str;
    if strfind(newstr,' ')
        if~strcmp(newstr(1),'"')
            newstr=['"',newstr];
        end
        if~strcmp(newstr(end),'"')
            newstr=[newstr,'"'];
        end
    end
end