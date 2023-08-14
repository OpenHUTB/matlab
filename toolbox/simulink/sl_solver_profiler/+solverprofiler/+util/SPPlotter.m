classdef SPPlotter<handle

    properties(SetAccess=private)





















Data
HFigure
HStepSize
HMaxStepSize
HZC
HFailure
HReset
HJacobian
    end

    methods

        function obj=SPPlotter(stepSizeFigureHandle,SPData)
            obj.HFigure=stepSizeFigureHandle;
            obj.Data=SPData;
        end


        function bringSelectedEventToFront(obj,tab)
            switch(tab)
            case 'Zero Crossing'
                uistack(obj.HZC,'top');
            case 'Solver Reset'
                uistack(obj.HReset,'top');
            case 'Solver Exception'
                uistack(obj.HFailure,'top');
            case 'Jacobian Analysis'
                uistack(obj.HJacobian,'top');
            end
        end


        function generateCleanFigure(obj)
            if isempty(obj.HFigure.CurrentAxes)
                figure(obj.HFigure);
                axes(obj.HFigure);
            end


            if~isempty(obj.HFigure.Children)
                hold(obj.HFigure.CurrentAxes,'off');
                axis(obj.HFigure.CurrentAxes,'auto');
            end


            mdl=obj.Data.getData('Model');
            obj.HStepSize=[];
            obj.HStepSize=semilogy(obj.HFigure.CurrentAxes,1,1,'.-','Color',[35,0,230]/255,'Tag','h');
            obj.HStepSize.XData=[];
            obj.HStepSize.YData=[];

            hold(obj.HFigure.CurrentAxes,'on');
            obj.HFigure.CurrentAxes.Toolbar.Visible='off';

            isFixed=strcmp(get_param(mdl,'SolverType'),'Fixed-step');
            if~isFixed
                obj.HMaxStepSize=semilogy(obj.HFigure.CurrentAxes,1,1,'k--','LineWidth',2,'Tag','hmax');
                obj.HMaxStepSize.XData=[];
                obj.HMaxStepSize.YData=[];
            else
                obj.HMaxStepSize=[];
            end


            obj.HFailure=semilogy(obj.HFigure.CurrentAxes,1,1,'.','Color',[226,61,45]/255,...
            'markersize',17,'Tag','pointsFailure');
            obj.HZC=semilogy(obj.HFigure.CurrentAxes,1,1,'.','Color',[238,166,0]/255,...
            'markersize',17,'Tag','pointsZC');
            obj.HReset=semilogy(obj.HFigure.CurrentAxes,1,1,'.','markersize',17,...
            'Color',[0,153,21]/255,'Tag','pointsReset');
            obj.HJacobian=semilogy(obj.HFigure.CurrentAxes,1,1,'k.','markersize',17,...
            'Tag','pointsJacobian');

            obj.removeAllEventDots();


            strZC=DAStudio.message('Simulink:solverProfiler:Zerocrossing');
            strException=DAStudio.message('Simulink:solverProfiler:Solverexception');
            strReset=DAStudio.message('Simulink:solverProfiler:Solverreset');
            strStep=DAStudio.message('Simulink:solverProfiler:Stepsize');
            strJacobian=DAStudio.message('Simulink:solverProfiler:Solverjacobian');

            if isFixed
                legend(obj.HFigure.CurrentAxes,...
                {strStep,strException,strZC,strReset,strJacobian},...
                'Location','southeastoutside','PickableParts','none');
            else
                legend(obj.HFigure.CurrentAxes,...
                {strStep,['Max ',strStep],strException,strZC,strReset,strJacobian},...
                'Location','southeastoutside','PickableParts','none');
            end


            strXLabel=DAStudio.message('Simulink:solverProfiler:plotXLabel');
            strYLabel=DAStudio.message('Simulink:solverProfiler:plotYLabel');
            xlabel(obj.HFigure.CurrentAxes,strXLabel,'FontSize',10);
            ylabel(obj.HFigure.CurrentAxes,strYLabel,'FontSize',10);

            tout=obj.Data.getTout();
            hmax=obj.Data.getHmax();
            hs=[tout(2)-tout(1);diff(tout)];


            obj.HStepSize.XData=tout;
            obj.HStepSize.YData=hs;


            if~strcmp(get_param(mdl,'SolverType'),'Fixed-step')
                obj.HMaxStepSize.XData=[tout(1);tout(end)];
                obj.HMaxStepSize.YData=[hmax;hmax];
            end


            if strcmp(get_param(mdl,'SolverType'),'Fixed-step')&&...
                diff(obj.HFigure.CurrentAxes.YLim)<10000*eps
                obj.HFigure.CurrentAxes.YLim(1)=obj.HFigure.CurrentAxes.YLim(1)-10000*eps;
                obj.HFigure.CurrentAxes.YLim(2)=obj.HFigure.CurrentAxes.YLim(2)+10000*eps;
            end


            axis(obj.HFigure.CurrentAxes,'manual');
            set(obj.HFigure.CurrentAxes,'Color',[252,252,252]/255);
        end



        function updateZCCheckBoxPoints(obj,status)
            if(~status)



                obj.HZC.XData=[];
                obj.HZC.YData=[];


                if(~isempty(obj.HZC.UserData))
                    obj.refreshTable(obj.HZC);
                    obj.Data.setData('ZCTableRowSelected',[]);
                end
            else

                zcMatrix=obj.Data.getAllZCEvents();
                if~isempty(zcMatrix)
                    obj.HZC.YData=zcMatrix(:,2);
                    obj.HZC.XData=zcMatrix(:,1);

                else
                    obj.HZC.XData=[];
                    obj.HZC.YData=[];
                end
            end
        end


        function updateFailureCheckBoxPoints(obj,status)
            if(~status)



                obj.HFailure.XData=[];
                obj.HFailure.YData=[];


                if(~isempty(obj.HFailure.UserData))
                    obj.refreshTable(obj.HFailure);
                    obj.Data.setData('ExceptionTableRowSelected',[]);
                    obj.Data.setData('ExceptionTableColumnSelected',[]);
                end
            else

                exceptionMatrix=obj.Data.getTotalFailureMatrix(0);
                if~isempty(exceptionMatrix)
                    obj.HFailure.YData=exceptionMatrix(:,2);
                    obj.HFailure.XData=exceptionMatrix(:,1);

                else
                    obj.HFailure.XData=[];
                    obj.HFailure.YData=[];
                end
            end

        end


        function updateSolverResetCheckBoxPoints(obj,status)
            if(~status)



                obj.HReset.XData=[];
                obj.HReset.YData=[];


                if(~isempty(obj.HReset.UserData))
                    obj.refreshTable(obj.HReset);
                    obj.Data.setData('ResetTableRowSelected',[]);
                    obj.Data.setData('ResetTableColumnSelected',[]);
                end
            else

                resetMatrix=obj.Data.getTotalResetMatrix(0);
                if~isempty(resetMatrix)
                    obj.HReset.YData=resetMatrix(:,2);
                    obj.HReset.XData=resetMatrix(:,1);

                else
                    obj.HReset.XData=[];
                    obj.HReset.YData=[];
                end
            end

        end


        function updateJacobianCheckBoxPoints(obj,status)
            if(~status)


                obj.HJacobian.XData=[];
                obj.HJacobian.YData=[];





                if(~isempty(obj.HJacobian.UserData))
                    obj.refreshTable(obj.HJacobian);
                    obj.Data.setData('StatisticsTableRowSelected',[]);
                end
            else

                tout=obj.Data.getTout();
                hs=[tout(2)-tout(1);diff(tout)];
                jacobianTime=obj.Data.getJacobianUpdateTime();

                if~isempty(jacobianTime)
                    inds=ismembc(tout,jacobianTime);
                    obj.HJacobian.YData=hs(inds);
                    obj.HJacobian.XData=tout(inds);

                else
                    obj.HJacobian.XData=[];
                    obj.HJacobian.YData=[];
                end

            end
        end



        function plotSelectedZCEvents(obj)
            zcMatrix=obj.Data.getZCEventsFromSelectedBlock();
            if~isempty(zcMatrix)
                obj.HZC.YData=zcMatrix(:,2);
                obj.HZC.XData=zcMatrix(:,1);

            else
                obj.HZC.XData=[];
                obj.HZC.YData=[];
            end
        end


        function plotSelectedExeceptionEvents(obj)
            type=obj.Data.getData('ExceptionTableColumnSelected')-1;
            resetMatrix=obj.Data.getFailureMatrixForSelectedState(type);
            if~isempty(resetMatrix)
                obj.HFailure.YData=resetMatrix(:,2);
                obj.HFailure.XData=resetMatrix(:,1);

            else
                obj.HFailure.XData=[];
                obj.HFailure.YData=[];
            end
        end


        function plotSelectedResetEvents(obj)
            type=obj.Data.getData('ResetTableColumnSelected')-1;
            resetMatrix=obj.Data.getResetMatrixForSelectedSource(type);
            if~isempty(resetMatrix)
                obj.HReset.YData=resetMatrix(:,2);
                obj.HReset.XData=resetMatrix(:,1);

            else
                obj.HReset.XData=[];
                obj.HReset.YData=[];
            end
        end


        function plotSelectedStatisticsEvents(obj)
            import solverprofiler.internal.OverviewTableRowIndex


            rowSelected=obj.Data.getData('StatisticsTableRowSelected');
            if isempty(rowSelected)
                return;
            end


            if rowSelected==OverviewTableRowIndex.ZeroCrossing
                zcMatrix=obj.Data.getAllZCEvents();
                if~isempty(zcMatrix)
                    obj.HZC.YData=zcMatrix(:,2);
                    obj.HZC.XData=zcMatrix(:,1);

                else
                    obj.HZC.XData=[];
                    obj.HZC.YData=[];
                end
            end


            if rowSelected==OverviewTableRowIndex.JacobianUpdate
                jacobianTime=obj.Data.getJacobianUpdateTime();
                if~isempty(jacobianTime)
                    tout=obj.Data.getTout();
                    hs=[tout(2)-tout(1);diff(tout)];
                    inds=ismembc(tout,jacobianTime);
                    obj.HJacobian.YData=hs(inds);
                    obj.HJacobian.XData=tout(inds);

                else
                    obj.HJacobian.XData=[];
                    obj.HJacobian.YData=[];
                end
            end


            if(rowSelected>=OverviewTableRowIndex.TotalReset)&&...
                (rowSelected<=OverviewTableRowIndex.InternalReset)

                resetType=rem(rowSelected(1),OverviewTableRowIndex.TotalReset);
                resetMatrix=obj.Data.getTotalResetMatrix(resetType);

                if~isempty(resetMatrix)
                    obj.HReset.YData=resetMatrix(:,2);
                    obj.HReset.XData=resetMatrix(:,1);

                else
                    obj.HReset.XData=[];
                    obj.HReset.YData=[];
                end
            end


            if(rowSelected>=OverviewTableRowIndex.TotalException)&&...
                (rowSelected<=OverviewTableRowIndex.ExceptionByDAENewtonIteration)
                failureType=rem(rowSelected(1),OverviewTableRowIndex.TotalException);
                resetMatrix=obj.Data.getTotalFailureMatrix(failureType);

                if~isempty(resetMatrix)
                    obj.HFailure.YData=resetMatrix(:,2);
                    obj.HFailure.XData=resetMatrix(:,1);

                else
                    obj.HFailure.XData=[];
                    obj.HFailure.YData=[];
                end
            end
        end


        function removeAllEventDots(obj)
            obj.HFailure.XData=[];
            obj.HFailure.YData=[];
            obj.HReset.XData=[];
            obj.HReset.YData=[];
            obj.HJacobian.XData=[];
            obj.HJacobian.YData=[];
            obj.HZC.XData=[];
            obj.HZC.YData=[];
        end

    end
end
