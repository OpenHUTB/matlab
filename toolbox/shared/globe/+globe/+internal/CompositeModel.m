classdef CompositeModel<handle


















    properties
PlotTypes
PlotDescriptors
IDs
    end
    methods
        function model=CompositeModel()
            model.PlotTypes={};
            model.PlotDescriptors={};
            model.IDs={};
        end

        function model=addGraphic(model,graphic,plotDescriptors)
            model.PlotTypes{end+1}=graphic;



            plotDescriptors.WaitForResponse=false;
            plotDescriptors.Animation='none';
            model.PlotDescriptors{end+1}=plotDescriptors;
        end

        function data=buildPlotDescriptors(model,waitForResponse)

            numPlotTypes=numel(model.PlotTypes);
            data=struct("PlotTypes",{cell(numPlotTypes,1)},"PlotDescriptors",{cell(numPlotTypes,1)});
            for i=1:numPlotTypes
                data.PlotTypes{i}=model.PlotTypes{i};
                data.PlotDescriptors{i}=model.PlotDescriptors{i};
            end
            data.IDs=model.IDs;




            data.EnableWindowLaunch=true;
            data.Animation='fly';
            if(nargin<2)
                waitForResponse=true;
            end
            data.WaitForResponse=waitForResponse;
        end

        function clearModel(model)
            model.PlotTypes={};
            model.PlotDescriptors={};
            model.IDs={};
        end
    end
end