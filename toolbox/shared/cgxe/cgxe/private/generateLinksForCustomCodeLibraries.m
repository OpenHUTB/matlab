function generateLinksForCustomCodeLibraries(ccDir,runtimeLibraries)




    linkFolder=ccDir;
    if ismac
        linkFolder=[getenv('HOME'),filesep,'lib'];
    end


    if~isfolder(linkFolder)
        mkdir(linkFolder);
    end


    linkCommands=genLinkCommands(linkFolder,runtimeLibraries);






    for linkCommand=linkCommands

        if~isfile(linkCommand{3})





            cause={'Simulink:cgxe:SymbolicLinkErrorCause'};
            if ispc
                cause={'Simulink:cgxe:HardLinkErrorWindowsCause'};
            end
            safeRunCommandWithErrorArgs(...
            linkCommand{1},...
            {'Simulink:cgxe:SymbolicLinkError',linkCommand{2},linkFolder},...
            cause);
        end
    end
end


function commands=genLinkCommands(linkFolder,files)






    commands=cell(3,length(files));
    for i=1:length(files)
        file=files{i};
        [~,fName,ext]=fileparts(file);
        link=[linkFolder,filesep,fName,ext];
        commands{1,i}=linkCommand(link,file);
        commands{2,i}=file;
        commands{3,i}=link;
    end
end

function command=linkCommand(link,file)



    command='';
    if ispc



        command=...
        ['mklink /H '...
        ,'"',link,'" '...
        ,'"',file,'"'];
    elseif isunix

        command=...
        ['ln -s -f '...
        ,'"',file,'" '...
        ,'"',link,'"'];
    end
end