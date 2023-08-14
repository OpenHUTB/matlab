function labelsAndIds=getLinkableEntries(dictPath)




    try

        myConnection=rmide.connection(dictPath);
        allSections=myConnection.getChildNames('');
        [~,dName]=fileparts(dictPath);
        labelsAndIds={dName,''};
        for i=1:length(allSections)
            section=allSections{i};
            labelsAndIds=[labelsAndIds;[section,{' '}]];%#ok<AGROW>
            myEntries=myConnection.getChildNames(section);
            myKeys=cell(size(myEntries));
            for j=1:length(myEntries)
                key=myConnection.getEntryKey([section,'.',myEntries{j}]);

                myKeys{j}=strrep(key.toString,'UUID ','UUID_');
            end
            labelsAndIds=[labelsAndIds;[myEntries,myKeys]];%#ok<AGROW>
        end
    catch ex
        if strcmp(ex.identifier,'SLDD:sldd:DictionaryNotFound')
            rmiut.warnNoBacktrace('Slvnv:rmide:DataDictNotFound',dictPath);
            labelsAndIds=cell(0,2);
        else
            rethrow(ex);
        end
    end
end
