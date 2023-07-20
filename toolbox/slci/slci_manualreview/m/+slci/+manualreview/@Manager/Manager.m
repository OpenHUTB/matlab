


classdef Manager<handle

    properties(Constant,Hidden)
    end

    properties(Access=private)
        fInitialized=false;

fManualReviews
fCodeViews
fData

        fDebugMode=false;
    end

    methods(Static)

        obj=getInstance
    end

    methods(Access=protected)
        function obj=Manager()

            obj.init();
        end
    end

    methods(Hidden)

        open(obj,studio)


        close(obj,studio)
    end


    methods

        turnOffView(obj,editor)


        function out=getDebugMode(obj)
            out=obj.fDebugMode;
        end


        function setDebugMode(obj,aDebugMode)
            obj.fDebugMode=aDebugMode;
        end

        clearStudioData(obj,modelH);


        function out=hasManualReview(obj,studio)
            studioT=studio.getStudioTag;
            out=isKey(obj.fManualReviews,studioT);
        end


        function out=hasCodeView(obj,studio)
            studioT=studio.getStudioTag;
            out=isKey(obj.fCodeViews,studioT);
        end


        out=getManualReview(obj,studio);


        out=getCodeView(obj,studio);
    end

end