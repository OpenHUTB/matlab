function newvalue=processNewValueForProperty(this,prop,newvalue)













    oldvalue=get(this,prop);





    classtype=class(this);
    [packagename,rem]=strtok(classtype,'.');
    classname=rem(2:length(rem));






    constructor_match=[classname];
    rtwconfig_match1='enablePropOnCondition';
    rtwconfig_match2='disablePropOnCondition';


    st=dbstack;

    locked=1;

    for i=1:length(st)
        if(~isempty(strfind(st(i).name,constructor_match))...
            |~isempty(strfind(st(i).name,rtwconfig_match1))...
            |~isempty(strfind(st(i).name,rtwconfig_match2)))

            locked=0;

            break;
        end;
    end;



    if(strcmp(oldvalue,RTWConfiguration.deactivatedString)==1)

        if(locked==1)
            newvalue=oldvalue;
        end;
    else

        if(strcmp(newvalue,RTWConfiguration.deactivatedString)==1)
            if(locked==1)
                newvalue=oldvalue;
            end;
        end;
    end;


    if(strcmp(newvalue,oldvalue)==0)
        this.updateDependencies(prop,newvalue);
    end;
