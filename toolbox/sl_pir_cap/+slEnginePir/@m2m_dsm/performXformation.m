function errMsg=performXformation(this)



    errMsg=[];

    failed_cmd=[];
    for i=1:length(this.fXformCmd)
        cmd=strrep(this.fXformCmd{i},char(10),' ');
        try
            eval(cmd);
        catch
            failed_cmd=[failed_cmd,{cmd}];
        end
    end

end
