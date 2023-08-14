classdef MenuUtils


    methods(Static)
        function out=checkSlicerUI(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);


            out=~isempty(uiObj)&&ishandle(uiObj);
        end

        function out=checkSlicerHasSlice(callbackInfo)
            modelH=callbackInfo.model.Handle;

            [sliceMapper,~]=modelslicerprivate('sliceActiveModelMapper','get',modelH);
            out=~isempty(sliceMapper);
        end

        function out=checkSlicerIsaSlice(callbackInfo)
            [isSlice,origLoaded]=modelisSlice(callbackInfo);
            out=isSlice&&origLoaded;
        end
    end
end

function out=isModelLoaded(modelName)
    out=false;
    try
        mdlH=get_param(modelName,'Handle');
        out=ishandle(mdlH);
    catch Mex
    end
end

function[isSlice,origLoaded]=modelisSlice(callbackInfo)
    isSlice=false;
    origLoaded=false;
    modelH=callbackInfo.model.Handle;

    try
        origMdlName=get_param(modelH,'SlicerOriginalModel');
        isSlice=~isempty(origMdlName);
        origLoaded=isModelLoaded(origMdlName);
    catch Mex
    end
end




