function disablePropOnCondition(this,prop,newvalue,disableset)






    disableset{length(disableset)+1}=RTWConfiguration.deactivatedString;

    for i=1:length(disableset)
        switch class(disableset{i})
        case 'function_handle'
            if(feval(disableset{i},newvalue)==1)
                i_deactivate(this,prop);

                return;
            end;
        case 'char'
            if(strcmp(disableset{i},newvalue)==1)
                i_deactivate(this,prop);

                return;
            end;
        end;
    end;
    return;

    function i_deactivate(this,prop)





        try
            eval(['this.',prop,' = ''',RTWConfiguration.deactivatedString,''';']);
        catch

        end;
