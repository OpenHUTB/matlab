classdef ArrayGalleryController<handle





    properties(Access=private)
pToolStrip
pApp
pParams
    end

    methods(Access=public)

        function obj=ArrayGalleryController(varargin)
            obj.pApp=varargin{1};
            obj.pToolStrip=varargin{1}.ToolStripDisplay;
            obj.pParams=varargin{1}.ParametersPanel;
        end

        function execute(obj,src,~)

            setAppStatus(obj.pApp,true);


            obj.pApp.ElementIndex=[];
            obj.pApp.SubarrayElementWeights=[];


            selectArrayItem(obj.pToolStrip,src.Tag);

            if~isempty(obj.pParams.ArrayDialog)
                obj.pParams.ArrayType='';
            end

            obj.pParams.ArrayType=src.Tag;


            if~obj.pApp.IsSubarray
                updateArrayObject(obj.pParams.ArrayDialog)
            else


                setDefaultParams(obj.pParams.AdditionalConfigDialog)
                updateArrayObject(obj.pParams.AdditionalConfigDialog)



                obj.pApp.ElementWeights=1;
                obj.pApp.ToolStripDisplay.SubarrayCustomWeightEdit.Value=mat2str(obj.pApp.ElementWeights);
                computeElementWeights(obj.pApp,obj.pApp.ElementWeights);
                updateSubarraySteering(obj.pApp);

                if strcmp(obj.pParams.AdditionalConfigDialog.SubarrayType,getString(message('phased:apps:arrayapp:partitionarray')))
                    if~isempty(obj.pApp.SubarrayLabels)
                        clear(obj.pApp.SubarrayLabels);
                    end
                    Labelposition=[0,0,obj.pApp.SubarrayPartitionFig.Position(3:4)];
                    obj.pApp.StoreData=[];
                    obj.pApp.StoreNames=[];
                    obj.pApp.SubarrayLabels=phased.apps.internal.interaction.SubarrayLabels(obj.pApp,Labelposition);
                end
            end


            adjustLayout(obj.pApp)



            disablAndEnableGratingLobe(obj.pApp)


            updateArrayCharTable(obj.pApp)


            updateOpenPlots(obj.pApp);


            obj.pToolStrip.PlotButtons{1}.Value=true;
            notify(obj.pToolStrip,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'arrayGeoFig'));

            obj.pApp.IsChanged=true;
            setAppTitle(obj.pApp,obj.pApp.DefaultSessionName)

            setAppStatus(obj.pApp,false);
        end
    end
end