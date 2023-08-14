classdef ReportState<handle&matlab.mixin.Copyable

























    properties


        CurrentFigure=[];


        PreRunOpenFigures=[];


        CurrentAxes=[];


        InitWSVars=[];


        InitWSAnsVar=[];
    end

    methods
        function obj=ReportState()


            obj.PreRunOpenFigures=findall(0,'-depth',1,'type','figure');


            obj.InitWSVars=evalin('base','who');

            if evalin('base','exist("ans","var")')
                obj.InitWSAnsVar=evalin('base','ans');
            else
                obj.InitWSAnsVar=[];
            end
        end

        function fig=get.CurrentFigure(this)
            if isempty(this.CurrentFigure)||~isgraphics(this.CurrentFigure)
                this.CurrentFigure=get(0,'CurrentFigure');
            end
            fig=this.CurrentFigure;
        end

        function axes=get.CurrentAxes(this)
            currentFig=this.CurrentFigure;


            if(isempty(this.CurrentAxes)||~isgraphics(this.CurrentAxes))...
                &&~isempty(currentFig)&&isgraphics(currentFig)
                this.CurrentAxes=get(currentFig,'CurrentAxes');
            end

            axes=this.CurrentAxes;
        end

        function cleanup(this)





            curFigures=findall(0,'-depth',1,'type','figure');

            oldFigures=this.PreRunOpenFigures;



            badFigures=setdiff(curFigures,oldFigures);

            badFigures=findall(badFigures,...
            '-depth',0);
            close(badFigures,'force');

            this.CurrentFigure=[];
            this.CurrentAxes=[];
        end

        function clearWorkspaceVariables(this)

            vars=evalin('base','who');
            rptWSVars=setdiff(vars',this.InitWSVars');
            assignin('base','rptWSVars',rptWSVars);

            if~isempty(rptWSVars)
                evalin('base','clearvars(rptWSVars{:})');
            end
            evalin('base','clearvars("rptWSVars")');
        end
    end
end

