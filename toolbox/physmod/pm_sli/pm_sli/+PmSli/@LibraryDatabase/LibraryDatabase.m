classdef LibraryDatabase





    properties(Constant,Access=private)
        Entries=lInitializeDatabase()
        Array=struct2array(PmSli.LibraryDatabase.Entries);
        Directories=lDirectories(PmSli.LibraryDatabase.Array);
    end

    methods
        function obj=LibraryDatabase()
        end
    end
end

function allEntries=lInitializeDatabase()


    PM_LIBDEF='pm_libdef';
    libDefs=which(PM_LIBDEF,'-all');




    libDefDirs=cell(size(libDefs));
    for i=1:length(libDefs)
        libDefDirs{i}=fileparts(libDefs{i});
    end





    libDefDirs=unique(libDefDirs);




    allEntries=struct();




    for i=1:length(libDefDirs)
        fcn=pm_pathtofunctionhandle(libDefDirs{i},PM_LIBDEF);
        fcnInfo=functions(fcn);
        try
            entries=fcn();
        catch exception




            pm_warning('physmod:pm_sli:PmSli:LibraryDatabase:ErrorRegisteringEntry',...
            fcnInfo.file,exception.message);




            continue;
        end

        for idx=1:numel(entries)
            entry=entries(idx);
            expType='PmSli.LibraryEntry';
            if~isa(entry,expType)




                pm_warning('physmod:pm_sli:PmSli:LibraryDatabase:InvalidLibraryEntry',...
                fcnInfo.file,expType);
            elseif isfield(allEntries,entry.Name)



                pm_warning('physmod:pm_sli:PmSli:LibraryDatabase:DuplicateLibraryEntry',...
                fcnInfo.file,...
                allEntries.(entry.Name).RegistrationFile,...
                entry.Name);
            end





            entry.RegistrationFile=fcnInfo.file;
            allEntries.(entry.Name)=entry;
        end
    end
end

function out=lDirectories(entries)
    if isempty(entries)
        out={};
    else
        out=fileparts(get(entries,'RegistrationFile'));
        if~iscell(out)
            out={out};
        end
    end

end

