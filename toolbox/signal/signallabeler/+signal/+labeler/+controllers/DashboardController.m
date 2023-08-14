classdef DashboardController<handle






    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='DashboardController';
    end

    events
PreShowComplete
PlotSelectionChangeComplete
AddPlotsComplete
UpdatePlotComplete
UpdatePlotsOnMemberSelectionChangedComplete
DeletePlotsComplete
OnLabelDefinitionsUncheckedComplete
DashboardCloseComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.DashboardDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.DashboardController(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=DashboardController(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.DashboardController;


            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','preshowdashboard'],...
            @(arg)cb_PreshowDashboard(this,arg));

            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','addplots'],...
            @(arg)cb_AddPlots(this,arg));

            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','updateplot'],...
            @(arg)cb_UpdatePlot(this,arg));

            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','updateplotsonmemberschange'],...
            @(arg)cb_UpdatePlotsOnMemberSelectionChanged(this,arg));

            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','deleteplots'],...
            @(arg)cb_DeletePlots(this,arg));

            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','plotselectionchanged'],...
            @(arg)cb_OnPlotSelectionChanged(this,arg));

            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','labeldefinitionsunchecked'],...
            @(arg)cb_OnLabelDefinitionsUnchecked(this,arg));

            this.Dispatcher.subscribe(...
            [DashboardController.ControllerID,'/','dashboardmodeclosed'],...
            @(arg)cb_OnDashboardModeClosed(this,arg));

        end
    end

    methods(Hidden)



        function cb_PreshowDashboard(this,args)




            lblDefInfo=this.Model.getLabelDefinitionsDataForDropDown();

            dataPacket.LabelDefinitionInfo=lblDefInfo;


            this.notify('PreShowComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','preShowComplete',...
            'data',dataPacket)));
        end

        function cb_OnPlotSelectionChanged(this,args)

            data=args.data;
            plotID=data.PlotID;

            [plotParams,labelDefinitionID,listOfActivePlotNamesForLabelDefID]=this.Model.getPlotParams(plotID);
            if(~isempty(plotParams))
                dataPacket.PlotParams=plotParams;
                dataPacket.LabelDefinitionID=labelDefinitionID;
                dataPacket.PlotID=plotID;




                dataPacket.ListOfActivePlotNamesForLabelDefID=listOfActivePlotNamesForLabelDefID;


                this.notify('PlotSelectionChangeComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','plotSelectionChangeComplete',...
                'data',dataPacket)));
            end
        end

        function cb_AddPlots(this,args)

            data=args.data;



            lblDefIDs=string(data.LabelDefinitionIDs);
            plotTypes=string(data.PlotTypes);

            numPlots=numel(lblDefIDs);
            dataPacket=repmat(struct(...
            'PlotParams',[],...
            'PlotData',[],...
            'PlotID',[],...
            'PlotType',[],...
            'LabelDefinitionID',[]),numPlots,1);

            for idx=1:numPlots
                lblDefID=lblDefIDs(idx);
                plotType=plotTypes(idx);

                [plotID,p]=this.Model.addPlot(lblDefID,plotType);
                plotParams=this.Model.getPlotParams(plotID);
                if~isempty(plotParams)
                    dataPacket(idx).PlotParams=plotParams;
                    dataPacket(idx).PlotData=p;
                    dataPacket(idx).PlotID=plotID;
                    dataPacket(idx).PlotType=plotType;
                    dataPacket(idx).LabelDefinitionID=lblDefID;
                else
                    dataPacket(idx).PlotParams=struct.empty;
                    dataPacket(idx).PlotData=struct.empty;
                    dataPacket(idx).PlotID=string.empty;
                    dataPacket(idx).PlotType=string.empty;
                    dataPacket(idx).LabelDefinitionID=string.empty;
                end
            end


            this.notify('AddPlotsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','addPlotsComplete',...
            'data',dataPacket)));
        end

        function cb_UpdatePlot(this,args)

            data=args.data;

            plotID=data.PlotID;
            plotParams=data.PlotParams;

            p=this.Model.updatePlot(plotID,plotParams);

            lblDefID=this.Model.getLabelDefinitionForPlotID(plotID);

            dataPacket.PlotData=p;
            dataPacket.PlotID=plotID;
            dataPacket.LabelDefinitionID=lblDefID;
            dataPacket.PlotParams=plotParams;


            this.notify('UpdatePlotComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','updatePlotComplete',...
            'data',dataPacket)));
        end

        function cb_UpdatePlotsOnMemberSelectionChanged(this,args)


            data=args.data;
            plotIDs=data.PlotIDs;
            numPlots=numel(plotIDs);

            dataPacketCell=cell(numPlots,1);
            for idx=1:numPlots
                dataPacket=struct;
                plotID=plotIDs(idx);
                p=this.Model.updatePlot(plotID,[]);

                lblDefID=this.Model.getLabelDefinitionForPlotID(plotID);

                dataPacket.PlotData=p;
                dataPacket.PlotId=plotID;
                dataPacket.LabelDefinitionID=lblDefID;

                dataPacketCell{idx}=dataPacket;
            end


            this.notify('UpdatePlotsOnMemberSelectionChangedComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','updatePlotsOnMemberSelectionChangedComplete',...
            'data',dataPacketCell)));
        end

        function cb_DeletePlots(this,args)

            allPlotIDs=this.Model.getAllDashboardPlotIDs();
            data=args.data;
            plotIDs=string(data.PlotIDs);

            numPlots=numel(plotIDs);
            dataPacket.LabelDefinitionIDs=strings(numPlots,1);

            for idx=1:numPlots
                plotID=plotIDs(idx);
                if(ismember(plotID,allPlotIDs))
                    lblDefID=this.Model.getLabelDefinitionForPlotID(plotID);

                    this.Model.deletePlot(plotID);
                    dataPacket.LabelDefinitionIDs(idx)=lblDefID;
                end
            end
            dataPacket.DeletedPlotIDs=plotIDs;

            this.notify('DeletePlotsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','deletePlotsComplete',...
            'data',dataPacket)));
        end

        function cb_OnLabelDefinitionsUnchecked(this,args)
            data=args.data;
            lblDefIDs=string(data.LabelDefinitionIDs);

            deletedPlotIDs=[];

            for idx=1:numel(lblDefIDs)
                lblDefID=lblDefIDs(idx);
                newDeletedPlotIDs=this.Model.deletePlotsForLabelDefinitionID(lblDefID);
                deletedPlotIDs=[deletedPlotIDs;newDeletedPlotIDs];%#ok<AGROW>
            end

            dataPacket.DeletedPlotIDs=deletedPlotIDs;
            dataPacket.LabelDefinitionIDs=lblDefIDs;

            this.notify('OnLabelDefinitionsUncheckedComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','onLabelDefinitionsUncheckedComplete',...
            'data',dataPacket)));
        end

        function cb_OnDashboardModeClosed(this,args)
            this.Model.resetModel();

            this.notify('DashboardCloseComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','dashboardCloseComplete',...
            'data',[])));
        end
    end
end