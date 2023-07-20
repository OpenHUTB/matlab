classdef(Abstract)BaseAccessor<handle




    properties

ReferenceObject



        SupportedFeatures;
    end


    methods
        function obj=BaseAccessor()
            obj.buildSupportedFeatures();
        end

        function obj=get.ReferenceObject(this)
            obj=this.ReferenceObject;
        end

        function set.ReferenceObject(this,value)
            this.ReferenceObject=value;
        end
    end

    methods(Access='private')
        function buildSupportedFeatures(obj)
            obj.SupportedFeatures=struct;

            obj.SupportedFeatures.Title=struct;
            obj.SupportedFeatures.Title.isSupported=@()obj.supportsTitle();
            obj.SupportedFeatures.Title.get=@()obj.getTitle();
            obj.SupportedFeatures.Title.set=@(value)obj.setTitle(value);

            obj.SupportedFeatures.XLabel=struct;
            obj.SupportedFeatures.XLabel.isSupported=@()obj.supportsXLabel();
            obj.SupportedFeatures.XLabel.get=@()obj.getXLabel();
            obj.SupportedFeatures.XLabel.set=@(value)obj.setXLabel(value);

            obj.SupportedFeatures.YLabel=struct;
            obj.SupportedFeatures.YLabel.isSupported=@()obj.supportsYLabel();
            obj.SupportedFeatures.YLabel.get=@()obj.getYLabel();
            obj.SupportedFeatures.YLabel.set=@(value)obj.setYLabel(value);

            obj.SupportedFeatures.ZLabel=struct;
            obj.SupportedFeatures.ZLabel.isSupported=@()obj.supportsZLabel();
            obj.SupportedFeatures.ZLabel.get=@()obj.getZLabel();
            obj.SupportedFeatures.ZLabel.set=@(value)obj.setZLabel(value);

            obj.SupportedFeatures.Grid=struct;
            obj.SupportedFeatures.Grid.isSupported=@()obj.supportsGrid();
            obj.SupportedFeatures.Grid.get=@()obj.getGrid();
            obj.SupportedFeatures.Grid.set=@(value)obj.setGrid(value);

            obj.SupportedFeatures.XGrid=struct;
            obj.SupportedFeatures.XGrid.isSupported=@()obj.supportsXGrid();
            obj.SupportedFeatures.XGrid.get=@()obj.getXGrid();
            obj.SupportedFeatures.XGrid.set=@(value)obj.setXGrid(value);

            obj.SupportedFeatures.YGrid=struct;
            obj.SupportedFeatures.YGrid.isSupported=@()obj.supportsYGrid();
            obj.SupportedFeatures.YGrid.get=@()obj.getYGrid();
            obj.SupportedFeatures.YGrid.set=@(value)obj.setYGrid(value);

            obj.SupportedFeatures.ZGrid=struct;
            obj.SupportedFeatures.ZGrid.isSupported=@()obj.supportsZGrid();
            obj.SupportedFeatures.ZGrid.get=@()obj.getZGrid();
            obj.SupportedFeatures.ZGrid.set=@(value)obj.setZGrid(value);

            obj.SupportedFeatures.RGrid=struct;
            obj.SupportedFeatures.RGrid.isSupported=@()obj.supportsRGrid();
            obj.SupportedFeatures.RGrid.get=@()obj.getRGrid();
            obj.SupportedFeatures.RGrid.set=@(value)obj.setRGrid(value);

            obj.SupportedFeatures.ThetaGrid=struct;
            obj.SupportedFeatures.ThetaGrid.isSupported=@()obj.supportsThetaGrid();
            obj.SupportedFeatures.ThetaGrid.get=@()obj.getThetaGrid();
            obj.SupportedFeatures.ThetaGrid.set=@(value)obj.setThetaGrid(value);

            obj.SupportedFeatures.Legend=struct;
            obj.SupportedFeatures.Legend.isSupported=@()obj.supportsLegend();
            obj.SupportedFeatures.Legend.get=@()obj.getLegend();
            obj.SupportedFeatures.Legend.set=@(value)obj.setLegend(value);

            obj.SupportedFeatures.Colorbar=struct;
            obj.SupportedFeatures.Colorbar.isSupported=@()obj.supportsColorbar();
            obj.SupportedFeatures.Colorbar.get=@()obj.getColorbar();
            obj.SupportedFeatures.Colorbar.set=@(value)obj.setColorbar(value);

            obj.SupportedFeatures.BasicFitting=struct;
            obj.SupportedFeatures.BasicFitting.isSupported=@()obj.supportsBasicFitting();
            obj.SupportedFeatures.BasicFitting.get=@()obj.getBasicFitting();
            obj.SupportedFeatures.BasicFitting.set=@(value)obj.setBasicFitting(value);

            obj.SupportedFeatures.DataStats=struct;
            obj.SupportedFeatures.DataStats.isSupported=@()obj.supportsDataStats();
            obj.SupportedFeatures.DataStats.get=@()obj.getDataStats();
            obj.SupportedFeatures.DataStats.set=@(value)obj.setDataStats(value);

            obj.SupportedFeatures.DataLinking=struct;
            obj.SupportedFeatures.DataLinking.isSupported=@()obj.supportsDataLinking();
            obj.SupportedFeatures.DataLinking.get=@()obj.getDataLinking();
            obj.SupportedFeatures.DataLinking.set=@(value)obj.setDataLinking(value);

            obj.SupportedFeatures.CameraTools=struct;
            obj.SupportedFeatures.CameraTools.isSupported=@()obj.supportsCameraTools();
            obj.SupportedFeatures.CameraTools.get=@()obj.getCameraTools();
            obj.SupportedFeatures.CameraTools.set=@(value)obj.setCameraTools(value);
        end
    end

    methods(Abstract)
        id=getIdentifier(obj);
    end

    methods(Access='public')

        function result=applyReferenceObject(~,refObj)
            result=refObj;
        end

        function result=getSupportedFeatures(obj)
            result=struct;

            fields=fieldnames(obj.SupportedFeatures);

            for i=1:numel(fields)
                field=fields{i};

                result.(field)=obj.isSupported(field);
            end
        end

        function result=isSupported(obj,feature)
            result=true;

            if isfield(obj.SupportedFeatures,feature)
                featureStruct=obj.SupportedFeatures.(feature);
                result=logical(featureStruct.isSupported());
            end
        end

        function result=get(obj,feature)
            result=[];

            if obj.isSupported(feature)
                featureStruct=obj.SupportedFeatures.(feature);
                result=featureStruct.get();
            end
        end

        function set(obj,feature,value)
            if obj.isSupported(feature)
                featureStruct=obj.SupportedFeatures.(feature);
                featureStruct.set(value);
            end
        end
    end




    methods(Access='protected')
        function result=supportsTitle(~)
            result=false;
        end

        function result=supportsXLabel(~)
            result=false;
        end

        function result=supportsYLabel(~)
            result=false;
        end

        function result=supportsZLabel(~)
            result=false;
        end

        function result=supportsGrid(~)
            result=false;
        end

        function result=supportsXGrid(~)
            result=false;
        end

        function result=supportsYGrid(~)
            result=false;
        end

        function result=supportsZGrid(~)
            result=false;
        end

        function result=supportsRGrid(~)
            result=false;
        end

        function result=supportsThetaGrid(~)
            result=false;
        end

        function result=supportsLegend(~)
            result=false;
        end

        function result=supportsColorbar(~)
            result=false;
        end

        function result=supportsBasicFitting(~)
            result=false;
        end

        function result=supportsDataStats(~)
            result=false;
        end

        function result=supportsDataLinking(~)
            result=false;
        end

        function result=supportsCameraTools(~)
            result=false;
        end
    end


    methods(Access='protected')

        function result=getTitle(~)
            result='';
        end

        function result=getXLabel(~)
            result='';
        end

        function result=getYLabel(~)
            result='';
        end

        function result=getZLabel(~)
            result='';
        end

        function result=getGrid(~)
            result='';
        end

        function result=getXGrid(~)
            result='';
        end

        function result=getYGrid(~)
            result='';
        end

        function result=getZGrid(~)
            result='';
        end

        function result=getRGrid(~)
            result='';
        end

        function result=getThetaGrid(~)
            result='';
        end

        function result=getLegend(~)
            result='';
        end

        function result=getColorbar(~)
            result='';
        end

        function result=getBasicFitting(~)
            result='';
        end

        function result=getDataStats(~)
            result='';
        end

        function result=getDataLinking(~)
            result='';
        end

        function result=getCameraTools(~)
            result='';
        end
    end


    methods(Access='protected')

        function setTitle(~,~)
        end

        function setXLabel(~,~)
        end

        function setYLabel(~,~)
        end

        function setZLabel(~,~)
        end

        function setGrid(~,~)
        end

        function setXGrid(~,~)
        end

        function setYGrid(~,~)
        end

        function setZGrid(~,~)
        end

        function setRGrid(~,~)
        end

        function setThetaGrid(~,~)
        end

        function setLegend(~,~)
        end

        function setColorbar(~,~)
        end

        function setBasicFitting(~,~)
        end

        function setDataStats(~,~)
        end

        function setDataLinking(~,~)
        end

        function setCameraTools(~,~)
        end
    end
end

