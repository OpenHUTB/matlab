function info=hdlcommentfixupcbsinfo(info,commentchars)

    cpos=strmatch([commentchars,' Cast Before Sum'],info);

    if~isempty(cpos)
        for n=1:length(cpos)
            idx=strfind(info{cpos(n)},'true');
            if isempty(idx)&&hdlgetparameter('cast_before_sum')==1
                info{cpos(n)}=[info{cpos(n)},' (Overridden to true by generatehdl)'];
            elseif~isempty(idx)&&hdlgetparameter('cast_before_sum')==0
                info{cpos(n)}=[info{cpos(n)},' (Overridden to false by generatehdl)'];
            end
        end
    end