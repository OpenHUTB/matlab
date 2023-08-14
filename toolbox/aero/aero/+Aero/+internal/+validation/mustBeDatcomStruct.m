function mustBeDatcomStruct(datcomStruct)





    if isstruct(datcomStruct)
        names=string(fieldnames(datcomStruct));

        required=["dim","deriv","grndht","delta","build","sref","blref","cbar",...
        "alpha","mach","alt","nalt","nmach"];

        stables=lower(["CD","CYb","CL","CLa","Clb","Cm","Cnb","Xcp"]);

        idxRequired=~ismember(required,names);
        idxStables=~ismember(stables,lower(names));

        if any(idxRequired)
            error(message('aero:validators:mustBeDatcomStructMissingParam',sprintf("\n\t'%s'",required(idxRequired))));
        end

        if any(idxStables)
            error(message('aero:validators:mustBeDatcomStructMissingTable',sprintf("\n\t'%s'",stables(idxStables))));
        end

        if(any(contains(names,"version"))&&(datcomStruct.version~=1976))
            error(message('aero:validators:mustBeDatcomStructUnsupportedVersion'));
        end
    else
        error(message('aero:validators:mustBeDatcomStructInvalidDATCOMStruct'));
    end
