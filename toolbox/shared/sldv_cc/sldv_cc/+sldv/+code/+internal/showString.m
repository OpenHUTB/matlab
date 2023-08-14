



function showString(testComp,criticity,str)

    isError=strcmpi(criticity,'error');

    if~isempty(testComp)&&isa(testComp,'SlAvt.TestComponent')&&~isempty(testComp.progressUI)


        try
            if isError
                line=sprintf('<font color=red>%s</font><br>\n',str);
            elseif strcmp(criticity,'subinfo')
                line=sprintf('&nbsp;&nbsp;&nbsp;%s\n',str);
            else
                line=sprintf('%s\n',str);
            end
            testComp.progressUI.appendToLog(line);
        catch
        end
    else
        if isError
            prefix='*** ';
        elseif strcmp(criticity,'subinfo')
            prefix='    ';
        else
            prefix='';
        end
        fprintf(1,'%s%s\n',prefix,str);
    end


