




function sldvData=applyCodeMappingInfo(sldvData)


    if~isfield(sldvData.ModelObjects,'mappedElements')||...
        ~isfield(sldvData.Objectives,'mappedElementsIdx')
        return
    end

    try



        moIdxInfo(1:numel(sldvData.ModelObjects))=struct('moIdx',0,'elOffset',0);


        allModelObjects=[];
        for ii=1:numel(sldvData.ModelObjects)
            mo=sldvData.ModelObjects(ii);

            numObjs=numel(allModelObjects);
            moIdxInfo(ii).moIdx=numObjs+1;

            if~isempty(mo.mappedElements)&&~isempty(mo.objectives)

                subIdx=unique([mo.mappedElements.objectives]);


                remObjectives=mo.objectives(~ismember(mo.objectives,subIdx));



                moOrig=mo;
                mo=moOrig.mappedElements;
                if~isempty(remObjectives)
                    moIdxInfo(ii).elOffset=moIdxInfo(ii).moIdx;
                    moOrig.objectives=remObjectives;
                    mo=[moOrig;mo];%#ok<AGROW>
                else
                    moIdxInfo(ii).elOffset=moIdxInfo(ii).moIdx-1;
                    moIdxInfo(ii).moIdx=[];
                end
            else
                moIdxInfo(ii).elOffset=[];
            end

            allModelObjects=[allModelObjects;mo];%#ok<AGROW>
        end


        allTestObjectives=sldvData.Objectives;
        for ii=1:numel(allTestObjectives)
            to=allTestObjectives(ii);
            offsetInfo=moIdxInfo(to.modelObjectIdx);

            modelObjectIdx=offsetInfo.moIdx;
            if~isempty(offsetInfo.elOffset)&&~isempty(to.mappedElementsIdx)
                modelObjectIdx=[modelObjectIdx,offsetInfo.elOffset+to.mappedElementsIdx];%#ok<AGROW>
            end
            allTestObjectives(ii).modelObjectIdx=unique(modelObjectIdx);
        end


        sldvData.ModelObjects=allModelObjects;
        sldvData.Objectives=allTestObjectives;

    catch MEx %#ok<NASGU>
        if sldv.code.internal.feature('disableErrorRecovery')
            rethrow(MEx);
        end
        return
    end
