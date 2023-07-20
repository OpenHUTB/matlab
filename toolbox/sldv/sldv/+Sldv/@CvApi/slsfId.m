function cvId=slsfId(filePath,blkH,sfId,notUsed)%#ok<INUSD>






















    correctForMatlabFunction=true;

    try


        if~isempty(filePath)&&sfId==0
            scriptName=cvi.TopModelCov.getScriptNameFromPath(filePath);
            cvId=SlCov.CoverageAPI.getCovId([scriptName,'.m'],[]);
            if isempty(cvId)
                cvId=0;
            end
            return;
        end

        if sfId==0
            is_block=blkH~=0&&strcmp(get_param(blkH,'Type'),'block');
            if is_block&&(strcmp(get_param(blkH,'BlockType'),'SubSystem'))
                iterator=sldvprivate('iteratorTable','find',blkH);
                if~isempty(iterator)
                    blkH=iterator;
                elseif strcmp(get_param(blkH,'SFBlockType'),'MATLAB Function')








                    correctForMatlabFunction=false;
                end
            elseif is_block&&strcmp(get_param(blkH,'BlockType'),'ModelReference')




                blkName=get_param(blkH,'ModelName');
                blkH=get_param(blkName,'handle');
            else
                [status,toBlkH]=checkIfTestObjective(blkH);
                if status
                    blkH=toBlkH;
                end
            end
        elseif blkH~=0

            blkH=get_param(blkH,'Parent');
        end

        cvId=SlCov.CoverageAPI.getCovId(blkH,sfId,correctForMatlabFunction);
        if isempty(cvId)
            cvId=0;
        end

    catch MEx %#ok<NASGU>

        cvId=0;
    end
end

function[isTestObj,toblkh]=checkIfTestObjective(sfcnBlkH)
    toblkh=[];
    isTestObj=false;
    if strcmp(get_param(sfcnBlkH,'BlockType'),'S-Function')&&...
        strcmp(get_param(sfcnBlkH,'Name'),'customAVTBlockSFcn')
        isTestObj=true;
        topath=get_param(get_param(sfcnBlkH,'Parent'),'Parent');
        toblkh=get_param(topath,'Handle');
    end
end
