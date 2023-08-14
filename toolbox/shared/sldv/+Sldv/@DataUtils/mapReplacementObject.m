
function[designObject,replacementSid]=mapReplacementObject(object,modelH,varargin)






    designObject=object;
    replacementSid='';
    analysisInfo=[];
    if nargin<3
        return;
    end
    if nargin<4
        forceMapToExtractedModel=false;
    else




        forceMapToExtractedModel=varargin{2};
    end

    if isa(varargin{1},'SlAvt.TestComponent')
        testcomp=varargin{1};
        analysisInfo=testcomp.analysisInfo;
    elseif isstruct(varargin{1})
        analysisInfo=varargin{1};
    end

    if isempty(analysisInfo)||...
        Sldv.utils.getObjH(modelH)==Sldv.utils.getObjH(analysisInfo.analyzedModelH)
        return;
    end

    blockReplacementApplied=...
    analysisInfo.replacementInfo.replacementsApplied;
    if~isempty(analysisInfo.analyzedSubsystemH)&&...
        ishandle(analysisInfo.analyzedSubsystemH)








        if slavteng('feature','MergeHarness')&&...
            strcmp(get_param(analysisInfo.analyzedSubsystemH,'blocktype'),'ModelReference')
            parentH=get_param(bdroot(object),'handle');
        else
            parent=get_param(analysisInfo.analyzedSubsystemH,'parent');
            parentH=get_param(parent,'Handle');
        end
        atomicss_report=true;
    else
        if blockReplacementApplied
            parentH=modelH;
        else
            parentH=[];
        end
        atomicss_report=false;
    end

    [designObject,replacedParentInfo,objReplacementInfo,origSFBlockH]=...
    sldvshareprivate('util_resolve_obj',...
    object,parentH,atomicss_report,...
    blockReplacementApplied,analysisInfo,true,forceMapToExtractedModel);

    isBDExtractedModel=analysisInfo.blockDiagramExtract;

    if~isempty(replacedParentInfo)
        setReplacementSid(replacedParentInfo.BeforeRepFullPath);
    elseif~isempty(objReplacementInfo)
        setReplacementSid(objReplacementInfo.BeforeRepFullPath);
    end

    function setReplacementSid(beforeRepFullPath)
        blockH=resolveInOriginalModel(analysisInfo,...
        beforeRepFullPath,parentH,atomicss_report,designObject,origSFBlockH);
        replacementSid=Simulink.ID.getSID(blockH);
        if isBDExtractedModel&&strcmpi(get_param(blockH,'SID'),'1')



            replacementSid='';
        end
    end
end

function blockH=resolveInOriginalModel(analysisInfo,blockPath,parentH,atomicss_report,designObject,origSFBlockH)
    blockH=get_param(blockPath,'Handle');
    if atomicss_report
        blockRootName=get_param(bdroot(blockPath),'Name');
        if isempty(origSFBlockH)
            designRootName=get_param(bdroot(designObject),'Name');
        else
            designRootName=get_param(bdroot(origSFBlockH),'Name');
        end
        if~strcmp(getfullname(analysisInfo.extractedModelH),blockRootName)

            if floor(designObject)==designObject

                blockH=sldvshareprivate('find_equiv_handle',designObject);
            else
                blockH=designObject;
            end
        elseif~strcmp(blockRootName,designRootName)
            blockH=...
            sldvshareprivate('util_resolve_obj',...
            blockH,...
            parentH,true,...
            true,analysisInfo);
        end
    end
end
