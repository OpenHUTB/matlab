function runGuidedRetiming(this,p,criticalPathSet,latencyConstraint,guidanceFileName,append,isRegenMode)




    if(isRegenMode)
        sanityCheckForRegen(guidanceFileName,p.ModelName);
        temp=load(guidanceFileName);
        newGuidance=temp.guidance;
        cpManager=guidancesetToCPManager(p,newGuidance.guidanceSet);
        hdlcoder.TransformDriver.guidedRetiming(p,cpManager);
        if(~isempty(criticalPathSet))
            tempData.guidance=newGuidance;
            diagnosticData=qoroptimizations.backAnnotateToSimulink(criticalPathSet,p);
            tempData.diagnostics=diagnosticData;
            qoroptimizations.saveFile(guidanceFileName,tempData,this.ModelName);
        end
    else

        if(append&&exist(guidanceFileName,'file')==2)

            temp=load(guidanceFileName);
            cpManager=guidancesetToCPManager(p,temp.guidance.guidanceSet);
            hdlcoder.TransformDriver.guidedRetiming(p,cpManager);

            newGuidance=qoroptimizations.createGuidance(p,criticalPathSet,latencyConstraint,temp.guidance.guidanceSet);
            guidance=newGuidance;
            guidance.guidanceSet=insertGuidanceSet(temp.guidance.guidanceSet,guidance.guidanceSet);
            s=copyfile(guidanceFileName,[guidanceFileName(1:end-4),'_last.mat'],'f');%#ok<NASGU>
        else
            newGuidance=qoroptimizations.createGuidance(p,criticalPathSet,latencyConstraint,[]);
            guidance=newGuidance;
        end
        tempData.guidance=guidance;
        diagnosticData=qoroptimizations.backAnnotateToSimulink(criticalPathSet,p);
        tempData.diagnostics=diagnosticData;
        qoroptimizations.saveFile(guidanceFileName,tempData,this.ModelName);
    end
end

function cpManager=guidancesetToCPManager(p,guidanceSet)

    cpManager=hdlcoder.criticalpathmanager.create;
    cp=cpManager.newCriticalPath();
    for i=1:length(guidanceSet)
        cpNode=guidanceSet(i);
        try
            nw=p.findNetwork('refnum',cpNode.nwRef);
            sig=nw.findSignal('refnum',cpNode.sigRef);
        catch me
            rethrow(me);
        end
        if(isempty(sig))

            warning(message('hdlcoder:optimization:SignalNotFound',cpNode.nwRef,cpNode.sigRef));
        end
        cp.addNode(cpNode.nwRef,cpNode.sigRef,0);
    end
    cpManager.markOnPir(p);
end

function u=unionGuidanceSet(s1,s2)
    mapObj=containers.Map('KeyType','char','ValueType','any');
    for i=1:length(s1)
        mapObj([s1(i).nwRef,'_',s1(i).sigRef])=s1(i);
    end
    for i=1:length(s2)
        mapObj([s2(i).nwRef,'_',s2(i).sigRef])=s2(i);
    end
    u=mapObj.values;
    u=[u{:}];
end

function updatedSet=insertGuidanceSet(existingSet,newSet)
    updatedSet=existingSet;
    mapObj=containers.Map('KeyType','char','ValueType','any');
    for i=1:length(existingSet)
        mapObj([existingSet(i).nwRef,'_',existingSet(i).sigRef])=existingSet(i);
    end
    for i=1:length(newSet)
        tf=isKey(mapObj,[newSet(i).nwRef,'_',newSet(i).sigRef]);
        if(~tf)
            updatedSet(end+1)=newSet(i);
        end
    end
end

function sanityCheckForRegen(bestGuidanceFilePath,topModelName)
    if(exist(bestGuidanceFilePath,'file')~=2)
        error(message('hdlcoder:optimization:GuidanceMissing',strrep(bestGuidanceFilePath,'\','\\')));
    end

    qoroptimizations.loadFile(bestGuidanceFilePath,topModelName);
end


