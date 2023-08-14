function msg=getDiagnosticMessage(me)
    msg=me.message;

    if~isempty(me.stack)&&~verLessThan('matlab','9.6')



        if endsWith(me.stack(1).file,fullfile('+Stateflow','+Debug','+Runtime','show_runtime_error_in_diagnostic_viewer.m'))
            msg=strrep(msg,'&','&amp;');
            msg=regexprep(msg,'<(?!a href=".*?">|strong>|/a>|/strong>)','&lt;');
            msg=regexprep(msg,'(?<!<a href=".*?"|<strong|</a|</strong)>','&gt;');
        end
    end
end