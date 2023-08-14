classdef AppGallery<handle&matlab.mixin.Heterogeneous




    properties

gallery
galleryPopup

galleryCats

galleryItems

categoryItems
    end

    properties(Access=protected)
Model
App
    end

    methods
        function obj=AppGallery(Model,App)

            obj.Model=Model;
            obj.App=App;
        end


        function rtn=getSelectedItem(obj)

            sync(obj.App)
            indices=cell2mat(cellfun(@(x)x.Value,...
            obj.galleryItems,'UniformOutput',false));
            if any(indices)
                rtn=obj.galleryItems{indices}.Tag;
            else
                rtn='';
            end
        end

        function reset(obj)
            selectItem(obj,obj.getSelectedItem());
        end

        function selectItem(obj,itemName)

            for i=1:length(obj.galleryItems)
                if strcmp(itemName,obj.galleryItems{i}.Tag)


                    obj.galleryItems{i}.Value=true;
                else

                    obj.galleryItems{i}.Value=false;
                end
            end
            sync(obj.App)
        end

        function disable(obj,varargin)
            if nargin==0
                obj.gallery.Enabled=false;
            else
                p=inputParser;
                p.addParameter('Item','',@ischar);
                parse(p,varargin{:})

                itemNames=cellfun(@(x)x.Tag,obj.galleryItems,'UniformOutput',false);
                obj.galleryItems{strcmpi(itemNames,p.Results.Item)}.Enabled=false;
            end
        end

        function enable(obj,varargin)
            if nargin==0
                obj.gallery.Enabled=false;
            else
                p=inputParser;
                p.addParameter('Item','',@ischar);
                parse(p,varargin{:})

                itemNames=cellfun(@(x)x.Tag,obj.galleryItems,'UniformOutput',false);
                obj.galleryItems{strcmpi(itemNames,p.Results.Item)}.Enabled=true;
            end
        end

    end
end
