function[totalSubsystems,countNew]=surrogateUpdateScreenshots(modelName,keepTempFiles)

















    if nargin==1
        keepTempFiles=false;
    end


    mdlReqs=rmi.getReqs(modelName);
    if isempty(mdlReqs)
        error(message('Slvnv:reqmgt:doorssync:ModelNotSynchronized',modelName));
    end
    surrLinks=mdlReqs(strcmp({mdlReqs.reqsys},'doors'));
    if isempty(surrLinks)
        error(message('Slvnv:reqmgt:doorssync:ModelNotSynchronized',modelName));
    end

    moduleId=surrLinks(1).doc;


    rptFile=rmisl.takeSnapshots();
    screenshots=rmisl.mapSnapshots(rptFile);


    rmidoors.show(moduleId,-1,true);

    origDescription=mascaradeDescription(moduleId);




    allSubsystems=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
    if~any(strcmp(allSubsystems,modelName));
        allSubsystems=[{modelName};allSubsystems];
    end
    totalSubsystems=length(allSubsystems);


    existingScreenshots=rmidoors.getModuleAttribute(moduleId,'SlRefObjects');
    if isempty(existingScreenshots)
        existingIDs={};
        existingLabels={};
    else
        existingIDs=existingScreenshots(:,1);
        existingLabels=existingScreenshots(:,4);
    end


    countNew=0;
    for i=1:totalSubsystems
        subsystem=allSubsystems{i};
        if isKey(screenshots,subsystem)
            disp(getString(message('Slvnv:reqmgt:doorssync:UsingFor',screenshots(subsystem),subsystem)));
            pictureFile=fullfile(pwd,screenshots(subsystem));
            countNew=countNew+...
            updateScreenshot(subsystem,pictureFile,moduleId,existingLabels,existingIDs);
        else
            disp(getString(message('Slvnv:reqmgt:doorssync:MissingScreenshot',strrep(subsystem,char(10),' '))));
        end
    end


    restoreDescription(moduleId,origDescription);


    disp(getString(message('Slvnv:reqmgt:doorssync:Processed0numberintegerSubsystems1numberinteger',totalSubsystems,countNew,moduleId)));


    if~keepTempFiles
        [myDir,myName]=fileparts(rptFile);
        tmpImages=[fullfile(myDir,myName),'_html_files'];
        rmdir(tmpImages,'s');
        delete(rptFile);
    end
end

function origDescr=mascaradeDescription(moduleId)
    origDescr=rmidoors.getModuleAttribute(moduleId,'DMI description');
    rmidoors.setModuleAttribute(moduleId,'DMI description',['Mascaraded ',origDescr]);
end

function restoreDescription(moduleId,origDescr)
    rmidoors.setModuleAttribute(moduleId,'DMI description',origDescr);
end

function isNew=updateScreenshot(subsystem,pictureFile,moduleId,labels,IDs)
    isNew=false;
    subsysReqs=rmi.getReqs(subsystem);
    surrLinks=subsysReqs(strcmp({subsysReqs.reqsys},'doors'));
    surrObject=surrLinks(1).id;
    if isempty(surrLinks)
        return
    end
    match=strcmp(labels,strrep(subsystem,char(10),' '));
    if any(match)
        id=IDs(match);
        rmidoors.setObjAttribute(moduleId,id{1},'picture',pictureFile);
    else
        isNew=true;
        label=makeLabel(subsystem);
        navcmd=rmi.objinfo(subsystem);
        navcmd=strrep(navcmd,','''')',','':'')');
        rmidoors.addLinkObj(moduleId,surrObject,pictureFile,label,navcmd);
    end
end

function label=makeLabel(subsystem)
    label=['[Simulink reference: ',strrep(subsystem,char(10),' '),']'];
end


