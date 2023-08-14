classdef Manager

    methods(Static)
        function listOfTemplates=getListOfTemplates()
            listOfTemplates={};

            registeredBultins=which('slreqBuiltinProfiles');
            currentFolder=pwd;
            restorePath=onCleanup(@()cd(currentFolder));

            if~iscell(registeredBultins)
                registeredBultins={registeredBultins};
            end

            for i=1:numel(registeredBultins)

                [builtinsFolder,~,~]=fileparts(registeredBultins{i});
                cd(builtinsFolder)
                builtinsInfo=slreqBuiltinProfiles;
                try
                    for bInfo=builtinsInfo(:)'
                        fileInfo=dir(bInfo.Name);

                        if license('test',bInfo.LicenseToCheck)
                            if slreq.templates.Manager.isProfile(fileInfo)
                                templateInfo.file=fileInfo;
                                templateInfo.description=bInfo.Description;
                                listOfTemplates{end+1}=templateInfo;%#ok<AGROW>
                            end
                        end
                    end
                catch

                end

            end
        end
        function bool=isProfile(fileInfo)
            [~,~,type]=fileparts(string(fileInfo.name));
            if lower(type)~=".xml"
                bool=false;
                return;
            end
            bool=true;
        end
    end
end


