function manuallyStitchExpandedContainerSignals(this,signalIDs,runID,dimsMap,varargin)








    import Simulink.sdi.internal.Util;




    hierarchyPathToSignalIDMap=Simulink.sdi.Map('char',int32(0));

    for iSignalID=1:length(signalIDs)


        hierarchyNodes=Util.createDataHierarchyGroupArray(signalIDs(iSignalID),this);
        len=length(hierarchyNodes);
        [separator,fullPath]=createNodePathString(hierarchyNodes);
        currentNodePath=fullPath;
        previousSignalID=[];
        for iNode=len:-1:1
            if~hierarchyPathToSignalIDMap.isKey(currentNodePath)


                if iNode==len
                    currentSignalID=signalIDs(iSignalID);
                else
                    currentSignalID=this.sigRepository.createSignal();
                    this.sigRepository.setSignalLabel(currentSignalID,hierarchyNodes{iNode});

                    if dimsMap.isKey(currentNodePath)
                        this.sigRepository.setSignalSampleDims(currentSignalID,...
                        dimsMap.getDataByKey(currentNodePath));
                    end
                end
                hierarchyPathToSignalIDMap.insert(currentNodePath,currentSignalID);
                this.sigRepository.addSignal(runID,currentSignalID);
            else
                if iNode==len


                    currentSignalID=signalIDs(iSignalID);
                else


                    currentSignalID=hierarchyPathToSignalIDMap.getDataByKey(currentNodePath);
                end
            end

            if~isempty(previousSignalID)
                this.sigRepository.setParent(previousSignalID,currentSignalID);
            end
            previousSignalID=currentSignalID;


            indices=find(currentNodePath==separator,1,'last');
            if~isempty(indices)
                currentNodePath=currentNodePath(1:indices(1)-1);
            end
        end
    end



    topLevelSignals=this.sigRepository.getAllSignalIDs(runID,'top');
    topModelName='';
    if nargin>5
        topModelName=varargin{1};
    end
    for iTopSignal=1:length(topLevelSignals)
        updateParentUsingChildren(topLevelSignals(iTopSignal),topModelName,this.sigRepository);
    end

end

function[separator,path]=createNodePathString(hierarchyNodes)

    separator='#';
    path=[];
    for iNode=1:length(hierarchyNodes)
        if iNode<length(hierarchyNodes)
            path=horzcat(path,hierarchyNodes{iNode},separator);%#ok<AGROW>
        else
            path=horzcat(path,hierarchyNodes{iNode});%#ok<AGROW>
        end
    end

end

function updateParentUsingChildren(rootSignalID,topModelName,sigRepository)

    children=sigRepository.getSignalChildren(rootSignalID);
    if~isempty(children)
        for iChildSignal=1:length(children)
            updateParentUsingChildren(children(iChildSignal),topModelName,sigRepository);
        end


        Simulink.sdi.SignalClient.setSignalSourceUsingCommonChildProperties(...
        int64(rootSignalID),topModelName,sigRepository);
    end

end
