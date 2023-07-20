classdef ProgressBar<handle





    properties
        pBar='';
        title='';
        errorID='';
    end


    methods(Access='public')
        function h=ProgressBar(title,errorID)
            h.title=title;
            h.errorID=errorID;
        end
    end

    methods(Access='public')
        function showProgressBar(h,message,value)
            if(isempty(h.pBar))
                h.pBar=DAStudio.WaitBar;
            end
            h.pBar.setWindowTitle(h.title);
            h.setProgressBarValue(message,value,1);
            h.pBar.show();
        end

        function vis=isProgressBarVisible(h)
            assert(~isempty(h.pBar));
            vis=h.pBar.visible();
        end

        function setProgressBarValue(h,message,value,varargin)
            assert(~isempty(h.pBar));


            if(nargin<4&&~h.isProgressBarVisible())
                error(h.errorID,DAStudio.message(h.errorID));
            end
            if(value<0)
                h.pBar.setCircularProgressBar(true);
            else
                h.pBar.setCircularProgressBar(false);
                h.pBar.setValue(value);
            end
            if(~isempty(message))
                h.pBar.setLabelText(message);
            end
            h.pBar.show();
        end

        function closeProgressBar(h)
            h.pBar=[];
        end
    end
end
