function msg=performXformation(m2mObj)




    failedCmds=[];
    if m2mObj.fInModelXform
        m2mObj.fPrefix='';
    end
    for idx=1:length(m2mObj.fXformCommands)
        cmd=strrep(m2mObj.fXformCommands{idx},newline,' ');

        if strfind(cmd,'m2mObj.setParam')==1
            posComma=strfind(cmd,',');
            val=cmd(posComma(2)+1:end);
            posQuote=strfind(val,'''');
            if length(posQuote)>2
                val_=val(1:posQuote(2));
                for qIdx=2:length(posQuote)-1
                    val_=[val_,'''',val(posQuote(qIdx)+1:posQuote(qIdx+1))];
                end
                val_=[val_,val(posQuote(end)+1:end)];
                cmd=[cmd(1:posComma(2)),val_];
            end
        end
        try
            eval(cmd);
        catch exception
            failedCmds=[failedCmds,{cmd}];%#ok
            exptnText=getReport(exception);
            disp(exptnText);
        end
    end

    msg=failedCmds;

end
