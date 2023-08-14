classdef ProgressBar<handle


    properties
        pBar=[];
        modelName='';
        callSite='';
    end


    methods(Access='public')
        function obj=ProgressBar(modelName,callSite)
            obj.callSite=callSite;
            obj.modelName=modelName;
            if strcmpi(callSite,'UI')
                if(isempty(obj.pBar))
                    obj.pBar=DAStudio.WaitBar;
                end
                obj.pBar.setWindowTitle(getString(message('FMUExport:FMU:FMU2ExpCSStatusDialogTitle',obj.modelName)));
                obj.pBar.setMinimum(0);
                obj.pBar.setMaximum(100);
                obj.pBar.setAlwaysOnTop(true);
                obj.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusIntializing')),1);
                obj.pBar.show;
                obj.centerDialog();
            end
        end
        function vis=isProgressBarVisible(obj)
            vis=false;
            if(~isempty(obj.pBar))
                vis=obj.pBar.isVisible;
            end
        end

        function setProgressBarInfo(obj,messageStr,varargin)
            if(~isempty(obj.pBar))

                if obj.pBar.wasCanceled
                    ME=MSLException([],message('FMUExport:FMU:FMU2ExpCSUserAborted',obj.modelName));
                    throw(ME);
                end
                if(~isempty(messageStr))
                    obj.pBar.setLabelText(messageStr);
                end
                switch nargin
                case 1
                case 2
                    obj.pBar.setCircularProgressBar(true);
                otherwise
                    obj.pBar.setValue(varargin{1});
                end
                obj.pBar.show();
            end
        end
        function closeProgressBar(obj)
            obj.pBar=[];
        end
        function delete(obj)
            if(~isempty(obj.pBar))
                delete(obj.pBar);
            end
        end
        function centerDialog(obj)
            if isProgressBarVisible(obj)
                [x,y]=obj.pBar.getPosition();
                [w,h]=obj.pBar.getSize();
                currPos=[x,y,w,h];

                modelPos=get_param(obj.modelName,'Location');

                modelPos(3)=modelPos(3)-modelPos(1);
                modelPos(4)=modelPos(4)-modelPos(2);

                newPos=[
                modelPos(1)+(modelPos(3))/2,...
                modelPos(2)+(modelPos(4))/2,...
                currPos(3),...
                currPos(4)];
                obj.pBar.setSize(newPos(3)+400,newPos(4));
                obj.pBar.centreOnLocation(newPos(1),newPos(2));
            end
        end
    end
end