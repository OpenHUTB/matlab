classdef DialogParameterTracer<handle

    properties(Access=private)
        BlkObj;
        ParamName;
        BlkObjToBeSet=[];
        ParamNameToBeSet=[];
        TracingComments={};
        MaskDataList=[];
        LinkDataList=[];
        ParameterNotPropagatedToLink=0;
    end
    methods
        function obj=DialogParameterTracer(blkObj,paramNameToBeSet)
            obj.BlkObj=blkObj;
            obj.ParamName=paramNameToBeSet;

            trace(obj);


            appendCommentsAfterTracing(obj);

        end
        function[blkObjToBeSet,paramNameToBeSet,tracingComment]=getDestinationProperties(obj)
            blkObjToBeSet=getBlkObjToBeSet(obj);
            paramNameToBeSet=getParamNameToBeSet(obj);
            tracingComment=getTracingComments(obj);
        end
        function blkObjToBeSet=getBlkObjToBeSet(obj)
            blkObjToBeSet=obj.BlkObjToBeSet;
        end
        function paramNameToBeSet=getParamNameToBeSet(obj)
            paramNameToBeSet=obj.ParamNameToBeSet;
        end
        function tracingComment=getTracingComments(obj)
            tracingComment=obj.TracingComments;
        end
    end
    methods(Access=private)

        function trace(obj)





























            blkObjOrig=obj.BlkObj;
            paramNameOrig=obj.ParamName;

            tracingComments={};

            [maskDataList,linkDataList,linkAboveMask]=SimulinkFixedPoint.TracingUtils.GetTraversalLists(blkObjOrig);

            obj.ParameterNotPropagatedToLink=linkAboveMask;

            if(numel(maskDataList)==0)

                blkObjToBeSet=blkObjOrig;
                paramNameToBeSet=paramNameOrig;

            else

                [blkObjToBeSet,paramNameToBeSet,tracingComments]=getTracingDestinationProperties(blkObjOrig,paramNameOrig,maskDataList);

                if~isempty(linkDataList)&&(~strcmp(blkObjToBeSet.getFullName,linkDataList(end).path))


                    obj.ParameterNotPropagatedToLink=1;
                else
                    obj.ParameterNotPropagatedToLink=0;
                end

            end

            obj.BlkObjToBeSet=blkObjToBeSet;
            obj.ParamNameToBeSet=paramNameToBeSet;
            obj.TracingComments=tracingComments;
            obj.MaskDataList=maskDataList;
            obj.LinkDataList=linkDataList;
        end
    end

    methods(Access=private)

        appendCommentsAfterTracing(obj);

    end
end

function[blkObjToBeSet,paramNameToBeSet,comments]=getTracingDestinationProperties(blkObj,paramNameOrig,maskDataList)
















    blkObjToBeSet=blkObj;
    paramNameToBeSet=paramNameOrig;
    comments={};








    currentMaskDataList=maskDataList;

    cnt=0;
    while true
        [blkObjToBeSet,paramNameToBeSet]=...
        getDestinationPropertiesThroughPromotion(blkObjToBeSet,paramNameToBeSet);
        cnt=cnt+1;
        paramContents=get_param(blkObjToBeSet.getFullName,paramNameToBeSet);

        if isPotentialMappedVar(paramContents)
            [isMappedAndEditable,blkObjToBeSet,paramNameToBeSet,currentMaskDataList,comments]=...
            getParamNameAndBlkToSetThroughMaskVarMapping(blkObjToBeSet,...
            paramNameToBeSet,paramContents,currentMaskDataList);
            if~isMappedAndEditable
                break;
            end
        else
            break;
        end
    end

end

function y=isPotentialMappedVar(dtstr)

    y=isempty(regexp(dtstr,'\W','ONCE'))&&...
    isempty(regexp(dtstr,'^(int|uint)(8|16|32)$','ONCE'))&&...
    ~strcmpi(dtstr,'double')&&~strcmpi(dtstr,'single');
end

function[blkObjToBeSet,paramNameToBeSet]=getDestinationPropertiesThroughPromotion(blkObj,paramName)


    blkObjToBeSet=blkObj;
    paramNameToBeSet=paramName;

    destinationBlock=blkObjToBeSet;
    destinationParameter=paramNameToBeSet;
    while~isempty(destinationBlock)&&~isempty(destinationParameter)
        [destinationBlock,destinationParameter]=Simulink.Mask.getPromotedInfo(blkObjToBeSet.getFullName,paramNameToBeSet);
        if~isempty(destinationParameter)
            blkObjToBeSet=get_param(destinationBlock,'Object');
            paramNameToBeSet=destinationParameter;
        end
    end
end

function y=selectMaskAboveBlk(blkObj,maskDataList)


    L=length(maskDataList);
    startIdx=L+1;
    matchFound=false;
    for i=1:length(maskDataList)
        pathLength=length(maskDataList(i).path);
        if strncmp(blkObj.getFullName,maskDataList(i).path,pathLength)
            matchFound=true;
            startIdx=i;
            break;
        end
    end
    if matchFound



        if isa(blkObj,'Simulink.SubSystem')
            startIdx=startIdx+1;
        end
        y=maskDataList(startIdx:L);
    end

end

function[isEditable,comment]=isEditableMaskParam(maskObjPath,paramName)

    isEditable=false;
    comment={};
    dialogParams=get_param(maskObjPath,'DialogParameters');
    if~isfield(dialogParams,paramName)
        comment{1}=DAStudio.message('SimulinkFixedPoint:autoscaling:maskSupportsAutoscalingButUnknownItem');
        return;
    else
        dialogParamsParamInfo=dialogParams.(paramName);
        isEditableString=strcmp(dialogParamsParamInfo.Type,'string');
        if~isEditableString
            comment{1}=DAStudio.message('SimulinkFixedPoint:autoscaling:underMaskNotSupportAutoscaling');
            return;
        end
        lockScalingParamNameStr='LockScale';
        if isfield(dialogParams,lockScalingParamNameStr)
            curLockScaleValue=get_param(maskObjPath,lockScalingParamNameStr);
            if strcmp('on',curLockScaleValue)
                comment{1}=DAStudio.message('SimulinkFixedPoint:autoscaling:lockedDTFromMask');
                return;
            end
        end

        isEditable=true;
        return;
    end
end

function[isMappedAndEditable,blkObjToBeSet,paramNameToBeSet,currentaskDataList,comments]=getParamNameAndBlkToSetThroughMaskVarMapping(blkObjToBeSet,paramNameToBeSet,paramContents,currentaskDataList)

    isMappedAndEditable=false;
    comments={};

    currentaskDataList=selectMaskAboveBlk(blkObjToBeSet,currentaskDataList);

    for i=1:length(currentaskDataList)
        if any(ismember(currentaskDataList(i).maskNames,paramContents))


            [isMappedAndEditable,comments]=...
            isEditableMaskParam(currentaskDataList(i).path,paramContents);
            blkObjToBeSet=get_param(currentaskDataList(i).path,'Object');
            paramNameToBeSet=paramContents;
            return;
        end
    end
end


