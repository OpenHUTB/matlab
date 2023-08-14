function plotStepSizeTS(mode,SP)

    f=SP.SPDocument.getStepSizePlotHandle();
    if~isvalid(f)
        return;
    end


    if~(SP.SPData.isDataReady())
        return;
    end


    if strcmp(mode,'clean')

        h=findobj(f,'Tag','pointsZC');
        h.XData=[];h.YData=[];
        h=findobj(f,'Tag','pointsFailure');
        h.XData=[];h.YData=[];
        h=findobj(f,'Tag','pointsReset');
        h.XData=[];h.YData=[];
        h=findobj(f,'Tag','pointsJacobian');
        h.XData=[];h.YData=[];

        drawnow;


        table=SP.SPDocument.HZeroCrossing.Children;
        data=table.Data;table.Data=data;
        table=findobj(SP.SPDocument.HException.Children,'RowName','');
        data=table.Data;table.Data=data;
        table=SP.SPDocument.HReset.Children;
        data=table.Data;table.Data=data;
        table=SP.SPDocument.HJacobian.Children;
        data=table.Data;table.Data=data;


        SP.SPData.refreshZCTableSelection();
        SP.SPData.refreshFailureTableSelection();
        SP.SPData.refreshResetTableSelection();
        SP.SPData.refreshJacobianTableSelection();
    end


    if strcmp(mode,'new')



        if~isempty(f.Children)
            hold(f.CurrentAxes,'off');
            axis(f.CurrentAxes,'auto');
        end


        plothhmax(f,SP.SPData);


        h1=semilogy(f.CurrentAxes,1,1,'.','Color',[226,61,45]/255,...
        'markersize',17,'Tag','pointsFailure');
        h2=semilogy(f.CurrentAxes,1,1,'.','Color',[238,166,0]/255,...
        'markersize',17,'Tag','pointsZC');
        h3=semilogy(f.CurrentAxes,1,1,'.','markersize',17,...
        'Color',[0,153,21]/255,'Tag','pointsReset');
        h4=semilogy(f.CurrentAxes,1,1,'k.','markersize',17,...
        'Tag','pointsJacobian');

        h1.XData=[];h1.YData=[];
        h2.XData=[];h2.YData=[];
        h3.XData=[];h3.YData=[];
        h4.XData=[];h4.YData=[];
        drawnow;

        strZC=DAStudio.message('Simulink:solverProfiler:Zerocrossing');
        strException=DAStudio.message('Simulink:solverProfiler:Solverexception');
        strReset=DAStudio.message('Simulink:solverProfiler:Solverreset');
        strStep=DAStudio.message('Simulink:solverProfiler:Stepsize');
        strJacobian=DAStudio.message('Simulink:solverProfiler:Solverjacobian');

        mdl=SP.SPData.getData('Model');
        if strcmp(get_param(mdl,'SolverType'),'Fixed-step')
            legend(f.CurrentAxes,...
            {strStep,strException,strZC,strReset,strJacobian},...
            'Location','southeastoutside','PickableParts','none');
        else
            legend(f.CurrentAxes,...
            {strStep,['Max ',strStep],strException,strZC,strReset,strJacobian},...
            'Location','southeastoutside','PickableParts','none');
        end


        axis(f.CurrentAxes,'manual');


        strXLabel=DAStudio.message('Simulink:solverProfiler:plotXLabel');
        strYLabel=DAStudio.message('Simulink:solverProfiler:plotYLabel');
        xlabel(f.CurrentAxes,strXLabel,'FontSize',10);
        ylabel(f.CurrentAxes,strYLabel,'FontSize',10);









        plotZCFailedStepSize(f,SP.SPData,SP.SPToolstrip);
    end


    if strfind(mode,'Checkbox')%#ok<STRIFCND>
        figureUpdateByCheckbox(f,mode,SP.SPData,SP.SPToolstrip);
    end


    if strcmp(mode,'table')

        if SP.SPData.isZCTabSelected()
            table=SP.SPDocument.HZeroCrossing.Children;
        elseif SP.SPData.isExceptionTabSelected()
            table=findobj(SP.SPDocument.HException.Children,'RowName','');
        elseif SP.SPData.isResetTabSelected()
            table=SP.SPDocument.HReset.Children;
        elseif SP.SPData.isJacobianTabSelected()
            return;
        else
            table=findobj(SP.SPDocument.HStatistics.Children,'RowName','');
        end
        figureUpdateByTable(f,SP.SPData,table);

    end


    drawnow;

end





function plothhmax(f,SPData)
    mdl=SPData.getData('Model');
    isfixed=strcmp(get_param(mdl,'SolverType'),'Fixed-step');

    tout=SPData.getTout();
    hmax=SPData.getHmax();
    hs=[tout(2)-tout(1);diff(tout)];


    if isempty(f.CurrentAxes)
        figure(f);
        axes(f)
    end
    semilogy(f.CurrentAxes,tout,hs,'.-','Color',[35,0,230]/255,'Tag','h');
    hold(f.CurrentAxes,'on');

    if~isfixed
        semilogy(f.CurrentAxes,[tout(1);tout(end)],[hmax;hmax],'k--',...
        'LineWidth',2,'Tag','hmax');
    end

    set(f.CurrentAxes,'Color',[252,252,252]/255);


    if strcmp(get_param(mdl,'SolverType'),'Fixed-step')&&diff(f.CurrentAxes.YLim)<10000*eps
        f.CurrentAxes.YLim(1)=f.CurrentAxes.YLim(1)-10000*eps;
        f.CurrentAxes.YLim(2)=f.CurrentAxes.YLim(2)+10000*eps;
    end
end

function plotZCFailedStepSize(f,SPData,SPToolstrip)

    tout=SPData.getTout();
    hs=[tout(2)-tout(1);diff(tout)];


    if(SPToolstrip.isZCCheckboxSelected)
        zcMatrix=SPData.getAllZCEvents();
        h=findobj(f,'Tag','pointsZC');
        if~isempty(zcMatrix)
            h.YData=zcMatrix(:,2);
            h.XData=zcMatrix(:,1);
            uistack(h,'top');
        else
            h.XData=[];
            h.YData=[];
        end
    end


    if(SPToolstrip.isExceptionCheckboxSelected)
        exceptionMatrix=SPData.getTotalFailureMatrix(0);
        h=findobj(f,'Tag','pointsFailure');
        if~isempty(exceptionMatrix)
            h.YData=exceptionMatrix(:,2);
            h.XData=exceptionMatrix(:,1);
            uistack(h,'top');
        else
            h.XData=[];
            h.YData=[];
        end
    end


    if(SPToolstrip.isResetCheckboxSelected)
        resetMatrix=SPData.getTotalResetMatrix(0);
        h=findobj(f,'Tag','pointsReset');
        if~isempty(resetMatrix)
            h.YData=resetMatrix(:,2);
            h.XData=resetMatrix(:,1);
            uistack(h,'top');
        else
            h.XData=[];
            h.YData=[];
        end
    end


    if(SPToolstrip.isJacobianCheckboxSelected)
        jacobianTime=SPData.getJacobianUpdateTime();
        h=findobj(f,'Tag','pointsJacobian');
        if~isempty(jacobianTime)
            inds=ismembc(tout,jacobianTime);
            h.YData=hs(inds);
            h.XData=tout(inds);
            uistack(h,'top');
        else
            h.XData=[];
            h.YData=[];
        end
    end
end


function figureUpdateByCheckbox(f,Tag,SPData,SPToolstrip)

    tout=SPData.getTout();
    hs=[tout(2)-tout(1);diff(tout)];


    if strcmp(Tag,'zcCheckbox')

        h=findobj(f,'Tag','pointsZC');
        if(SPToolstrip.isZCCheckboxSelected)
            zcMatrix=SPData.getAllZCEvents();
            if~isempty(zcMatrix)
                h.YData=zcMatrix(:,2);
                h.XData=zcMatrix(:,1);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end

        else
            h.XData=[];
            h.YData=[];
        end
        if(~isempty(h.UserData))
            dataCache=h.UserData.Data;
            h.UserData.Data=dataCache;
            SPData.refreshZCTableSelection();
        end


    elseif strcmp(Tag,'failureCheckbox')

        h=findobj(f,'Tag','pointsFailure');
        if(SPToolstrip.isExceptionCheckboxSelected)
            exceptionMatrix=SPData.getTotalFailureMatrix(0);
            if~isempty(exceptionMatrix)
                h.YData=exceptionMatrix(:,2);
                h.XData=exceptionMatrix(:,1);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end

        else
            h.XData=[];
            h.YData=[];
        end

        if(~isempty(h.UserData))
            dataCache=h.UserData.Data;
            h.UserData.Data=dataCache;
            SPData.refreshFailureTableSelection();
        end


    elseif strcmp(Tag,'resetCheckbox')

        h=findobj(f,'Tag','pointsReset');
        if(SPToolstrip.isResetCheckboxSelected)
            resetMatrix=SPData.getTotalResetMatrix(0);
            if~isempty(resetMatrix)
                h.YData=resetMatrix(:,2);
                h.XData=resetMatrix(:,1);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end
        else
            h.XData=[];
            h.YData=[];
        end

        if(~isempty(h.UserData))
            dataCache=h.UserData.Data;
            h.UserData.Data=dataCache;
            SPData.refreshResetTableSelection();
        end

    elseif strcmp(Tag,'jacobianCheckbox')
        h=findobj(f,'Tag','pointsJacobian');
        if(SPToolstrip.isJacobianCheckboxSelected)
            jacobianTime=SPData.getJacobianUpdateTime();
            if~isempty(jacobianTime)
                inds=ismembc(tout,jacobianTime);
                h.YData=hs(inds);
                h.XData=tout(inds);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end
        else
            h.XData=[];
            h.YData=[];
        end
        if(~isempty(h.UserData))
            dataCache=h.UserData.Data;
            h.UserData.Data=dataCache;
            SPData.refreshJacobianTableSelection();
        end
    end

end

function figureUpdateByTable(f,SPData,table)

    import solverprofiler.internal.OverviewTableRowIndex


    if SPData.isZCTabSelected()

        h=findobj(f,'Tag','pointsZC');
        zcMatrix=SPData.getZCEventsFromSelectedBlock();
        if~isempty(zcMatrix)
            h.YData=zcMatrix(:,2);
            h.XData=zcMatrix(:,1);
            uistack(h,'top');
        else
            h.XData=[];
            h.YData=[];
        end
        if(~isempty(h.UserData)&&h.UserData~=table)
            dataCache=h.UserData.Data;
            h.UserData.Data=dataCache;
        end
        h.UserData=table;


    elseif SPData.isExceptionTabSelected()

        h=findobj(f,'Tag','pointsFailure');
        type=SPData.getData('ExceptionTableColumnSelected')-1;
        resetMatrix=SPData.getFailureMatrixForSelectedState(type);
        if~isempty(resetMatrix)
            h.YData=resetMatrix(:,2);
            h.XData=resetMatrix(:,1);
            uistack(h,'top');
        else
            h.XData=[];
            h.YData=[];
        end
        if(~isempty(h.UserData)&&h.UserData~=table)
            dataCache=h.UserData.Data;
            h.UserData.Data=dataCache;
        end
        h.UserData=table;


    elseif SPData.isResetTabSelected()

        h=findobj(f,'Tag','pointsReset');
        type=SPData.getData('ResetTableColumnSelected')-1;
        resetMatrix=SPData.getResetMatrixForSelectedSource(type);
        if~isempty(resetMatrix)
            h.YData=resetMatrix(:,2);
            h.XData=resetMatrix(:,1);
            uistack(h,'top');
        else
            h.XData=[];
            h.YData=[];
        end
        if(~isempty(h.UserData)&&h.UserData~=table)
            dataCache=h.UserData.Data;
            h.UserData.Data=dataCache;
        end
        h.UserData=table;

    else

        rowSelected=SPData.getData('StatisticsTableRowSelected');
        if isempty(rowSelected)
            return;
        end


        if rowSelected==OverviewTableRowIndex.ZeroCrossing
            h=findobj(f,'Tag','pointsZC');
            zcMatrix=SPData.getAllZCEvents();
            if~isempty(zcMatrix)
                h.YData=zcMatrix(:,2);
                h.XData=zcMatrix(:,1);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end
            if(~isempty(h.UserData)&&h.UserData~=table)
                dataCache=h.UserData.Data;
                h.UserData.Data=dataCache;
                SPData.refreshZCTableSelection();
            end
            h.UserData=table;
        end

        if rowSelected==OverviewTableRowIndex.JacobianUpdate
            h=findobj(f,'Tag','pointsJacobian');
            jacobianTime=SPData.getJacobianUpdateTime();
            if~isempty(jacobianTime)
                tout=SPData.getTout();
                hs=[tout(2)-tout(1);diff(tout)];
                inds=ismembc(tout,jacobianTime);
                h.YData=hs(inds);
                h.XData=tout(inds);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end
            if(~isempty(h.UserData)&&h.UserData~=table)
                dataCache=h.UserData.Data;
                h.UserData.Data=dataCache;
                SPData.refreshJacobianTableSelection();
            end

            h.UserData=table;
        end


        if(rowSelected>=OverviewTableRowIndex.TotalReset)&&...
            (rowSelected<=OverviewTableRowIndex.InternalReset)

            h=findobj(f,'Tag','pointsReset');
            resetType=rem(rowSelected(1),OverviewTableRowIndex.TotalReset);
            resetMatrix=SPData.getTotalResetMatrix(resetType);

            if~isempty(resetMatrix)
                h.YData=resetMatrix(:,2);
                h.XData=resetMatrix(:,1);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end
            if(~isempty(h.UserData)&&h.UserData~=table)
                dataCache=h.UserData.Data;
                h.UserData.Data=dataCache;
                SPData.refreshResetTableSelection();
            end
            h.UserData=table;
        end


        if(rowSelected>=OverviewTableRowIndex.TotalException)&&...
            (rowSelected<=OverviewTableRowIndex.ExceptionByDAENewtonIteration)

            h=findobj(f,'Tag','pointsFailure');
            failureType=rem(rowSelected(1),OverviewTableRowIndex.TotalException);
            resetMatrix=SPData.getTotalFailureMatrix(failureType);

            if~isempty(resetMatrix)
                h.YData=resetMatrix(:,2);
                h.XData=resetMatrix(:,1);
                uistack(h,'top');
            else
                h.XData=[];
                h.YData=[];
            end
            if(~isempty(h.UserData)&&h.UserData~=table)
                dataCache=h.UserData.Data;
                h.UserData.Data=dataCache;
                SPData.refreshFailureTableSelection();
            end
            h.UserData=table;

        end

    end

end



