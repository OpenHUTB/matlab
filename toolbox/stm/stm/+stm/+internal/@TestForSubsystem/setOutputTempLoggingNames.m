function setOutputTempLoggingNames(obj,sigHandles,tmpName)























    for k=1:obj.numOfComps
        try
            if obj.proceedToNextStep(k)
                sigHdls=sigHandles{k};
                for j=1:length(sigHdls)
                    if sigHdls(j)==-1
                        continue;
                    end

                    indexToUse=j;
                    loggingName=tmpName;
                    portType='outputs';
                    gotoname='';
                    if strcmp(tmpName,'sltest_goto')

                        l=get_param(sigHdls(j),'Line');
                        bHdl=get_param(l,'DstBlockHandle');
                        gotoname=get_param(bHdl,'Name');
                        loggingName=[tmpName,gotoname];
                        indexToUse=0;
                        portType='goto';
                    end
                    dataLoggingName=obj.setTempLoggingNames(sigHdls(j),indexToUse,loggingName,k);

                    obj.cacheBlkStructInMap(dataLoggingName,'outputs',portType,gotoname,'','PortIndex',indexToUse,'ComponentIndex',k);



                    if~obj.outSigNameMap.isKey(sigHdls(j))
                        obj.outSigNameMap(sigHdls(j))=get_param(sigHdls(j),'Name');
                        set_param(sigHdls(j),'Name','');
                    end
                end
            end
        catch me
            obj.populateErrorContainer(me,k);
        end
    end

