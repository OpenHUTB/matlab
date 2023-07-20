function invalidentries=validateChildren(this)






    invalidentries=[];
    entries=this.children;

    reservedSymbols=this.object.getReservedIdentifiers;
    stringResolutionMap=this.object.StringResolutionMap;

    this.object=[];
    this.object=RTW.TflTable;

    [~,tableName,~]=fileparts(this.Name);
    this.object.Name=tableName;

    this.object.setReservedIdentifiers(reservedSymbols);
    this.object.StringResolutionMap=stringResolutionMap;

    for i=1:length(entries)

        currEnt=entries(i).object;
        try
            entries(i).isValid=currEnt.isValid;
            this.object.addEntry(currEnt);
            entries(i).errLog='';
        catch ME
            entries(i).isValid=false;
            entries(i).errLog=ME.message;
            entries(i).firepropertychanged;
            if isempty(invalidentries)
                invalidentries=entries(i);
            else
                invalidentries(end+1)=entries(i);%#ok
            end
        end

    end


