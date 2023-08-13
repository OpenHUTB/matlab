classdef(Abstract,Hidden)LayerInterface<handle&matlab.mixin.CustomDisplay

    properties(SetAccess=protected)

        Catalog char


        CatalogVersion(1,1)double
    end

    properties(Access=protected)

        LayerType driving.internal.heremaps.LayerType
    end

    methods

        function this=LayerInterface(data,metadata)




            for field=fields(data)'
                this.(field{:})=data.(field{:});
            end


            this.Catalog=metadata.Catalog;
            this.CatalogVersion=metadata.Version;
            this.LayerType=metadata.Layer;
        end

    end

    methods(Access=protected)

        function groups=getPropertyGroups(this)


            [fields,metaFields]=...
            driving.internal.heremaps.utils.getLayerFields(...
            unique(string([this.LayerType])));

            groups(1)=matlab.mixin.util.PropertyGroup(fields,...
            getString(message('driving:heremaps:LayerDataPropertyGroupText')));
            groups(2)=matlab.mixin.util.PropertyGroup(metaFields,...
            getString(message('driving:heremaps:LayerMetadataPropertyGroupText')));
        end

    end

    methods(Hidden)

        function plot(this,varargin)


            plottable=driving.internal.heremaps.LayerType.getPlottable;
            error(message('driving:heremaps:LayerNotPlottable',...
            unique(string([this.LayerType])),join(string(plottable),', ')));
        end

    end

end

