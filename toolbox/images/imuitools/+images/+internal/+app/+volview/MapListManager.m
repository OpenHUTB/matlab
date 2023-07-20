classdef MapListManager<handle


    properties
        appVolColormaps={getString(message('images:volumeViewer:mri')),...
        getString(message('images:volumeViewer:ctbone')),...
        getString(message('images:volumeViewer:ctsoft_tissue')),...
        getString(message('images:volumeViewer:ctlung')),...
        getString(message('images:volumeViewer:ctcoronary')),...
        getString(message('images:volumeViewer:mrimip')),...
        getString(message('images:volumeViewer:ctmip'))};
List
ListType
        DefaultVolCmap='gray';
        DefaultVolAmap=getString(message('images:volumeViewer:linear'));
    end

    methods
        function obj=MapListManager(listType)
            obj.ListType=listType;

            switch listType
            case 'volumeColormap'
                obj.List=[{'bone','copper','gray','hot','hsv','jet','parula',...
                'pink'},getString(message('images:volumeViewer:linear')),...
                obj.appVolColormaps];

            case 'volumeAlphamap'
                obj.List=[getString(message('images:volumeViewer:linear')),...
                obj.appVolColormaps];

            end
        end

        function[cmap,colorCP]=getColormap(self,colormapName)

            colorCP=[];

            if strcmp(colormapName,getString(message('images:volumeViewer:linear')))
                colormapName='cool';
            end

            if any(strcmp(colormapName,self.appVolColormaps))
                config=images.internal.app.volview.VolumeConfiguration(colormapName);
                cmap=config.Colormap;
                colorCP=config.ColorControlPoints;
            else
                fhandle=str2func(colormapName);
                if strcmp(self.ListType,'volumeColormap')
                    cmap=fhandle(256);
                else

                    cmap=[zeros(1,3);fhandle(255)];
                end
            end
        end

        function[amap,alphaCP]=getAlphamap(~,amapName)
            config=images.internal.app.volview.VolumeConfiguration(amapName);
            amap=config.Alphamap;
            alphaCP=config.AlphaControlPoints;
        end

        function idx=getDefaultIdx(self)

            switch self.ListType
            case 'volumeColormap'
                idx=find(strcmp(self.DefaultVolCmap,self.List));
            case 'volumeAlphamap'
                idx=find(strcmp(self.DefaultVolAmap,self.List));
            end
        end
    end
end