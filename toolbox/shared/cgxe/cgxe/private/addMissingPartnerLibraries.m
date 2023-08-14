function allLibraries=addMissingPartnerLibraries(libraries)









    allLibraries=libraries;

    allLibraryNamesAndExts=...
    cellfun(@getNameAndExt,allLibraries,'UniformOutput',false);

    for libraryCell=libraries
        library=libraryCell{1};




        [otherLibrary,otherNecessary]=partnerLibrary(library);

        if~isempty(otherLibrary)&&...
            ~ismember(getNameAndExt(otherLibrary),allLibraryNamesAndExts)


            if isfile(otherLibrary)

                allLibraries{end+1}=otherLibrary;
            elseif otherNecessary

                [fPath,fName,fExt]=fileparts(otherLibrary);
                exception=MException(message(...
                'Simulink:cgxe:FileNotFound',[fName,fExt],fPath));

                libraryExceptionFormat=strrep(library,'\','\\');
                cause=MException(...
                'Simulink:cgxe:FileNotFoundCause',...
                ['Required by use of ',libraryExceptionFormat]);
                makeException=addCause(exception,cause);
                throw(makeException);
            end
        end
    end
end

function[partner,necessary]=partnerLibrary(library)













    importExt=getLibraryExtension('import');
    dynamicExt=getLibraryExtension('dynamic');
    staticExt=getLibraryExtension('static');

    partner=[];
    necessary=false;



    if~isequal(importExt,dynamicExt)

        [filePath,fileName,fileExt]=fileparts(library);


        if isequal(fileExt,importExt)

            partner=[filePath,filesep,fileName,dynamicExt];
            necessary=true;
        elseif isequal(fileExt,dynamicExt)

            partner=[filePath,filesep,fileName,importExt];
            necessary=true;
        end


        necessary=necessary&&~isequal(fileExt,staticExt);

    end
end

function nameAndExt=getNameAndExt(file)



    [~,name,ext]=fileparts(file);
    nameAndExt=[name,ext];
end