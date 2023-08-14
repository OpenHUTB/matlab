classdef ProductCatalogReader<matlab.mixin.SetGet&matlab.mixin.Heterogeneous





    properties

ProductCatalogFile

FeatureParameters

Features

ConstrainedFeature

Constraints

ModelPath

PlantModel
    end

    properties(Access=private)

MandatoryFeatures

OptionalFeatures

FeatureMap
    end

    methods
        function obj=ProductCatalogReader(varargin)
            if~isempty(varargin)
                set(obj,varargin{:});
            end

            if~isempty(obj.ProductCatalogFile)
                obj.readProductCatalog();
                obj.ConstrainedFeature=obj.buildConstrainedFeatures();
                obj.Constraints=obj.getConstraintsAndSignal();
            end

        end

    end

    methods
        function readProductCatalog(obj)

            obj.Features=sheetnames(obj.ProductCatalogFile);
            obj.Features=obj.Features(1:end-4);
            obj.FeatureMap=containers.Map;
            n=length(obj.Features);
            obj.FeatureParameters=cell(n,1);
            for i=1:n

                obj.FeatureParameters{i}=readbyFeaturename(obj,obj.Features{i},obj.ProductCatalogFile);

            end
        end



        function out=getMFeatures(obj)
            out=obj.MandatoryFeatures;
        end

        function out=getOFeatures(obj)
            out=obj.OptionalFeatures;
        end

        function out=getAFeature(obj,featurename)
            out=[];
            if~isempty(obj.FeatureMap)
                out=obj.FeatureMap(featurename);
            end
        end


        function vvparameter=readbyFeaturename(obj,featurename,filein)
            data=readmatrix(filein,'FileType','spreadsheet',...
            'Sheet',featurename,...
            'OutputType','char',...
            'NumHeaderLines',1);
            feature=data{1,1};
            vvparameter=VirtualAssembly.VirtualFeature('Feature',feature);
            vvparameter.Type=data{1,14};
            if strcmpi(data{1,14},'mandatory')
                ind=length(obj.MandatoryFeatures);
                obj.MandatoryFeatures{ind+1}=featurename;
            else
                ind=length(obj.OptionalFeatures);
                obj.OptionalFeatures{ind+1}=featurename;
            end

            vvparameter.FeatureVariant=unique(data(:,2),'stable');
            vlen=length(vvparameter.FeatureVariant);
            pp=[];label=[];icon=[];image=[];


            for ii=1:vlen
                fp=[];
                sidx=find(strcmp(vvparameter.FeatureVariant(ii),data(:,2)));
                startidx=sidx(1);
                stopidx=sidx(end);

                if~isempty(data{startidx,11})

                    label{end+1}=data{startidx,11};

                end

                if~isempty(data{startidx,12})

                    icon{end+1}=data{startidx,12};

                end

                if~isempty(data{startidx,13})

                    image{end+1}=data{startidx,13};

                end

                if~isempty(data{startidx,3})

                    for j=startidx:stopidx

                        fp{j-startidx+1}=VirtualAssembly.Parameters('Name',data{j,3},...
                        'Description',data{j,4},...
                        'Unit',data{j,5},...
                        'Value',data{j,6},...
                        'Editable',data{j,7},...
                        'Plotable',data{j,8},...
                        'DataSource',data{j,9},...
                        'VarName',data{j,10});

                    end
                end




                pp{end+1}=fp;



            end

            vvparameter.FeatureParameter=pp;
            vvparameter.Label=label;
            vvparameter.Icon=icon;
            vvparameter.Image=image;

            obj.FeatureMap(featurename)=vvparameter.FeatureVariant;






        end

        function fdata=getFeatureData(obj,featurename)
            index=find(strcmp(obj.Features,featurename),1);
            try
                fdata=obj.FeatureParameters{index};
            catch

            end
        end

        function Output=buildConstrainedFeatures(obj)



            components=obj.FeatureParameters;
            n_components=length(components);


            for i=1:n_components
                ComponentName=components{i}.Feature;
                ComponentNameNoSpace=VirtualAssembly.NameFilter(ComponentName);
                Output.(ComponentNameNoSpace).Name=ComponentName;
                Output.(ComponentNameNoSpace).Options=components{i}.FeatureVariant;
                Output.(ComponentNameNoSpace).Value=components{i}.FeatureVariant(1);
                Output.(ComponentNameNoSpace).default.Options=components{i}.FeatureVariant;
            end

        end


        function output=getConstraintsAndSignal(obj)
            bdclose all;
            cd(obj.ModelPath);
            output=obj.buildConstraints();
        end


        function Output=buildConstraints(obj)

            ModelFile=obj.ModelPath;
            ProductCatalogData=obj;


            if~isempty(obj.ProductCatalogFile)
                if strcmp(obj.PlantModel,'Simulink')
                    Components=readmatrix(obj.ProductCatalogFile,'FileType','spreadsheet',...
                    'Sheet','SimulinkComponents','OutputType','char','NumHeaderLines',1);
                    FConstraints=readmatrix(obj.ProductCatalogFile,'FileType','spreadsheet',...
                    'Sheet','SimulinkConstraints','OutputType','char','NumHeaderLines',1);
                else
                    Components=readmatrix(obj.ProductCatalogFile,'FileType','spreadsheet',...
                    'Sheet','SimscapeComponents','OutputType','char','NumHeaderLines',1);
                    FConstraints=readmatrix(obj.ProductCatalogFile,'FileType','spreadsheet',...
                    'Sheet','SimscapeConstraints','OutputType','char','NumHeaderLines',1);
                end
            end


            num_all_components=size(Components,1);
            delete_component_index=[];
            for i=1:num_all_components
                if strcmp(Components{i,2},'inactive')
                    delete_component_index=[delete_component_index,i];
                end
            end
            Components(delete_component_index,:)=[];


            n_components=size(Components,1);
            for i=1:n_components
                ComponentName=Components{i,1};
                ComponentNameNoSpace=VirtualAssembly.NameFilter(ComponentName);
                ComponentPath=[];
                if~strcmp(Components{i,3},'none')&&~strcmp(Components{i,3},'dataset')
                    for j=9:size(Components,2)
                        if~strcmp(Components{i,j},'none')
                            ComponentPath=[ComponentPath,convertCharsToStrings(Components{i,j})];
                        end
                    end
                end
                eval([ComponentNameNoSpace,'= VirtualAssembly.VirtualAssemblyComponents(ModelFile,ComponentName,ComponentPath,Components{i,3},Components{i,5},Components{i,8},ProductCatalogData);']);
            end


            G1=digraph;
            G2=digraph;

            for i=1:n_components
                G1=addnode(G1,Components{i,1});
                G2=addnode(G2,Components{i,1});
            end

            for i=1:n_components
                nodes=strsplit(Components{i,7},', ');
                if~strcmp(nodes{1,1},'none')
                    NumOfNodes=size(nodes,2);
                    for j=1:NumOfNodes
                        if findnode(G1,nodes{j})~=0
                            G1=addedge(G1,Components{i,1},nodes{j});
                        end
                    end
                end
            end

            for i=1:n_components
                nodes=strsplit(Components{i,6},', ');
                if~strcmp(nodes{1,1},'none')
                    NumOfNodes=size(nodes,2);
                    for j=1:NumOfNodes
                        if findnode(G2,nodes{j})~=0
                            G2=addedge(G2,Components{i,1},nodes{j});
                        end
                    end
                end
            end


            n_constraints=size(FConstraints,1);
            for i=1:n_constraints
                MasterComponent=FConstraints{i,1};
                MasterOption=FConstraints{i,2};
                Condition=FConstraints{i,3};
                RequestedComponent=FConstraints{i,4};
                RequiredOption=FConstraints{i,5};
                resolution=FConstraints{i,6};
                eval([MasterComponent,'.addConstraints(MasterOption,','Condition,',RequestedComponent,',RequiredOption,resolution);']);
            end


            for i=1:n_components
                ComponentName=Components{i,1};
                ComponentNameNoSpace=VirtualAssembly.NameFilter(ComponentName);
                Output.(ComponentNameNoSpace)=eval(ComponentNameNoSpace);
            end
            Output.ComponentAdjacency=G1;
            Output.ConstraintAdjacency=G2;
        end

    end
end


