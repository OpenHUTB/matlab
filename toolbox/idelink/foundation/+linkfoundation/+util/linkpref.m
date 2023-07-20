function prefVal=linkpref(action,groupName,prefName,value)




    prefVal=[];

    switch(action)
    case 'setpref',
        narginchk(4,4);
        if~ispref(groupName)
            addpref(groupName,prefName,value);
        else
            if~ispref(groupName,prefName)
                addpref(groupName,prefName,value);
            else
                setpref(groupName,prefName,value);
            end
        end
    case 'getpref',
        narginchk(3,3);
        if~ispref(groupName)
            prefVal=[];
        else
            if~ispref(groupName,prefName)
                prefVal=[];
            else
                prefVal=getpref(groupName,prefName);
            end
        end
    case 'rmpref',
        narginchk(3,3);
        if ispref(groupName)
            rmpref(groupName,prefName);
        end
    case 'rmgroup',
        narginchk(2,2);
        if ispref(groupName)
            rmpref(groupName);
        end
    otherwise,
        DAStudio.error('ERRORHANDLER:utils:InvalidInputToFunction',action,upper(mfilename));
    end


