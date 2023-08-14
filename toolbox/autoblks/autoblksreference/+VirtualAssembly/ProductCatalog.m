classdef ProductCatalog<matlab.mixin.SetGet&matlab.mixin.Heterogeneous



    properties

        Name=''

        SolnModel=[];
    end

    properties(SetAccess=private)

        Catalog=[]

        Data=[]
    end

    methods
        function obj=ProductCatalog(varargin)
            if~isempty(varargin)
                if ischar(varargin{1})

                    varargin=[{'Name'},varargin];
                end
                set(obj,varargin{:});
            end
            file=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            [obj.Name,'.xlsx']);
            obj.ProductCatalogData=VirtualAssembly.ProductCatalogReader(file);
            obj.createProductCatalog(obj.Name);

        end

        function delete(obj)
            obj.clearDictionary();
        end

    end

    methods
        function createProductCatalog(obj,name)

            import systemcomposer.feature.*;
            import systemcomposer.feature.solution.*

            m=mf.zero.Model;

            obj.Catalog=SystemCatalog.make(name);

            MFeatures=obj.Data.getMFeatures();

            for i=1:length(MFeatures)
                obj.addMandatoryFeature(MFeatures{i});
                AFeatures=obj.Data.getAFeature(MFeatures{i});
                obj.addAlternativeFeature(MFeatures{i},AFeatures);
            end


            OFeatures=obj.Data.getOFeatures();
            for i=1:length(OFeatures)
                obj.addOptionalyFeature(OFeatures{i});
                AFeatures=obj.Data.getAFeature(OFeatures{i});
                obj.addAlternativeFeature(MFeatures{i},AFeatures);
            end


            obj.addSolution();
        end

        function addMandatoryFeature(obj,feature)
            import systemcomposer.feature.*;


            obj.Catalog.addFeature(feature,FeatureType.MANDATORY);
        end

        function addOptionalyFeature(obj,feature)
            import systemcomposer.feature.*;

            obj.Catalog.addFeature(feature,FeatureType.OPTIONAL);
        end

        function addAlternativeFeature(obj,feature,variants)

            import systemcomposer.feature.*;
            if ischar(feature)
                feature=obj.Catalog.getFeature(feature);
            end
            var=feature.addFeatureGroup(GroupType.ALTERNATIVE);
            for i=1:length(variants)
                var.addFeature(variants{i});
            end
        end

        function plotCatalog(obj)
            import systemcomposer.feature.*;
            g=obj.Catalog.toGraph();
            plot(g);
        end

        function feature=getFeature(obj,featurename)
            import systemcomposer.feature.*;
            feature=obj.Catalog.getFeature(featurename);
        end

        function variants=getSubFeature(obj,featurename)


            import systemcomposer.feature.*;
            if isempty(featurename)
                featurename=obj.Name;
            end
            catalog=obj.Catalog;
            g=catalog.toGraph();
            edgetable=g.Edges;
            variants={};
            for i=1:length(edgetable.EndNodes)
                if strcmp(edgetable.EndNodes{i,1},featurename)
                    f=edgetable.EndNodes{i,2};
                    variants=[variants,f];
                end
            end
        end

        function addConstraint(obj,feature1,type,feature2)
            import systemcomposer.feature.*;
            switch type
            case 'require'
                obj.Catalog.addConstraint(feature1,ConstraintType.REQUIRES,feature2);
            case 'excludes'
                obj.Catalog.addConstraint(feature1,ConstraintType.REQUIRES,feature2);
            otherwise
            end

        end

        function addSolution(obj)

            import systemcomposer.feature.*
            import systemcomposer.feature.solution.*
            Model.make(obj.Catalog,obj.SolnModel);
        end

        function setFeatureParameter(obj,feature,solnModel,featurepath,pname,pvalue)



            SetParameter.make(feature,solnModel,featurepath,pname,pvalue);
        end

        function clearDictionary(~)
            systemcomposer.feature.SystemCatalog.clear();
        end
    end
end

