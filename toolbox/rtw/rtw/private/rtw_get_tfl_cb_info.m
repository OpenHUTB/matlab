function fctInfo=rtw_get_tfl_cb_info(modelName,idx)







    persistent tlcList;
    persistent lastLength;
    hRtwFcnLib=get_param(modelName,'TargetFcnLibHandle');

    if isempty(hRtwFcnLib)
        DAStudio.error('RTW:buildProcess:loadObjectHandleError',...
        'TargetFcnLibhandle');
    end

    if idx==-1

        fctInfo=length(hRtwFcnLib.TLCCallList);
        if fctInfo==0
            return;
        end;
        for i=1:fctInfo
            tmpList(i)=hRtwFcnLib.TLCCallList(i).copy;%#ok<AGROW>
        end
        tlcList=tmpList;
        lastLength=fctInfo;
    elseif idx==-2
        numHits=length(hRtwFcnLib.TLCCallList);
        if lastLength~=numHits

            tlcListIndex=1;
            newListIndex=1;
            lengthTlcList=length(tlcList);
            for i=1:numHits


                if tlcListIndex<=lengthTlcList&&...
                    strcmp(hRtwFcnLib.TLCCallList(i).Key,...
                    tlcList(tlcListIndex).Key)&&...
                    strcmp(hRtwFcnLib.TLCCallList(i).GenCallback,...
                    tlcList(tlcListIndex).GenCallback)&&...
                    strcmp(hRtwFcnLib.TLCCallList(i).GenFileName,...
                    tlcList(tlcListIndex).GenFileName)
                    tlcListIndex=tlcListIndex+1;
                else

                    newList(newListIndex)=hRtwFcnLib.TLCCallList(i).copy;%#ok<AGROW>
                    newListIndex=newListIndex+1;
                end
            end
            tlcList=newList;
            fctInfo=length(tlcList);
            lastLength=numHits;
        else
            fctInfo=0;
        end
    elseif~isempty(tlcList)
        implH=tlcList(idx);
        genCallbackFcn=implH.Implementation.Name;
        if(RTW.isKeywordInTLC(genCallbackFcn))


            genCallbackFcn=['gen_',genCallbackFcn];
        end
        fctInfo=struct('genCallback',implH.GenCallback,...
        'genCallbackFcn',genCallbackFcn,...
        'FcnName',implH.Implementation.Name,...
        'FileName',implH.GenFileName,...
        'FcnType',implH.Implementation.Return.toString(),...
        'HdrFile',implH.Implementation.HeaderFile,...
        'NumInputs',implH.Implementation.NumInputs,...
        'NonFiniteSupportNeeded',implH.NonFiniteSupportNeeded);
    end



