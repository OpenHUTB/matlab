function[fPath,dPath,label]=resolveEntry(entry)




    if ischar(entry)


        [fDir,nameAndScope,suffix]=fileparts(entry);
        label=suffix(2:end);
        [fName,rest]=strtok(nameAndScope,'|');
        if isempty(fDir)
            fPath=rmide.getFilePath(fName);
        else
            fPath=[fDir,filesep,fName];
        end
        dPath=rest(2:end);



        if strcmp(dPath,'Design')
            dPath='Global';
        end

    else


        label=entry.getDisplayLabel();
        dPath=entry.getParent.getNodeName();


        if strcmp(dPath,'Design')
            dPath='Global';
        end




        dName=entry.getPropValue('DataSource');
        fPath=rmide.resolveDict(dName);






        myConnection=rmide.connection(fPath);
        myConnection.getEntryKey([dPath,'.',label]);
    end
end

