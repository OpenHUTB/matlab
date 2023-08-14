classdef Feature<matlab.mixin.SetGet&matlab.mixin.Heterogeneous



    properties

        FeatureName(1,:)char='';

        FeatureVariants='';

        FeatureVariantsDes='';

        FeatureIcons='';

        FeatureOptionImages='';
    end

    methods
        function obj=Feature(varargin)
            if~isempty(varargin)
                if ischar(varargin{1})

                    varargin=[{'FeatureName'},varargin];
                end
                set(obj,varargin{:});
            end
        end
    end

    methods

        function addFeature(varargin)
            obj=varargin{1};
            set(obj,varargin{:});
        end

        function addFeatureItems(obj,proname,value)
            if isempty(obj.(proname))
                obj.(proname)=value;
            else
                obj.(proname){end+1}=value;
            end
        end

        function changeFeatureItems(obj,proname,value,index)
            nn=length(obj.(proname));
            if length(obj.(proname))<index-1
                for i=nn+1:index-1
                    obj.(proname){i}='';
                end
            end
            obj.(proname){index}=value;
        end
    end
end