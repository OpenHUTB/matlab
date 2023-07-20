classdef SubarraySelectionController<handle






    properties(Access=private)
pToolStrip
pApp
pParams
Layout
IsSubarray
    end

    methods(Access=public)

        function obj=SubarraySelectionController(varargin)
            obj.pApp=varargin{1};
            obj.pToolStrip=varargin{1}.ToolStripDisplay;
            obj.pParams=varargin{1}.ParametersPanel;
            obj.IsSubarray=obj.pApp.IsSubarray;
        end

        function execute(obj,src,~)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;

            setAppStatus(obj.pApp,true);


            if obj.IsSubarray
                if isempty(obj.pParams.AdditionalConfigDialog)
                    obj.pParams.AdditionalConfigDialog=phased.apps.internal.arrayDialogs.SubarrayConfigurationDialog(obj.pParams);
                else
                    delete(obj.pParams.AdditionalConfigDialog.Panel);
                    obj.pParams.AdditionalConfigDialog=phased.apps.internal.arrayDialogs.SubarrayConfigurationDialog(obj.pParams);
                end
                if strcmp(src.Text,getString(message('phased:apps:arrayapp:replicatesubarray')))

                    obj.pParams.AdditionalConfigDialog.Panel.Title=...
                    getString(message('phased:apps:arrayapp:replicatepaneltitle'));
                    obj.pParams.AdditionalConfigDialog.SubarrayType=...
                    getString(message('phased:apps:arrayapp:replicatesubarray'));
                else

                    obj.pParams.AdditionalConfigDialog.Panel.Title=...
                    getString(message('phased:apps:arrayapp:partitionpaneltitle'));
                    obj.pParams.AdditionalConfigDialog.SubarrayType=...
                    getString(message('phased:apps:arrayapp:partitionarray'));
                end
            end


            layoutUIControls(obj.pParams.AdditionalConfigDialog)
            setDefaultParams(obj.pParams.AdditionalConfigDialog)


            adjustLayout(obj.pApp)


            validArrayParams=verifyParameters(obj.pParams.ArrayDialog);

            if obj.IsSubarray
                if strcmp(src.Text,getString(message('phased:apps:arrayapp:partitionarray')))
                    cond=(isempty(obj.pApp.SubarrayPartitionFig)||isstruct(obj.pApp.SubarrayPartitionFig)...
                    ||~isvalid(obj.pApp.SubarrayPartitionFig));
                    if strcmp(obj.pApp.Container,'ToolGroup')
                        if cond
                            obj.pApp.SubarrayPartitionFig=figure('NumberTitle','off',...
                            'Visible','off',...
                            'HandleVisibility','off','IntegerHandle','off',...
                            'Name',getString(message('phased:apps:arrayapp:subarraypanelname')),...
                            'Tag','subarrayparamsfig',...
                            'SizeChangedFcn',@(~,~)resize(obj.pApp.SubarrayLabels,obj.pApp.SubarrayPartitionFig.Position));
                        end
                    else
                        if cond
                            subarrayFigOptions.Title=getString(message('phased:apps:arrayapp:subarraypanelname'));
                            subarrayFigOptions.Tag='subarrayparamsfig';
                            obj.pApp.DefineSubarrayDoc=FigureDocument(subarrayFigOptions);
                            obj.pApp.DefineSubarrayDoc.DocumentGroupTag='parameterSettings';
                            obj.pApp.SubarrayPartitionFig=obj.pApp.DefineSubarrayDoc.Figure;
                            obj.pApp.SubarrayPartitionFig.Internal=false;
                            obj.pApp.DefineSubarrayDoc.Closable=false;
                            obj.pApp.SubarrayPartitionFig.AutoResizeChildren="off";
                            obj.pApp.ToolGroup.add(obj.pApp.DefineSubarrayDoc);
                        else
                            obj.pApp.SubarrayPartitionFig=obj.pApp.DefineSubarrayDoc.Figure;
                        end
                    end
                end
                if~isempty(obj.pApp.SubarrayLabels)
                    clear(obj.pApp.SubarrayLabels);
                    obj.pApp.ElementIndex=[];
                    obj.pApp.SubarrayElementWeights=[];
                end
            end
            if validArrayParams

                if obj.IsSubarray
                    updateArrayObject(obj.pParams.AdditionalConfigDialog);



                    obj.pApp.ElementWeights=1;
                    obj.pApp.ToolStripDisplay.SubarrayCustomWeightEdit.Value=mat2str(obj.pApp.ElementWeights);
                    computeElementWeights(obj.pApp,obj.pApp.ElementWeights);
                    updateSubarraySteering(obj.pApp);
                    enableSubarraySteeringOptions(obj.pApp);
                else
                    updateArrayObject(obj.pParams.ArrayDialog);
                    disableSubarraySteeringOptions(obj.pApp);
                end



                disablAndEnableGratingLobe(obj.pApp)


                updateArrayCharTable(obj.pApp)


                updateOpenPlots(obj.pApp);


                obj.pToolStrip.PlotButtons{1}.Value=true;
                notify(obj.pToolStrip,'NewPlotRequest',...
                phased.apps.internal.controller.NewPlotEventData(...
                'arrayGeoFig'));


                if(isa(obj.pApp.CurrentArray,'phased.PartitionedArray')&&~obj.pApp.pFromSimulink)
                    removeAllMessages(obj.pApp.BannerMessage);
                    setMessage(obj.pApp.BannerMessage,'text',...
                    getString(message('phased:apps:arrayapp:bannermsg')),...
                    'phased:apps:arrayapp:bannermsg');
                else
                    removeAllMessages(obj.pApp.BannerMessage);
                end

                obj.pApp.IsChanged=true;
                setAppTitle(obj.pApp,obj.pApp.DefaultSessionName)
            end
            if strcmp(obj.pApp.Container,'ToolGroup')
                if obj.IsSubarray&&strcmp(src.Text,getString(message('phased:apps:arrayapp:partitionarray')))
                    obj.pApp.ToolGroup.addFigure(obj.pApp.SubarrayPartitionFig);


                    drawnow;
                    matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                    prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
                    state=java.lang.Boolean.FALSE;
                    matDsk.getClient(obj.pApp.SubarrayPartitionFig.Name,obj.pApp.ToolGroup.Name).putClientProperty(prop,state);
                    drawnow;
                    Labelposition=[0,0,obj.pApp.SubarrayPartitionFig.Position(3:4)];
                    obj.pApp.SubarrayLabels=phased.apps.internal.interaction.SubarrayLabels(obj.pApp,Labelposition);
                else
                    if(~isempty(obj.pApp.SubarrayPartitionFig)&&isvalid(obj.pApp.SubarrayPartitionFig))
                        close(obj.pApp.SubarrayPartitionFig);
                    end
                    brush(obj.pApp.ArrayGeometryFig,'off')
                end
            else
                if obj.IsSubarray&&strcmp(src.Text,getString(message('phased:apps:arrayapp:partitionarray')))
                    Labelposition=[0,0,obj.pApp.SubarrayPartitionFig.Position(3:4)];
                    obj.pApp.SubarrayLabels=phased.apps.internal.interaction.SubarrayLabels(obj.pApp,Labelposition);
                    obj.pApp.SubarrayPartitionFig.SizeChangedFcn=@(x,y)resize(obj.pApp.SubarrayLabels,obj.pApp.SubarrayPartitionFig.Position);
                else
                    if(~isempty(obj.pApp.SubarrayPartitionFig)&&isvalid(obj.pApp.SubarrayPartitionFig))
                        closeDocument(obj.pApp.ToolGroup,"parameterSettings","subarrayparamsfig");
                    end
                    brush(obj.pApp.ArrayGeometryFig,'off')
                end
            end

            obj.pParams.ArrayDialog.Panel.Title=...
            assignArrayDialogTitle(obj.pParams.ArrayDialog);

            generateAndApplyLayout(obj.pApp,obj.pApp.pFromSimulink);

            setAppStatus(obj.pApp,false);
        end
    end
end