function enablePropOnCondition(this,prop,newvalue,enableset)




    for i=1:length(enableset)
        switch class(enableset{i})
        case 'function_handle'
            if(feval(enableset{i},newvalue)==1)
                i_activate(this,prop);

                return;
            end;
        case 'char'
            if(strcmp(enableset{i},newvalue)==1)
                i_activate(this,prop);

                return;
            end;
        end;
    end;
    return;

    function i_activate(this,prop)





        foundsep=0;
        for i=length(prop):-1:1
            if(prop(i)=='.')
                foundsep=1;
                break;
            end;
        end;




        try
            if(foundsep==1)

                part1=prop(1:i-1);
                part2=prop(i+1:length(prop));
                thisProp=findprop(eval(['this.',part1]),part2);
            else
                thisProp=findprop(this,prop);
            end;

            actValue=thisProp.ActivateValue;

            eval(['this.',prop,' = ''',actValue,''';']);
        catch

        end;
