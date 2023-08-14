function ret=createTable(this,eng,sigIDs,numMDRows,varargin)



    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();




    expNumRows=0;
    sigs=cell(1,length(sigIDs));
    vals=cell(1,length(sigIDs));
    timeVals=cell(1,length(sigIDs));
    dataVals=cell(1,length(sigIDs));
    sigDims=cell(1,length(sigIDs));
    numChannels=ones(size(sigIDs));
    repo=sdi.Repository(1);
    xlRowsLimitReached=false;
    for sigIdx=1:length(sigIDs)
        sigs{sigIdx}=Simulink.sdi.Signal(repo,sigIDs(sigIdx));
        vals{sigIdx}=this.getValuesForSignal(sigs{sigIdx});
        timeVals{sigIdx}=vals{sigIdx}.Time;
        if isduration(timeVals{sigIdx})
            timeVals{sigIdx}=seconds(timeVals{sigIdx});
        end
        dataVals{sigIdx}=vals{sigIdx}.Data;
        numRowsForSig=length(timeVals{sigIdx});
        if expNumRows<numRowsForSig
            expNumRows=numRowsForSig;
        end



        if numMDRows+expNumRows+1>this.MAX_ROWS_ALLOWED

            msgStr=getString(message('SDI:sdi:XLSMaxRowsWarn',...
            num2str(this.MAX_ROWS_ALLOWED)));
            if~xlRowsLimitReached

                sw=warning('off','backtrace');
                tmp=onCleanup(@()warning(sw));
                warning('SDI:sdi:XLSMaxRowsWarn',msgStr);
                xlRowsLimitReached=true;
            end
            expNumRows=this.MAX_ROWS_ALLOWED-numMDRows-1;
            continue;
        end


        id=sigs{sigIdx}.ID;
        if eng.sigRepository.isRealPartOfCompositeComplex(id)
            id=eng.sigRepository.getSignalParent(id);
        end
        if eng.sigRepository.isUnexpandedMatrixLeaf(id)
            sigDims{sigIdx}=sigs{sigIdx}.Dimensions;
            numChannels(sigIdx)=prod(sigDims{sigIdx});
        end
    end


    for sigIdx=1:length(sigIDs)
        if fw.isImportCancelled()
            wksParser.IsImportCancelled=true;
            error('cancel')
        end
        sig=sigs{sigIdx};
        sigTimeVals=timeVals{sigIdx};
        numRows=length(sigTimeVals);
        sigDataVals=dataVals{sigIdx};


        if numMDRows+numRows+1>this.MAX_ROWS_ALLOWED
            numRows=this.MAX_ROWS_ALLOWED-numMDRows-1;
        end

        for chIdx=1:numChannels(sigIdx)
            sigTimeVals=sigTimeVals(1:numRows);
            if numChannels(sigIdx)>1
                idxStr=locGetChannelIdxStr(sigDims{sigIdx},chIdx);
                sigDataVals=eval(['dataVals{sigIdx}',idxStr]);
                sigDataVals=sigDataVals(1:numRows);
            else
                sigDataVals=sigDataVals(1:numRows);
            end
            isSigEnum=eng.isEnum(sig.ID);
            isSigFixedPoint=isfi(sigDataVals);
            isSigLogical=islogical(sigDataVals);
            isHalf=strcmpi(sig.DataType,'half');
            isComplex=strcmpi(sig.Complexity,'complex');
            if~isequal(size(sigDataVals),size(sigTimeVals))
                sigDataVals=reshape(sigDataVals,size(sigTimeVals));
            end
            if~isequal(numRows,expNumRows)



                for rowIdx=1:expNumRows
                    if rowIdx>numRows
                        sigTimeVals(end+1)=NaN;%#ok
                        if isSigEnum


                            sigDataVals(end+1)="";%#ok
                        elseif isSigFixedPoint||isSigLogical||isHalf

                            sigDataVals=double(sigDataVals);
                            sigDataVals(end+1)=NaN;%#ok
                        elseif isComplex

                            sigDataVals(end+1)=NaN+i*NaN;%#ok
                        else
                            sigDataVals(end+1)=NaN;%#ok
                        end
                    else
                        if isSigEnum
                            sigDataVals=string(sigDataVals);
                        end
                    end
                end
                [~,sigCols]=size(sigDataVals);
                [~,timeCols]=size(sigTimeVals);
                if sigCols~=1


                    [r,c]=size(sigDataVals);
                    sigDataVals=reshape(sigDataVals,[c,r]);
                end
                if timeCols~=1


                    sigTimeVals=sigTimeVals';
                end
            end
            if isSigEnum
                sigDataVals=string(sigDataVals);
            elseif isComplex

                realDataVals=real(sigDataVals);
                imagDataVals=imag(sigDataVals);
                if isSigFixedPoint||isHalf
                    realDataVals=double(realDataVals);
                    imagDataVals=double(imagDataVals);
                end
                sigDataVals=[realDataVals,imagDataVals];
            elseif isSigFixedPoint||isHalf

                sigDataVals=double(sigDataVals);
            elseif strcmpi(sig.Dimensions,'variable')

                sigDataVals=locConvertVarDimSignalToCols(sigDataVals);
            end
            if sigIdx==1&&chIdx==1

                ret=[num2cell(sigTimeVals),num2cell(sigDataVals)];
                currTimeVals=sigTimeVals;
            else

                if this.RateBasedGrouping
                    if~isequal(rmmissing(sigTimeVals),...
                        rmmissing(currTimeVals))
                        currTimeVals=sigTimeVals;
                        ret(:,end+1)=num2cell(sigTimeVals);%#ok
                    end
                else

                    ret(:,end+1)=num2cell(sigTimeVals);%#ok
                end
                for idx=1:width(sigDataVals)
                    ret(:,end+1)=num2cell(sigDataVals(:,idx));%#ok
                end
            end


            if~isempty(this.ProgressTracker)
                this.ProgressTracker.incrementValue();
            end
        end
    end
end


function idxStr=locGetChannelIdxStr(sampleDims,channelIdx)
    dimIdx=cell(size(sampleDims));
    [dimIdx{:}]=ind2sub(sampleDims,channelIdx);
    channel=cell2mat(dimIdx);
    numDims=length(channel);
    if numDims==1
        idxStr=sprintf('(:,%d)',channel);
    else
        idxStr=sprintf('%d,',channel);
        idxStr=sprintf('(%s:)',idxStr);
    end
end


function ret=locConvertVarDimSignalToCols(sigDataVals)
    nRows=length(sigDataVals);
    maxLen=0;
    for rowIdx=1:nRows
        currLen=numel(sigDataVals{rowIdx});
        if currLen>maxLen
            maxLen=currLen;
        end
    end
    ret=ones(nRows,maxLen);
    for rowIdx=1:nRows
        currRow=sigDataVals{rowIdx};
        if numel(currRow)<maxLen
            for idx=numel(currRow)+1:maxLen
                currRow(idx)=NaN;
            end
        end
        ret(rowIdx,:)=reshape(currRow,1,maxLen);
    end
end
