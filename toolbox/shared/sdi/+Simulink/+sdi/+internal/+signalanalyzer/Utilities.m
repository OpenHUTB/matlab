classdef Utilities<handle

%#ok<*INUSL>
    methods(Static,Hidden)

        function varInfo=getSignalHierarchyFromIDs(eng,sigIDs,activeApp)





            for idx=1:numel(sigIDs)
                varInfo(idx).signalID=sigIDs(idx);
                varInfo(idx).Children=Simulink.sdi.internal.signalanalyzer.Utilities.expandChildren(eng,varInfo(idx).signalID,activeApp);
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
                varInfo(idx).isExportToTimetable=Simulink.sdi.internal.signalanalyzer.Utilities.isExportTimeInfomation(eng,varInfo(idx),activeApp);
            end
        end

        function varInfo=getSelectedSignalHierarchyFromViewIndices(eng,viewIndices,clientID,activeApp)





            saUtil=Simulink.sdi.Instance.getSetSAUtils();
            if isempty(saUtil)
                varInfo=[];
                return
            end
            sigIDs=saUtil.getSelectedSignalIDs(eng,clientID,viewIndices);
            for idx=1:numel(sigIDs)
                varInfo(idx).signalID=sigIDs(idx);
                varInfo(idx).Children=Simulink.sdi.internal.signalanalyzer.Utilities.expandChildren(eng,varInfo(idx).signalID,activeApp);
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
                varInfo(idx).isExportToTimetable=Simulink.sdi.internal.signalanalyzer.Utilities.isExportTimeInfomation(eng,varInfo(idx),activeApp);
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
                    varInfo(idx).Children=Simulink.sdi.internal.signalanalyzer.Utilities.expandChildren(eng,newIDs(idx),activeApp);
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
                    varInfo(idx).isExportToTimetable=Simulink.sdi.internal.signalanalyzer.Utilities.isExportTimeInfomation(eng,varInfo(idx),activeApp);
                end
            else

                varInfo=[];
            end
        end

        function varInfo=convertSigNamesToVarNames(eng,varInfo)
            for idx=1:length(varInfo)
                sigID=varInfo(idx).signalID;
                sigName=eng.getSignalLabel(sigID,true);
                isMatrix=false;
                isTT=false;
                isCell=false;


                [~,sigName]=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(sigName);

                appendStr=[];
                if contains(sigName,{strtrim(getString(message('simulation_data_repository:sdr:RealSignalName','')))})
                    appendStr='_real';
                    sigName=strrep(sigName,getString(message('simulation_data_repository:sdr:RealSignalName','')),'');
                elseif contains(sigName,{strtrim(getString(message('simulation_data_repository:sdr:ImagSignalName','')))})
                    appendStr='_imag';
                    sigName=strrep(sigName,getString(message('simulation_data_repository:sdr:ImagSignalName','')),'');
                end

                varName=sigName;
                strIdx1=strfind(sigName,'(');
                if~isempty(strIdx1)
                    varName=sigName(1:strIdx1-1);
                    strIdx1=strfind(sigName,',');
                    strIdx2=strfind(sigName,')');
                    varName=[varName,'_',sigName(strIdx1+1:strIdx2-1)];%#ok<*AGROW>
                    isMatrix=true;
                end



                if~isempty(varInfo(idx).Children)
                    varInfo(idx).Children=Simulink.sdi.internal.signalanalyzer.Utilities.convertSigNamesToVarNames(eng,varInfo(idx).Children);
                end
                cellOpenIdx=strfind(varName,'{');
                if~isempty(cellOpenIdx)
                    varName(cellOpenIdx)='_';
                    cellCloseIdx=strfind(varName,'}');
                    varName(cellCloseIdx)=[];
                    isCell=true;
                end
                dotIdx=strfind(varName,'.');
                if~isempty(dotIdx)
                    varName(dotIdx)='_';
                    colName=varName(dotIdx+1:end);
                    isTT=true;
                else
                    colName=varName;
                end

                if~isempty(appendStr)
                    varName=[varName,appendStr];
                end

                varInfo(idx).colName=colName;
                varInfo(idx).varName=varName;
                varInfo(idx).isMatrix=isMatrix;
                varInfo(idx).isTT=isTT;
                varInfo(idx).isCell=isCell;
            end
        end

        function[varInfo,validFlag]=verifyValidHierarchy(eng,requestedVarInfo)




            varInfo=[];

            for idx=1:length(requestedVarInfo)
                if~requestedVarInfo(idx).isLSS
                    [validFlag(idx),approvedVarInfo]=Simulink.sdi.internal.signalanalyzer.Utilities.verifyTimeAndLength(eng,requestedVarInfo(idx));


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

                    [flag,requestedVarInfo(idx).Children]=Simulink.sdi.internal.signalanalyzer.Utilities.verifyTimeAndLength(eng,requestedVarInfo(idx).Children);
                    if~flag


                        varInfo=[varInfo,requestedVarInfo(idx).Children];
                    else


                        varInfo=[varInfo,requestedVarInfo(idx)];
                    end
                else


                    varInfo=[varInfo,requestedVarInfo(idx)];
                end
            end


            validFlag=Simulink.sdi.internal.signalanalyzer.Utilities.verifySignalLength(eng,varInfo);
            isExportToTimetable=[varInfo.isExportToTimetable];



            if any(isExportToTimetable)
                if validFlag
                    [validFlag,checkTimeValuesFlag]=Simulink.sdi.internal.signalanalyzer.Utilities.verifyTimeParams(eng,varInfo,isExportToTimetable);
                end

                if validFlag&&checkTimeValuesFlag
                    validFlag=Simulink.sdi.internal.signalanalyzer.Utilities.verifyTimeValues(eng,varInfo,isExportToTimetable);
                end
            end
        end

        function validFlag=verifySignalLength(eng,verifyInfo)



            validFlag=true;

            for idx=1:length(verifyInfo)



                newID=Simulink.sdi.internal.signalanalyzer.Utilities.getLeafNodeFromHierarchy(verifyInfo(idx));
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

                leafID=Simulink.sdi.internal.signalanalyzer.Utilities.getLeafNodeFromHierarchy(verifyInfo(isExportToTimetable(idx)));
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
                    mFreqUnits=Simulink.sdi.internal.signalanalyzer.Utilities.getFrequencyMultiplier(freqUnits);
                    sampleRate(idx)=eng.getSignalTmSampleRate(sigID)*mFreqUnits;
                case 'ts'
                    timeUnits=eng.getSignalTmSampleTimeUnits(sigID);
                    mTimeUnits=Simulink.sdi.internal.signalanalyzer.Utilities.getTimeMultiplier(timeUnits);
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




            saUtil=Simulink.sdi.Instance.getSetSAUtils();
            if isempty(saUtil)
                validFlag=false;
                return
            end

            isExportToTimetable=find(isExportToTimetable);
            signalIDs=zeros(size(verifyInfo));
            for idx=1:length(isExportToTimetable)

                verifyInfo(idx)=Simulink.sdi.internal.signalanalyzer.Utilities.getLeafNodeFromHierarchy(verifyInfo(isExportToTimetable(idx)));
                if verifyInfo(idx).isComplex
                    complexIDs=eng.getSignalChildren(verifyInfo(idx).signalID);
                    signalIDs(idx)=complexIDs(1);
                else
                    signalIDs(idx)=verifyInfo(idx).signalID;
                end
            end
            validFlag=saUtil.verifyEqualTimeValues(eng,signalIDs);
        end

        function childID=getLeafNodeFromHierarchy(varInfo)



            childID=varInfo;
            while~isempty(childID.Children)
                childID=childID.Children(1);
            end
        end

        function[isExportToTimetable,tmMode,tmOrigin,exportAsTimetablePref]=isExportTimeInfomation(eng,verifyInfo,activeApp)





            saUtil=Simulink.sdi.Instance.getSetSAUtils();
            if isempty(saUtil)
                isExportToTimetable=[];
                tmMode=[];
                tmOrigin=[];
                exportAsTimetablePref=[];
                return
            end
            if strcmp(activeApp,'siganalyzer')
                exportAsTimetablePref=Simulink.sdi.getExportAsTimetablePref();
                for idx=1:length(verifyInfo)

                    newID=Simulink.sdi.internal.signalanalyzer.Utilities.getLeafNodeFromHierarchy(verifyInfo(idx));
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
                            lssTmMode=saUtil.getTmModeLabeledSignalSet(eng,verifyInfo(idx).signalID);
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

        function[memberName,sigName,lssName]=convertToValidMemberName(name)


            name_woMatrix=strsplit(name,'(:');
            name_woMatrix=name_woMatrix{1};
            strIdxLSS=strfind(name_woMatrix,':');
            lssName=name(1:strIdxLSS-1);
            if~isempty(strIdxLSS)
                memberName=name_woMatrix(strIdxLSS+1:end);
                sigName=name(strIdxLSS+1:end);
            else
                memberName=name_woMatrix;
                sigName=name;
            end


            if length(memberName)>8&&strcmp(memberName(1:7),'Member{')
                strIdx=strfind(memberName,'}');
                memberName(strIdx(1))=[];
                sigName(strIdx(1))=[];
                memberName=matlab.lang.makeValidName(memberName(1:strIdx-1));
                sigName=[matlab.lang.makeValidName(sigName(1:strIdx-1)),sigName(strIdx:end)];
            else
                strIdxCell=strfind(memberName,'{');
                strIdxTT=strfind(memberName,'.');
                if~isempty(strIdxCell)
                    memberName=memberName(1:strIdxCell-1);
                elseif~isempty(strIdxTT)
                    memberName=memberName(1:strIdxTT-1);
                end
            end
        end

        function m=getTimeMultiplier(units)

            switch units
            case 'ns'
                m=1e-9;
            case 'us'
                m=1e-6;
            case 'ms'
                m=1e-3;
            case 's'
                m=1;
            case 'minutes'
                m=60;
            case 'hours'
                m=60*60;
            case 'days'
                m=60*60*24;
            case 'years'
                m=60*60*24*365;
            end
        end

        function m=getFrequencyMultiplier(units)

            switch lower(units)
            case 'hz'
                m=1;
            case 'khz'
                m=1e3;
            case 'mhz'
                m=1e6;
            case 'ghz'
                m=1e9;
            end
        end
    end
end