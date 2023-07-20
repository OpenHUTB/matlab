classdef(Hidden)MarkerViewer<globe.internal.VisualizationViewer





















    properties(Constant,Hidden)
        SquareIcon='/toolbox/shared/globe/globeviewer/release/globeviewer/images/square.svg'
        TriangleIcon='/toolbox/shared/globe/globeviewer/release/globeviewer/images/triangle.svg'
        DiamondIcon='/toolbox/shared/globe/globeviewer/release/globeviewer/images/diamond.svg'
    end


    methods
        function viewer=MarkerViewer(globeController)









            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;
        end


        function IDs=marker(viewer,location,icon,varargin)
            [IDs,plotDescriptors]=viewer.buildPlotDescriptors(location,icon,varargin{:});
            viewer.PrimitiveController.plot('marker',plotDescriptors);
        end

        function[IDs,plotDescriptors]=buildPlotDescriptors(viewer,location,icon,varargin)

            primitiveController=viewer.PrimitiveController;


            p=inputParser;
            p.addParameter('Animation','');
            p.addParameter('EnableWindowLaunch',true);
            p.addParameter('ClusterMarkers',false);
            p.addParameter('IconSize',[36,36]);
            p.addParameter('IconAlignment','top');
            p.addParameter('Color',{[1,1,1]});
            p.addParameter('Name',{'Marker'});
            p.addParameter('ShowStem',false);
            p.addParameter('Description',{''});
            p.addParameter('GroundElevation',0);
            p.addParameter('Visible',true);
            p.addParameter('ValidateIcon',true);
            p.addParameter('WaitForResponse',true);
            p.addParameter('ID',primitiveController.getId(size(location,1)));
            try
                p.parse(varargin{:});
            catch e
                throwAsCaller(e);
            end


            if(~iscell(location))
                location=num2cell(location,2);
            end
            clusterMarkers=p.Results.ClusterMarkers;
            iconSize=p.Results.IconSize;
            iconAlignment=p.Results.IconAlignment;
            color=p.Results.Color;
            name=p.Results.Name;
            showStem=p.Results.ShowStem;
            animation=p.Results.Animation;
            IDs=p.Results.ID;
            enableWindowLaunch=p.Results.EnableWindowLaunch;
            description=cellstr(p.Results.Description);
            groundElevations=p.Results.GroundElevation;
            visible=p.Results.Visible;
            validateIcon=p.Results.ValidateIcon;
            waitForResponse=p.Results.WaitForResponse;



            if(validateIcon)
                [icon,usingOnlyPreset]=validateIconPreset(icon);


                validateIcon=~usingOnlyPreset;
            end



            if(~iscell(IDs))
                IDs=num2cell(IDs);
            end

            if(~iscell(iconSize))
                iconSize=num2cell(iconSize,2);
            end
            if(~iscell(iconAlignment))
                iconAlignment=cellstr(iconAlignment);
            end
            if(~iscell(clusterMarkers))
                clusterMarkers=num2cell(clusterMarkers);
            end


            if(~iscell(color)&&size(color,1)==1)
                color={color};
            end

            if(validateIcon)
                iconUrls=cell(numel(icon),1);
                for h=1:numel(icon)
                    if~isempty(which(icon{h}))
                        iconUrls{h}=globe.internal.ConnectorServiceProvider.getResourceURL(...
                        which(icon{h}),['marker',num2str(IDs{h})]);
                    elseif(exist(icon{h},'file')==2)
                        iconUrls{h}=globe.internal.ConnectorServiceProvider.getResourceURL(...
                        icon{h},['marker',num2str(IDs{h})]);
                    else
                        iconUrls{h}=icon{h};
                    end
                end
            else
                iconUrls=icon;
            end


            plotDescriptors=struct(...
            'IDs',{IDs},...
            'Names',{name},...
            'Location',{location},...
            'GroundElevations',{num2cell(groundElevations)},...
            'Description',{description},...
            'Icons',{iconUrls},...
            'IconSize',{iconSize},...
            'IconAlignment',{iconAlignment},...
            'Color',{color},...
            'Animation',animation,...
            'EnableWindowLaunch',enableWindowLaunch,...
            'ShowStem',showStem,...
            'Visible',visible,...
            'WaitForResponse',waitForResponse,...
            'ClusterMarkers',{clusterMarkers});

            function[icons,usingOnlyPreset]=validateIconPreset(icon)

                if(iscell(icon))
                    icons=icon;
                else
                    icons=cellstr(icon);
                end
                usingOnlyPreset=true;
                for i=1:numel(icons)
                    switch icons{i}
                    case{"s","square"}
                        icons{i}=globe.internal.MarkerViewer.SquareIcon;
                    case "^"
                        icons{i}=globe.internal.MarkerViewer.TriangleIcon;
                    case{"d","diamond"}
                        icons{i}=globe.internal.MarkerViewer.DiamondIcon;
                    otherwise
                        usingOnlyPreset=false;
                    end
                end
            end
        end

        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end