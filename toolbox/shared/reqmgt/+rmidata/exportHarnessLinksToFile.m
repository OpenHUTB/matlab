function success=exportHarnessLinksToFile(mainModel,harnessID,destinationBaseName)











    persistent outName cutObjs cutReqs

    if nargin==1


        success=strcmp(outName,mainModel);
        if success&&~isempty(cutObjs)
            try
                load_system(outName);
                for i=1:length(cutObjs)
                    if strcmp(cutReqs{i}.id,':')

                        try
                            chopAt=strfind(cutReqs{i}.description,'  (');
                            if~isempty(chopAt)
                                objPath=cutReqs{i}.description(1:chopAt-1);
                                sid=Simulink.ID.getSID(objPath);
                                [~,cutReqs{i}.id]=strtok(sid,':');
                            else
                                cutReqs{i}.id=':1';
                            end
                        catch ex %#ok<NASGU>
                            cutReqs{i}.id=':1';
                        end
                    end
                    rmi.catReqs(cutObjs{i},cutReqs{i});
                end
                rmidata.save(outName);
            catch ex %#ok<NASGU>
                success=false;
            end
        end


        outName='';
        cutObjs={};
        cutReqs={};

    else

        success=false;
        try
            if ischar(mainModel)
                mainModelH=get_param(mainModel,'Handle');
            else
                mainModelH=mainModel;
                mainModel=get_param(mainModelH,'Name');
            end
            if~rmidata.isExternal(mainModelH)

                return;
            end
            [~,outName]=fileparts(destinationBaseName);
            artifactName=[destinationBaseName,'.slx'];
            if rmipref('StoreDataExternally')
                reqFilePath=rmimap.StorageMapper.getInstance.getStorageFor(artifactName);
            else
                reqFilePath='';
            end

            [success,cutObjs,cutReqs]=slreq.utils.exportMatchedItems(mainModel,harnessID,artifactName,reqFilePath);
            if success
                if~isempty(reqFilePath)
                    disp(getString(message('Slvnv:rmidata:export:LinksFileForExternalHarness',reqFilePath)));
                end
            else
                outName='';
            end

        catch Mex
            warning(Mex.identifier,'%s',Mex.message);
            outName='';
        end
    end
end

