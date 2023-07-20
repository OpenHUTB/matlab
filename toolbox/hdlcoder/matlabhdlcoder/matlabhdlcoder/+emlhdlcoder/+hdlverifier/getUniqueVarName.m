function uniquename=getUniqueVarName(Name,initialize)





    persistent existnames;

    if isempty(existnames)
        existnames={};
    end

    if nargin==1
        initialize=0;
    end

    if initialize
        existnames={};
        uniquename='';
    else
        uniquename=genvarname(Name,existnames);
        if iscell(Name)
            existnames=[existnames,uniquename];
        else
            existnames{end+1}=uniquename;
        end
    end



