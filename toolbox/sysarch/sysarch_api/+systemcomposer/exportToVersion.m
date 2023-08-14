function exportToVersion(mdlName,dirName,version)










    [~,name,ext]=fileparts(mdlName);
    if isempty(ext)
        ext='.slx';
    end
    mdlName=[name,ext];


    if(exist(dirName,'dir')~=7)
        mkdir(dirName);
    end

    if~isDirEmpty(dirName)
        error('Target directory must be empty');
    end



    dependencies=systemcomposer.internal.DependencyAnalyzer.getDependencies(mdlName);


    for name=dependencies.models
        if contains(name{1},'.slxp')

            warning('SystemArchitecture:Architecture:ArchitectureSLXPNotExportedToPreviousVersion',...
            DAStudio.message('SystemArchitecture:Architecture:ArchitectureSLXPNotExportedToPreviousVersion',name{1}));
            continue;
        end
        h=load_system(name{1});
        zcModel=get_param(h,'SystemComposerModel');
        if~isempty(zcModel)
            zcModel.exportToVersion(fullfile(dirName,[name{1},'.slx']),version);
        end
    end


    for name=dependencies.profiles
        pfl=systemcomposer.loadProfile(name{1});
        if~isempty(pfl)
            pfl.exportToVersion(fullfile(dirName,[name{1},'.xml']),version);
        end
    end


    dictionariesToExport=[];
    for name=dependencies.interfaceDictionaries
        dd=Simulink.data.dictionary.open([name{1},'.sldd']);
        if~isempty(dd)



            if(~isempty(dd.DataSources)&&~isVersionGreaterOrEqualTo(version,'R2020b'))
                DAStudio.error('SystemArchitecture:Interfaces:SLDDExportWithClosureToPre20a');
            end



            if~isDictionaryADataSource(dictionariesToExport,dd)


                idxToRemove=[];
                for i=1:numel(dictionariesToExport)
                    [~,filename,ext]=fileparts(dictionariesToExport(i).filepath);
                    ddNameToCheck=[filename,ext];
                    if any(ismember(dd.DataSources,ddNameToCheck))
                        idxToRemove=[idxToRemove,i];%#ok<AGROW>
                    end
                end
                dictionariesToExport(idxToRemove)=[];%#ok<AGROW>
                dictionariesToExport=[dictionariesToExport,dd];%#ok<AGROW>
            end
        end
    end


    for i=1:numel(dictionariesToExport)
        dictionariesToExport(i).exportToVersion(dirName,version);
    end


end

function tf=isDirEmpty(dirName)

    c=dir(dirName);
    tf=true;
    for i=1:numel(c)
        if~c(i).isdir
            tf=false;
        end
    end

end

function tf=isVersionGreaterOrEqualTo(actVersion,versionToCmp)
    tf=saveas_version(actVersion)>=saveas_version(versionToCmp);
end

function tf=isDictionaryADataSource(ddList,ddToCheck)
    tf=false;
    [~,name,ext]=fileparts(ddToCheck.filepath);
    ddNameToCheck=[name,ext];
    for i=1:numel(ddList)
        if any(ismember(ddList(i).DataSources,ddNameToCheck))
            tf=true;
            return;
        end
    end
end