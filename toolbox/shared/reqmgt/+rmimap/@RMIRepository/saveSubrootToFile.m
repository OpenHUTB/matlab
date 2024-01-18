function[success,cutObjs,cutReqs]=saveSubrootToFile(this,subrootName,saveAsName,reqFilePath)

    success=false;
    cutObjs={};
    cutReqs={};
    subRoot=rmimap.RMIRepository.getRoot(this.graph,subrootName);
    if isempty(subRoot)
        return;
    end

    t1=M3I.Transaction(this.graph);

    for i=1:subRoot.links.size
        if isempty(subRoot.links.at(i).getProperty('dependentUrl'))
            rmimap.RMIRepository.populateLinkData(subRoot.links.at(i));
        end
    end

    if rmisl.isHarnessIdString(subrootName)
        [parentName,harnessId]=strtok(subrootName,':');

        for i=1:subRoot.links.size
            stripHarnessIds(subRoot.links.at(i),harnessId);
        end
        harnesses=Simulink.harness.find(parentName);
        harnessesIDs={harnesses(:).uuid};
        harnessInfo=harnesses(strcmp(harnessesIDs,harnessId(2:end)));
        harnessOwner=harnessInfo.ownerFullPath;
        parentRoot=rmimap.RMIRepository.getRoot(this.graph,parentName);
        for i=1:parentRoot.nodes.size
            oneNode=parentRoot.nodes.at(i);
            if rmisl.isHarnessIdString(oneNode.id)
                continue;
            end
            objH=Simulink.ID.getHandle([parentName,oneNode.id]);

            if isa(objH,'Stateflow.Object')
                sfChart=obj_chart(objH.Id);
                sfBlock=sfprivate('chart2block',sfChart);
                objPath=sprintf('%s SID_%d',getfullname(sfBlock),objH.SSIdNumber);
            else
                objPath=getfullname(objH);
            end
            if strncmp(objPath,harnessOwner,length(harnessOwner))

                for j=1:oneNode.dependeeLinks.size
                    oneLink=oneNode.dependeeLinks.at(j);
                    cutReqs{end+1}=rmimap.RMIRepository.populateReqData(oneLink);%#ok<AGROW>
                    cutObjs{end+1}=replaceDiagramName(objPath,harnessOwner,saveAsName);%#ok<AGROW>
                end
            end
        end

    end

    if~strcmp(subRoot.url,saveAsName)
        subRoot.url=saveAsName;
    end

    t1.commit;

    try
        rmimap.RMIRepository.writeM3I(reqFilePath,subRoot);
        success=true;
    catch Mex
        warning(Mex.identifier,Mex.message);
        success=false;
    end

end


function stripHarnessIds(link,harnessId)
    dependentUrl=link.getProperty('dependentUrl');
    if contains(dependentUrl,harnessId)
        dependentUrl=strrep(dependentUrl,harnessId,'');
        link.setProperty('dependentUrl',dependentUrl);
    end
    dependeeUrl=link.getProperty('dependentUrl');
    if contains(dependeeUrl,harnessId)
        dependeeUrl=strrep(dependeeUrl,harnessId,'');
        link.setProperty('dependeeUrl',dependeeUrl);
    end
end


function updatedPath=replaceDiagramName(objPath,harnessOwner,saveAsName)
    if length(objPath)>length(harnessOwner)
        localPath=objPath(length(harnessOwner)+1:end);
    else
        localPath='';
    end
    sfMatch=regexp(localPath,'(.*) SID_([\d\:]+)','tokens');
    if isempty(sfMatch)
        ownerName=get_param(harnessOwner,'Name');
        updatedPath=[saveAsName,'/',ownerName,localPath];
    else

        parentChart=sfMatch{1}{1};
        updatedChart=replaceDiagramName(parentChart,harnessOwner,saveAsName);
        updatedPath=[Simulink.ID.getSID(updatedChart),':',sfMatch{1}{2}];
    end
end
