classdef EditorTab<handle




    properties
        uiData=containers.Map('KeyType','char','ValueType','any');
        tabType='soln';
        backgroundColor=[240,248,255];
        system='';
        blkHandle='';
        position=[];

        graderNumber=-1;
        matlabChecks={};
        matlabPassStatus=[];


        positionFlag=false;
        backgroundControl=false;
    end

    properties(Access=public,Constant)
        ASSESS_PANE_DOCKED_TAG='statusEmbedded';
    end

    methods(Access=public)
        function this=EditorTab(system,blkHandle,position,type,varargin)
            this.blkHandle=blkHandle;
            this.system=system;
            this.position=position([1,2]);
            this.tabType=type;

            this.graderNumber=learning.simulink.Application.getInstance().getCurrentTask;

            if~isempty(varargin)
                this.matlabChecks=varargin{1};
            end
            if numel(varargin)==2
                this.matlabPassStatus=varargin{2};
            end
        end

        function setPosition(obj,pos)
            obj.positionFlag=true;
            obj.position=pos;
        end

        function show(this,dlg,studio)

            this.position=dlg.position;

            signalCheckComponent=studio.getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.ASSESS_PANE_ID);
            if~isempty(signalCheckComponent)
                studio.destroyComponent(signalCheckComponent);
            end
            comp=GLUE2.DDGComponent(studio,learning.simulink.StudioMgr.ASSESS_PANE_ID,this);
            studio.registerComponent(comp);
            comp.UserClosable=false;
            ss=get(groot,'ScreenSize');
            assessmentPaneWidth=learning.simulink.Application.getInstance().getAssessmentPaneWidth();
            if isempty(assessmentPaneWidth)
                width=ss(3)*0.22;
            else
                width=assessmentPaneWidth;
            end
            height=ss(4)*0.50;
            comp.setPreferredSize(width,height);
            studio.moveComponentToDock(comp,...
            message('learning:simulink:resources:AssessmentPaneTitle').getString(),'right','stacked');
        end

        function openPlotWindow(this)
            if this.isBlockAssessment(this.blkHandle)
                block=getfullname(this.blkHandle);
                SignalCheckUtils.openSignalInPlotWindow(block);
            else
                assessmentObjs=learning.simulink.Application.getInstance().getInteractionAssessments();
                currentTask=learning.simulink.Application.getInstance().getCurrentTask();
                for i=1:length(assessmentObjs{currentTask})

                    if isequal(class(assessmentObjs{currentTask}{i}),'learning.assess.assessments.student.StudentBlockValue')
                        assessmentWithPlot=assessmentObjs{currentTask}{i};
                        break;
                    end
                end

                selectedBlock=gcb;
                if~strcmp(get_param(gcb,'Selected'),'on')
                    selectedBlock=[];
                end
                showFigureWindow=true;
                assessmentWithPlot.writePlotFigure(selectedBlock,showFigureWindow);
            end
        end

    end

    methods(Static)
        function opendlg(src)
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
        end

        function isBlockAssessment=isBlockAssessment(blockHandle)
            if isempty(blockHandle)
                isBlockAssessment=false;
                return;
            end
            block=getfullname(blockHandle);
            isBlockAssessment=contains(block,'Signal Assessment');
        end
    end
end
