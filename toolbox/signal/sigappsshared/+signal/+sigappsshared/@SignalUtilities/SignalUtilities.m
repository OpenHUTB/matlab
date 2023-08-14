classdef SignalUtilities<handle





    methods(Static,Hidden)


        function removeDomainSignals(engine,id)


            engine.sigRepository.removeSaDomainSignals(id);
        end


        function removeResampledSignal(engine,id)


            engine.sigRepository.removeSaResampledSignal(id);
        end


        function removeAllAuxilarySignals(engine,id)


            engine.sigRepository.removeSaSignals(id);
        end


        function resetAllAuxilarySignalIds(engine,id)



            engine.sigRepository.resetSaSignals(id);
        end


        function y=createPreprocessBackupSignal(engine,id)



            y=engine.sigRepository.createPreprocessBackupSignal(id);
        end


        function updateSASignalIDOnLoad(eng,signalIDs)


            for idx=1:length(signalIDs)
                signalID=signalIDs(idx);
                if~any(strcmp(eng.getSignalTmMode(signalID),{'none','resampled','domainSignal','preprocessBackup'}))

                    eng.sigRepository.resetSaSignals(signalID);
                end

                currMode=eng.getSignalTmMode(signalID);
                if strcmp(currMode,'inherentLabeledSignalSet')
                    currMode=signal.sigappsshared.SignalUtilities.getTmModeLabeledSignalSet(eng,signalID);
                end
                if any(strcmp(currMode,{'tv','inherentTimetable','inherentTimeseries'}))&&...
                    isempty(eng.getSignalChildren(signalID))


                    tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();

                    tmd.updateResampledSignal(signalID,[]);
                end

                eng.setMetaDataV2(signalID,'ActionNameThatCreatedSignal','');
            end
        end


        function updateSASignalHierarchyOnLoad(eng,signalIDs)


            if nargin<1
                eng=Simulink.sdi.Instance.engine;
            end
            if nargin<2
                runIDs=eng.getAllRunIDs('siganalyzer');
                signalIDs=[];
                for idx=1:length(runIDs)
                    signalIDs=[signalIDs;eng.getAllSignalIDs(runIDs(idx))];
                end
            end
            correctedSignalIDs=signalIDs;
            for idx=1:length(signalIDs)
                signalID=signalIDs(idx);
                if~ismember(signalID,correctedSignalIDs)

                    continue;
                end


                if~eng.isEmptySignal(signalID)
                    data=eng.getSignalDataValues(signalID);
                    eng.setSignalTmNumPoints(signalID,numel(data.Data));
                    eng.setSignalTmTimeRange(signalID,[data.Time(1);data.Time(end)])
                end

                tmMode=eng.getSignalTmMode(signalID);
                childIDs=eng.getSignalChildren(signalID);
                if strcmp(tmMode,'inherentTimetable')&&~isempty(childIDs)





                    subParentNames=arrayfun(@(x)eng.getSignalName(x),childIDs,'UniformOutput',false);
                    superParentName=eng.getSignalName(signalID);
                    if all(strcmp(subParentNames,superParentName))
                        deletedIDs=childIDs;
                        for cidx=1:length(deletedIDs)


                            grandChildIDs=eng.getSignalChildren(childIDs(cidx));
                            for gcidx=1:length(grandChildIDs)
                                eng.sigRepository.setParent(grandChildIDs(gcidx),signalID);
                            end


                            Simulink.sdi.deleteSignal(deletedIDs(cidx));
                            didx=ismember(correctedSignalIDs,deletedIDs(cidx));
                            correctedSignalIDs(didx)=[];
                        end

                    end
                end
            end
        end


        function updateSALSSRepoAndSignalHierarchyOnLoad(eng,sigIDs,filename,extension)

            signal.sigappsshared.SignalUtilities.updateSASignalIDOnLoad(eng,sigIDs);
            if~isempty(extension)&&strcmp(extension,'.mat')
                m=matfile(filename,'Writable',true);

                if isprop(m,'MLSS')
                    signal.sigappsshared.SignalUtilities.loadLSSRepositoryFromMatFileObject(m);
                end



                if isprop(m,'SDRDescriptor')


                    sdr=m.SDRDescriptor;
                    fullVersion=sdr.Version;
                    strIdx=strfind(fullVersion,'.');
                    versionNumber=str2double(fullVersion(1:strIdx(2)-1));
                    if versionNumber<9.6
                        signal.sigappsshared.SignalUtilities.updateSASignalHierarchyOnLoad(eng,sigIDs);
                    end
                end
            end
        end


        function loadLSSRepositoryFromMatFileObject(m)




            mlss_filename=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();
            if exist(mlss_filename,'file')==2


                delete(mlss_filename)
            end

            mlss_file=matfile(mlss_filename,'Writable',true);
            MLSS=m.MLSS;
            lssKeys=fields(m.MLSS);
            for midx=1:length(lssKeys)
                mlss_file.(lssKeys{midx})=MLSS.(lssKeys{midx});
            end

        end




        function childrenIDs=recurseGetAllChildren(eng,signalID)




















            childrenIDs=[];
            childVect=helperGetAllChildren(eng,signalID);
            if~isempty(childVect)
                for idx=1:numel(childVect)
                    childVectIDs=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(eng,childVect(idx));
                    childrenIDs=[childrenIDs;childVect(idx);childVectIDs(:)];
                end
            end
        end

        function parentIDs=recurseGetAllParents(eng,signalID)



            ID=signalID;
            parentIDs=[];
            while(ID~=0)
                ID=eng.getSignalParent(ID);
                if(ID~=0)
                    parentIDs=[parentIDs;ID];
                end
            end
            if~isempty(parentIDs)&&eng.getSignalTmMode(parentIDs(1))=="inherentLabeledSignalSet"
                parentIDs(end)=[];
            end
        end

        function childrenIDs=recurseGetAllLeafChildren(eng,signalID)


            childrenIDs=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(eng,signalID);

            removeIDx=false(size(childrenIDs));
            for idx=1:numel(childrenIDs)
                testChildren=eng.getSignalChildren(childrenIDs(idx));
                if~isempty(testChildren)
                    removeIDx(idx)=true;
                end

            end

            childrenIDs(removeIDx)=[];

        end

        function parent=getSignalSuperparent(eng,signalID)

            isDone=false;
            while(~isDone)
                ID=eng.getSignalParent(signalID);
                if(ID==0)
                    parent=signalID;
                    isDone=true;
                else
                    signalID=ID;
                end
            end
        end

        function isPresent=checkSignalNameExsistsInSigApp(eng,newSignalName)
            isPresent=false;
            runId=eng.getAllRunIDs('siganalyzer');
            if isempty(runId)
                return;
            end

            runId=runId(1);
            sigIDs=eng.getAllSignalIDs(runId);
            for idx=1:length(sigIDs)
                sigID=sigIDs(idx);
                superparentSigID=signal.sigappsshared.SignalUtilities.getSignalSuperparent(eng,sigID);
                superparentSigName=eng.getSignalLabel(superparentSigID);




                if~eng.isEmptySignal(sigID)&&strcmp(superparentSigName,newSignalName)
                    isPresent=true;
                    return;
                end
            end
        end

        function sigIDs=getAllRelatedSignals(eng,signalID,leafFlag)



            if nargin<3
                leafFlag=false;
            end

            parentID=signal.sigappsshared.SignalUtilities.getSignalSuperparent(eng,signalID);
            sigIDs=[parentID;signal.sigappsshared.SignalUtilities.recurseGetAllChildren(eng,parentID)];


            if(leafFlag)
                removeIdx=[];
                for idx=1:numel(sigIDs)
                    sigChildren=eng.getSignalChildren(sigIDs(idx));
                    if~isempty(sigChildren)
                        removeIdx=[removeIdx;idx];
                    end
                end
                sigIDs(removeIdx)=[];
            end
        end

        function[sigIDs,viewIndicesFromServer]=getSelectedSignalIDs(eng,clientID,selectedViewIndices)











            if nargin<3
                [sigIDs,viewIndicesFromServer]=Simulink.sdi.getSelectedSignalIDsAndViewIndices(eng.sigRepository,clientID);
            else
                isDone=false;
                cnt=0;
                while~isDone
                    drawnow;
                    [sigIDs,viewIndicesFromServer]=Simulink.sdi.getSelectedSignalIDsAndViewIndices(eng.sigRepository,clientID);
                    isDone=cnt>1500||(numel(viewIndicesFromServer)==numel(selectedViewIndices)&&all(viewIndicesFromServer(:)==selectedViewIndices(:)));
                    cnt=cnt+1;
                end
            end
        end

        function[mapOfIDs,leafSignalIDsVect]=getUniqueSetOfSelectedSignalIDsByViewIndex(eng,selectedViewIndices,clientID)











            parsedIDs=[];
            parsedViewIndices=[];
            leafSignalIDsVect=[];

            sigIDs=signal.sigappsshared.SignalUtilities.getSelectedSignalIDs(eng,clientID,selectedViewIndices);

            isDone=isempty(sigIDs);
            while(~isDone)
                parsedIDs=[parsedIDs;sigIDs(1)];
                parsedViewIndices=[parsedViewIndices;selectedViewIndices(1)];

                sigID=sigIDs(1);
                sigIDs(1)=[];
                selectedViewIndices(1)=[];

                childrenIDs=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(eng,sigID);
                [~,intersectIDx]=intersect(sigIDs,childrenIDs);
                sigIDs(intersectIDx)=[];
                selectedViewIndices(intersectIDx)=[];

                isDone=isempty(sigIDs);
            end


            mapOfIDs=containers.Map('KeyType','double','ValueType','any');
            for idx=1:numel(parsedIDs)
                [~,childrenIDs]=Simulink.sdi.getIDsFromViewIndices(...
                eng.sigRepository,int32(parsedViewIndices(idx)),clientID);

                mapOfIDs(double(parsedIDs(idx)))=childrenIDs(:);
                leafSignalIDsVect=[leafSignalIDsVect;childrenIDs(:)];
            end
        end

        function leafSignalIDsVect=getUniqueSetOfSelectedSignalIDsByID(eng,sigIDs)





            parsedIDs=[];
            leafSignalIDsVect=[];

            isDone=isempty(sigIDs);
            while(~isDone)
                parsedIDs=[parsedIDs;sigIDs(1)];

                sigID=sigIDs(1);
                sigIDs(1)=[];

                childrenIDs=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(eng,sigID);
                [~,intersectIDx]=intersect(sigIDs,childrenIDs);
                sigIDs(intersectIDx)=[];

                isDone=isempty(sigIDs);
            end

            for idx=1:numel(parsedIDs)
                sigID=parsedIDs(idx);
                childrenIDs=signal.sigappsshared.SignalUtilities.recurseGetAllLeafChildren(eng,sigID);

                if isempty(childrenIDs)
                    childrenIDs=sigID;
                end
                leafSignalIDsVect=[leafSignalIDsVect;childrenIDs(:)];
            end
        end

        function flag=verifyEqualTimeValues(eng,signalIDs)








            allIDs=[];
            for idx=1:length(signalIDs)
                childIDs=signal.sigappsshared.SignalUtilities.recurseGetAllLeafChildren(eng,signalIDs(idx));

                if~isempty(childIDs)
                    allIDs=[allIDs,childIDs];
                else
                    allIDs=[allIDs,signalIDs(idx)];
                end

            end

            flag=Simulink.sdi.verifyEqualTimeValues(eng.sigRepository,int32(allIDs));

        end

        function setTmModeLabeledSignalSet(eng,signalID,tmModeLSS)





            validateattributes(signalID,{'numeric'},{'scalar'});
            validatestring(tmModeLSS,{'samples','fs','ts','tv','inherentTimetable'},'signal.sigappsshared.SignalUtilities.setTmModeLabeledSignalSet');
            Simulink.sdi.setTmModeLabeledSignalSet(eng.sigRepository,int32(signalID),tmModeLSS);
        end

        function tmModeLSS=getTmModeLabeledSignalSet(eng,signalID)



            validateattributes(signalID,{'numeric'},{'scalar'});
            tmModeLSS=Simulink.sdi.getTmModeLabeledSignalSet(eng.sigRepository,int32(signalID));
        end

        function setKeyLabeledSignalSet(eng,signalID,key)



            validateattributes(signalID,{'numeric'},{'scalar'});
            Simulink.sdi.setKeyLabeledSignalSet(eng.sigRepository,int32(signalID),key);
        end

        function Key=getKeyLabeledSignalSet(eng,signalID)



            validateattributes(signalID,{'numeric'},{'scalar'});
            Key=Simulink.sdi.getKeyLabeledSignalSet(eng.sigRepository,int32(signalID));
        end

        function LSS=getLabeledSignalSet(eng,signalID)






            validateattributes(signalID,{'numeric'},{'scalar'});
            lssKey=Simulink.sdi.getKeyLabeledSignalSet(eng.sigRepository,int32(signalID));
            matname=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();

            if isempty(lssKey)||exist(matname,'file')~=2


                LSS=[];
                return
            end

            m=matfile(matname);




            if isprop(m,lssKey)&&isa(m.(lssKey),'signallabelutils.internal.labeling.LightWeightLabeledSignalSet')
                LSS=m.(lssKey);
            else

                LSS=[];
                return
            end
        end

        function setMemberIndexLabeledSignalSet(eng,signalID,memberIdx)




            validateattributes(signalID,{'numeric'},{'scalar'});
            validateattributes(memberIdx,{'numeric'},{'scalar'});
            Simulink.sdi.setMemberIndexLabeledSignalSet(eng.sigRepository,int32(signalID),int32(memberIdx));
        end

        function memberIdx=getMemberIndexLabeledSignalSet(eng,signalID)





            validateattributes(signalID,{'numeric'},{'scalar'});
            memberIdx=Simulink.sdi.getMemberIndexLabeledSignalSet(eng.sigRepository,int32(signalID));
        end

        function sortedMemberSignalIDs=getAllMemberSignalIDsLabeledSignalSet(eng,signalID)





            validateattributes(signalID,{'numeric'},{'scalar'});

            parentLSSID=signal.sigappsshared.SignalUtilities.getSignalSuperparent(eng,signalID);
            members=eng.getSignalChildren(parentLSSID);

            sortedMemberSignalIDs=zeros(length(members),1,'like',members);
            for idx=1:length(members)
                memberIdx=Simulink.sdi.getMemberIndexLabeledSignalSet(eng.sigRepository,int32(members(idx)));
                if isempty(memberIdx)

                    sortedMemberSignalIDs=[];
                    return;
                else
                    sortedMemberSignalIDs(idx)=members(memberIdx);
                end
            end
        end

        function avgLineColor=getAvgColorOfChildren(eng,signalID)
            validateattributes(signalID,{'numeric'},{'scalar'});
            leafIDs=signal.sigappsshared.SignalUtilities.recurseGetAllLeafChildren(eng,int32(signalID));

            if~isempty(leafIDs)

                lineColor=zeros(length(leafIDs),3);
                for idx=1:length(leafIDs)
                    lineColor(idx,:)=eng.getSignalLineColor(leafIDs(idx));
                end

                avgLineColor=mean(lineColor,1);
            else

                avgLineColor=eng.getSignalLineColor(signalID);
            end
            avgLineColor=round(255*avgLineColor);
        end

        function currentData=getSignalDataStructure(eng,signalID,runID)
            validateattributes(signalID,{'numeric'},{'scalar'})

            currentData.Data=[];
            currentData.Time=[];
            if isempty(eng.getSignalChildren(signalID))

                dataTs=signal.sigappsshared.SignalUtilities.getSignalValue(eng,runID,signalID,true);
                currentData.Data=dataTs.Data;
                currentData.Time=dataTs.Time;
            end
        end


        function varInfo=getSignalHierarchyFromIDs(eng,sigIDs,activeApp)





            for idx=1:numel(sigIDs)
                varInfo(idx).signalID=sigIDs(idx);%#ok<*AGROW>
                varInfo(idx).Children=signal.sigappsshared.SignalUtilities.expandChildren(eng,varInfo(idx).signalID,activeApp);
                if isempty(varInfo(idx).Children)

                    varInfo(idx).isComplex=eng.sigRepository.getSignalComplexityAndLeafPath(varInfo(idx).signalID).IsComplex;
                    if varInfo(idx).isComplex
                        newIDs=eng.getSignalChildren(varInfo(idx).signalID);
                        varInfo(idx).tmMode=eng.getSignalTmMode(newIDs(1));
                        varInfo(idx).tmOrigin=eng.getSignalTmOrigin(newIDs(1));
                    else
                        varInfo(idx).tmMode=eng.getSignalTmMode(varInfo(idx).signalID);
                        varInfo(idx).tmOrigin=eng.getSignalTmOrigin(varInfo(idx).signalID);
                    end
                    varInfo(idx).isLSS=strcmp(varInfo(idx).tmMode,'inherentLabeledSignalSet');

                else
                    varInfo(idx).tmMode=[];
                    varInfo(idx).tmOrigin=[];
                    varInfo(idx).isLSS=all([varInfo(idx).Children.isLSS]);
                    varInfo(idx).isComplex=false;
                end
                varInfo(idx).isExportToTimetable=signal.sigappsshared.SignalUtilities.isExportTimeInfomation(eng,varInfo(idx),activeApp);
            end
        end


        function varInfo=expandChildren(eng,parentID,activeApp)


            newIDs=eng.getSignalChildren(parentID);
            if~isempty(newIDs)
                isComplex=eng.sigRepository.getSignalComplexityAndLeafPath(newIDs(1)).IsComplex;
                if isComplex&&isempty(eng.getSignalChildren(newIDs(1)))
                    varInfo=[];
                    return;
                end


                for idx=1:length(newIDs)
                    varInfo(idx).signalID=newIDs(idx);
                    varInfo(idx).Children=signal.sigappsshared.SignalUtilities.expandChildren(eng,newIDs(idx),activeApp);
                    if isempty(varInfo(idx).Children)

                        varInfo(idx).isComplex=eng.sigRepository.getSignalComplexityAndLeafPath(varInfo(idx).signalID).IsComplex;
                        if varInfo(idx).isComplex
                            grandChildIDs=eng.getSignalChildren(varInfo(idx).signalID);
                            varInfo(idx).tmMode=eng.getSignalTmMode(grandChildIDs(1));
                            varInfo(idx).tmOrigin=eng.getSignalTmOrigin(grandChildIDs(1));
                        else
                            varInfo(idx).tmMode=eng.getSignalTmMode(varInfo(idx).signalID);
                            varInfo(idx).tmOrigin=eng.getSignalTmOrigin(varInfo(idx).signalID);
                        end
                        varInfo(idx).isLSS=strcmp(varInfo(idx).tmMode,'inherentLabeledSignalSet');

                    else
                        varInfo(idx).tmMode=[];
                        varInfo(idx).tmOrigin=[];
                        varInfo(idx).isLSS=all([varInfo(idx).Children.isLSS]);
                        varInfo(idx).isExportToTimetable=all([varInfo(idx).Children.isExportToTimetable]);
                        varInfo(idx).isComplex=false;
                    end
                    varInfo(idx).isExportToTimetable=signal.sigappsshared.SignalUtilities.isExportTimeInfomation(eng,varInfo(idx),activeApp);
                end
            else

                varInfo=[];
            end
        end


        function[isExportToTimetable,tmMode,tmOrigin,exportAsTimetablePref]=isExportTimeInfomation(eng,verifyInfo,activeApp)





            if strcmp(activeApp,'siganalyzer')
                exportAsTimetablePref=Simulink.sdi.getExportAsTimetablePref();
                for idx=1:length(verifyInfo)

                    newID=signal.sigappsshared.SignalUtilities.getLeafNodeFromHierarchy(verifyInfo(idx));
                    tmMode{idx}=newID.tmMode;
                    tmOrigin{idx}=newID.tmOrigin;
                    isExportToTimetable(idx)=any(strcmp(tmMode{idx},{'inherentTimetable','inherentTimeseries'}))||...
                    (~strcmp(tmMode{idx},'samples')&&exportAsTimetablePref)||...
                    (~strcmp(tmMode{idx},'samples')&&any(strcmp(tmOrigin{idx},{'timetable','timeseries'})));
                end
            elseif strcmp(activeApp,'labeler')
                for idx=1:length(verifyInfo)
                    if isempty(verifyInfo(idx).Children)
                        if verifyInfo(idx).isLSS
                            lssTmMode=signal.sigappsshared.SignalUtilities.getTmModeLabeledSignalSet(eng,verifyInfo(idx).signalID);
                            isExportToTimetable(idx)=~strcmp(lssTmMode,'samples');
                        else
                            isExportToTimetable(idx)=~strcmp(verifyInfo(idx).tmMode,'samples');
                        end
                    else
                        isExportToTimetable(idx)=all([verifyInfo(idx).Children.isExportToTimetable]);
                    end
                end
            else
                isExportToTimetable=false;
                exportAsTimetablePref=false;
                tmMode=[];
                tmOrigin=[];
            end
        end


        function childID=getLeafNodeFromHierarchy(varInfo)



            childID=varInfo;
            while~isempty(childID.Children)
                childID=childID.Children(1);
            end
        end


        function[varInfo,validFlag]=verifyValidHierarchy(eng,requestedVarInfo)




            varInfo=[];

            for idx=1:length(requestedVarInfo)
                if~requestedVarInfo(idx).isLSS
                    [validFlag(idx),approvedVarInfo]=signal.sigappsshared.SignalUtilities.verifyTimeAndLength(eng,requestedVarInfo(idx));


                    varInfo=[varInfo,approvedVarInfo];
                    [~,matchedId]=unique([varInfo.signalID]);
                    varInfo=varInfo(matchedId);
                else

                    varInfo=[varInfo,requestedVarInfo(idx)];
                    validFlag(idx)=true;
                end
            end

            validFlag=all(validFlag);
        end

        function[validFlag,varInfo]=verifyTimeAndLength(eng,requestedVarInfo)





            varInfo=[];
            for idx=1:length(requestedVarInfo)
                if~isempty(requestedVarInfo(idx).Children)

                    [flag,requestedVarInfo(idx).Children]=signal.sigappsshared.SignalUtilities.verifyTimeAndLength(eng,requestedVarInfo(idx).Children);
                    if~flag


                        varInfo=[varInfo,requestedVarInfo(idx).Children];
                    else


                        varInfo=[varInfo,requestedVarInfo(idx)];
                    end
                else


                    varInfo=[varInfo,requestedVarInfo(idx)];
                end
            end


            validFlag=signal.sigappsshared.SignalUtilities.verifySignalLength(eng,varInfo);
            isExportToTimetable=[varInfo.isExportToTimetable];



            if any(isExportToTimetable)
                if validFlag
                    [validFlag,checkTimeValuesFlag]=signal.sigappsshared.SignalUtilities.verifyTimeParams(eng,varInfo,isExportToTimetable);
                end

                if validFlag&&checkTimeValuesFlag
                    validFlag=signal.sigappsshared.SignalUtilities.verifyTimeValues(eng,varInfo,isExportToTimetable);
                end
            end
        end


        function validFlag=verifySignalLength(eng,verifyInfo)



            validFlag=true;

            for idx=1:length(verifyInfo)



                newID=signal.sigappsshared.SignalUtilities.getLeafNodeFromHierarchy(verifyInfo(idx));
                numberPoints(idx)=eng.getSignalTmNumPoints(newID.signalID);
                signalName{idx}=eng.getSignalName(newID.signalID);
            end


            if any(numberPoints~=numberPoints(1))||any(contains(signalName,{'(real)','(imag)'}))
                validFlag=false;
            end
        end

        function[validFlag,checkTimeValuesFlag]=verifyTimeParams(eng,verifyInfo,isExportToTimetable)





            validFlag=true;
            checkTimeValuesFlag=true;
            tmMode=cell(nnz(isExportToTimetable),1);
            sampleRate=zeros(nnz(isExportToTimetable),1);
            sampleTime=zeros(nnz(isExportToTimetable),1);
            avgSampleRate=zeros(nnz(isExportToTimetable),1);
            timeRange=zeros(nnz(isExportToTimetable),2);
            isExportToTimetable=find(isExportToTimetable);
            for idx=1:length(isExportToTimetable)

                leafID=signal.sigappsshared.SignalUtilities.getLeafNodeFromHierarchy(verifyInfo(isExportToTimetable(idx)));
                if leafID.isComplex
                    sigID=eng.getSignalChildren(leafID.signalID);
                    sigID=sigID(1);
                    tmMode{idx}=eng.getSignalTmMode(sigID);
                else
                    sigID=leafID.signalID;
                    tmMode{idx}=leafID.tmMode;
                end


                timeRange(idx,:)=eng.getSignalTmTimeRange(sigID);
                switch tmMode{idx}
                case 'fs'
                    freqUnits=eng.getSignalTmSampleRateUnits(sigID);
                    mFreqUnits=signal.sigappsshared.Utilities.getFrequencyMultiplier(freqUnits);
                    sampleRate(idx)=eng.getSignalTmSampleRate(sigID)*mFreqUnits;
                case 'ts'
                    timeUnits=eng.getSignalTmSampleTimeUnits(sigID);
                    mTimeUnits=signal.sigappsshared.Utilities.getTimeMultiplier(timeUnits);
                    sampleTime(idx)=eng.getSignalTmSampleTime(sigID)*mTimeUnits;
                case{'tv','inherentTimetable','inherentTimeseries'}
                    avgSampleRate(idx)=eng.getSignalTmAvgSampleRate(sigID);
                end
            end

            if~isempty(tmMode)

                if any(~strcmp(tmMode,tmMode{1}))
                    validFlag=false;
                    return
                end


                switch tmMode{1}
                case 'fs'
                    if any(abs(sampleRate-sampleRate(1))>sqrt(eps))
                        validFlag=false;
                    end
                    checkTimeValuesFlag=false;
                case 'ts'
                    if any(abs(sampleTime-sampleTime(1))>sqrt(eps))
                        validFlag=false;
                    end
                    checkTimeValuesFlag=false;
                case{'tv','inherentTimetable','inherentTimeseries'}

                    rangeDiff=abs(timeRange-timeRange(1,:));
                    if any(rangeDiff(:)>sqrt(eps))
                        validFlag=false;
                    end
                end

                if any(abs(avgSampleRate-avgSampleRate(1))>sqrt(eps))
                    validFlag=false;
                end
            end
        end

        function validFlag=verifyTimeValues(eng,verifyInfo,isExportToTimetable)




            isExportToTimetable=find(isExportToTimetable);
            signalIDs=zeros(size(verifyInfo));
            for idx=1:length(isExportToTimetable)

                verifyInfo(idx)=signal.sigappsshared.SignalUtilities.getLeafNodeFromHierarchy(verifyInfo(isExportToTimetable(idx)));
                if verifyInfo(idx).isComplex
                    complexIDs=eng.getSignalChildren(verifyInfo(idx).signalID);
                    signalIDs(idx)=complexIDs(1);
                else
                    signalIDs(idx)=verifyInfo(idx).signalID;
                end
            end
            validFlag=signal.sigappsshared.SignalUtilities.verifyEqualTimeValues(eng,signalIDs);
        end

        function[dispLabel,dispValue,dispUnits]=getSampleRateOrTimeDisplayValue(eng,memberID)
            dispLabel='';
            dispValue='';
            dispUnits='';
            tmMode=eng.getSignalTmMode(memberID);
            if tmMode=="inherentLabeledSignalSet"
                tmMode=eng.getMetaDataV2(memberID,"tmModeLabeledSignalSet");
            end
            if tmMode=="fs"
                dispLabel="Fs: ";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(eng.getSignalTmSampleRate(memberID));
                dispUnits=eng.getSignalTmSampleRateUnits(memberID);
            elseif tmMode=="ts"
                dispLabel="Ts: ";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(eng.getSignalTmSampleTime(memberID));
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits(eng.getSignalTmSampleTimeUnits(memberID));
            elseif tmMode=="tv"||tmMode=="inherentTimeseries"||tmMode=="inherentTimetable"
                [dispLabel,dispValue,dispUnits]=...
                signal.sigappsshared.Utilities.getDisplayValuesForAvgSampleRate(...
                eng.getSignalTmAvgSampleRate(memberID));
                if eng.getSignalTmResampledSigID(memberID)~=-1



                    dispLabel="* "+dispLabel;
                end
            end
        end

        function[dispValue,dispUnits]=getStartTimeDisplayValues(engine,signalID)
            dispValue='';
            dispUnits='';
            tmMode=engine.getSignalTmMode(signalID);
            if tmMode=="samples"
                return;
            elseif tmMode=="tv"||tmMode=="inherentTimeseries"||tmMode=="inherentTimetable"
                timeRange=engine.getSignalTmTimeRange(signalID);
                [dispValue,dispUnits]=signal.sigappsshared.Utilities.getDisplayValuesForStartTime(timeRange(1));
            else
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(engine.getSignalTmStartTime(signalID));
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits(engine.getSignalTmStartTimeUnits(signalID));
            end
        end

        function[flag,type,sampleRate]=verifySignalsSampleRateAndComplexity(eng,leafSignalIDs)



            flag=true;
            type='';
            sampleRate=[];
            isSignalInSamples=false;
            for idx=1:numel(leafSignalIDs)
                signalID=leafSignalIDs(idx);
                signalComplexityAndLeafPath=eng.sigRepository.getSignalComplexityAndLeafPath(signalID);
                if signalComplexityAndLeafPath.IsComplex
                    flag=false;
                    type='complex';
                    sampleRate=[];
                    return;
                end
                if~isSignalInSamples
                    tmMode=eng.getSignalTmMode(signalID);
                    if tmMode=="inherentLabeledSignalSet"
                        tmMode=eng.getMetaDataV2(signalID,"tmModeLabeledSignalSet");
                    end
                    switch tmMode
                    case 'fs'
                        freqUnits=eng.getSignalTmSampleRateUnits(signalID);
                        mFreqUnits=signal.sigappsshared.Utilities.getFrequencyMultiplier(freqUnits);
                        currentSampleRate=eng.getSignalTmSampleRate(signalID)*mFreqUnits;
                    case 'ts'
                        timeUnits=eng.getSignalTmSampleTimeUnits(signalID);
                        mTimeUnits=signal.sigappsshared.Utilities.getTimeMultiplier(timeUnits);
                        currentSampleRate=1/(eng.getSignalTmSampleTime(signalID)*mTimeUnits);
                    case{'tv','inherentTimetable','inherentTimeseries'}
                        currentSampleRate=eng.getSignalTmAvgSampleRate(signalID);
                    otherwise

                        currentSampleRate=-1;
                        isSignalInSamples=true;
                    end
                end
                if idx==1
                    sampleRate=currentSampleRate;
                elseif abs(currentSampleRate-sampleRate)>sqrt(eps)
                    flag=false;
                    type='sampleRate';
                    return;
                end

            end
        end

        function filename=getStorageLSSFilename()




            appStateCtrl=signal.analyzer.controllers.AppState.getController();
            clientID=appStateCtrl.getSignalAnalyzerClientID();
            filename=tempdir+"temp_signalAnalyzer_datarepository_"+clientID+".mat";
        end

        function updateIsFiniteMetaDataFlag(engine,sigIDs,varValues,isRemoveTime)
            if isa(varValues,'labeledSignalSet')
                sigIDIndex=1;





                source=varValues.Source;
                for idx=1:numel(source)
                    if iscell(source{idx})
                        for jdx=1:numel(source{idx})
                            varValues=getDataValuesFromVariables(source{idx}{jdx},false);
                            for kdx=1:size(varValues,2)
                                engine.setMetaDataV2(sigIDs(sigIDIndex),'IsFinite',double(allfinite(varValues(:,kdx))));
                                sigIDIndex=sigIDIndex+1;
                            end
                        end
                    else
                        varValues=getDataValuesFromVariables(source{idx},false);
                        for jdx=1:size(varValues,2)
                            engine.setMetaDataV2(sigIDs(sigIDIndex),'IsFinite',double(allfinite(varValues(:,jdx))));
                            sigIDIndex=sigIDIndex+1;
                        end
                    end
                end
            else
                varValues=getDataValuesFromVariables(varValues,isRemoveTime);
                for idx=1:numel(sigIDs)
                    engine.setMetaDataV2(sigIDs(idx),'IsFinite',double(allfinite(varValues(:,idx))));
                end
            end
        end

        function isFinite=getIsFiniteMetaDataFlag(sigID)
            engine=Simulink.sdi.Instance.engine;
            isFinite=logical(engine.getMetaDataV2(sigID,'IsFinite'));
            if isempty(isFinite)

                isFinite=true;
            end
        end

        function deleteSignalsAndResampledSignalsInEngine(dbIDs)
            engine=Simulink.sdi.Instance.engine;
            for idx=1:length(dbIDs)
                if engine.isValidSignalID(dbIDs(idx))

                    resampledSigID=engine.sigRepository.getSignalTmResampledSigID(dbIDs(idx));
                    if engine.isValidSignalID(resampledSigID)
                        engine.sigRepository.remove(resampledSigID);
                    end
                    engine.sigRepository.remove(dbIDs(idx));
                end
            end
        end

        function outData=getSignalValue(eng,runID,sigID,canSignalBeComplex)
            outData=eng.safeTransaction(@getSignalValueImpl,eng.sigRepository,runID,sigID,canSignalBeComplex);
        end

    end
end





function signalValue=getSignalValueImpl(repo,runID,sigID,canSignalBeComplex)
    if canSignalBeComplex
        s=Simulink.sdi.Signal(repo,sigID);
        sigID=s.getIDForData();
    end
    outValues=Simulink.sdi.exportRunData(repo,runID,false,false,'',int32(sigID),int32.empty(),double.empty());
    signalValue=outValues.Streamed(:).Values;
end

function childrenIDs=helperGetAllChildren(eng,IDVect)

    childrenIDs=[];
    for idx=1:numel(IDVect)
        id=IDVect(idx);
        newIDs=eng.getSignalChildren(id);
        childrenIDs=[childrenIDs;newIDs(:)];
    end
end

function dataValues=getDataValuesFromVariables(dataValues,isRemoveTime)
    if isa(dataValues,'timeseries')

        dataValues=dataValues.Data;
    elseif isa(dataValues,'timetable')

        dataValues=dataValues.Variables;
    elseif isRemoveTime


        dataValues=dataValues(:,2:end);
    end
end