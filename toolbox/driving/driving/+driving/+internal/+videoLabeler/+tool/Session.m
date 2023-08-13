classdef Session<vision.internal.labeler.tool.Session&...
    vision.internal.videoLabeler.tool.Session


    methods(Access=protected)

        function value=getVersion(this)
            value=versionFromProductName(this,"driving","Automated Driving Toolbox");
        end
    end


    methods(Static,Hidden)
        function this=loadobj(that)




            that.Version=vision.internal.labeler.tool.Session....
            findVersionInfoByProductName(...
            that.Version,"Automated Driving Toolbox");

            if isa(that,'driving.internal.videoLabeler.tool.Session')
                this=that;
            else
                this=driving.internal.videoLabeler.tool.Session;
                loadObjHelper(this,that,true);
            end
        end
    end

    methods
        function gTruth=exportLabelAnnotations(this,signalNames)

            if nargin<2
                signalNames=getSignalNames(this);
            end


            definitions=exportLabelDefinitions(this);

            if isempty(definitions)
                gTruth=[];
            else


                dataSources=getDataSourceForExport(this,signalNames);


                selectedSignalNames=[dataSources.SignalName];
                [roiData,sceneData]=getAnnotationsForExport(this,selectedSignalNames);

                gTruth=groundTruthMultisignal(dataSources,definitions,...
                roiData,sceneData);
            end
        end

        function definitions=exportLabelDefinitions(this)

            definitions=exportLabelDefinitions@vision.internal.videoLabeler.tool.Session(this);
            definitions=formatLabelDefinitionTable(this,definitions);
        end
    end

    methods(Hidden)
        function dataSources=getDataSourceForExport(this,signalNames)

            if nargin<2
                signalNames=getSignalNames(this);
            end

            sources=getSource(this.SignalModel);
            dataSources=vision.labeler.loading.MultiSignalSource.empty;

            selectedSignalNames=[];

            for sourceId=1:numel(sources)

                currentSource=sources(sourceId);

                sourceSignalNames=currentSource.SignalName;

                if any(ismember(signalNames,sourceSignalNames))
                    selectedSignalNames=[selectedSignalNames,sourceSignalNames];%#ok<AGROW>

                    className=class(currentSource);

                    newSource=eval(className);

                    newSource.loadSource(currentSource.SourceName,...
                    currentSource.SourceParams);

                    newSource.setTimestamps(currentSource.Timestamp);

                    dataSources=[dataSources;newSource];%#ok<AGROW>
                end
            end
        end

        function[roiData,sceneData]=getAnnotationsForExport(this,signalNames)
            timeVectors=getTimeVectors(this.SignalModel,signalNames);

            maintainROIOrder=false;

            roiAnnotationsTable=this.ROIAnnotations.export2table(timeVectors,signalNames,maintainROIOrder);
            [frameAnnotations,frameLabelNames]=this.FrameAnnotations.exportData(timeVectors,signalNames);

            roiData=vision.labeler.labeldata.ROILabelData(signalNames,roiAnnotationsTable);
            if~isempty(frameLabelNames)
                sceneData=vision.labeler.labeldata.SceneLabelData(frameLabelNames,frameAnnotations);
            else
                sceneData=vision.labeler.labeldata.SceneLabelData.empty;
            end
        end
    end

    methods(Access=private)
        function outputLabelDefinitions=formatLabelDefinitionTable(~,inputLabelDefinitions)


            index=string(inputLabelDefinitions.Properties.VariableNames)=="Type";
            inputLabelDefinitions.Properties.VariableNames{index}='LabelType';



            inputLabelDefinitions=replicateLabelsForPCData(...
            inputLabelDefinitions,labelType.Rectangle,labelType.Cuboid);
            inputLabelDefinitions=replicateLabelsForPCData(...
            inputLabelDefinitions,labelType.Line,labelType.Line);


            signalTypes=vision.labeler.loading.SignalType.empty(height(inputLabelDefinitions),0);

            additionalEntry=0;
            totalEntry=height(inputLabelDefinitions)-sum(inputLabelDefinitions.LabelType==labelType.Line)/2;
            for idx=1:totalEntry
                switch inputLabelDefinitions.LabelType(idx+additionalEntry)
                case{labelType.Rectangle,labelType.PixelLabel,labelType.Polygon,labelType.ProjectedCuboid}
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.Image;
                case{labelType.Cuboid}
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.PointCloud;
                case{labelType.Line}
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.Image;
                    additionalEntry=additionalEntry+1;
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.PointCloud;
                case labelType.Scene
                    signalTypes(idx+additionalEntry)=vision.labeler.loading.SignalType.Time;
                end
            end

            inputLabelDefinitions=addvars(inputLabelDefinitions,signalTypes',...
            'After','Name','NewVariableNames',"SignalType");

            inputLabelDefinitions=movevars(inputLabelDefinitions,'Group',...
            'After','LabelType');
            inputLabelDefinitions=movevars(inputLabelDefinitions,'Description',...
            'After','Group');
            inputLabelDefinitions=movevars(inputLabelDefinitions,'LabelColor',...
            'After','Description');

            variableNames=string(inputLabelDefinitions.Properties.VariableNames);

            if any(variableNames=="PixelLabelID")
                inputLabelDefinitions=movevars(inputLabelDefinitions,'PixelLabelID',...
                'After','LabelColor');
            end

            if any(variableNames=="Hierarchy")
                if any(variableNames=="PixelLabelID")
                    columnName='PixelLabelID';
                else
                    columnName='LabelColor';
                end
                inputLabelDefinitions=movevars(inputLabelDefinitions,'Hierarchy',...
                'After',columnName);
            end

            outputLabelDefinitions=inputLabelDefinitions;
        end
    end
end

function inputLabelDefinitions=replicateLabelsForPCData(...
    inputLabelDefinitions,labelTypes,suportedLabelType)

    indices=find(inputLabelDefinitions.LabelType==labelTypes);
    for idx=1:numel(indices)

        rowIdx=indices(idx);
        inputLabelDefinitions=[inputLabelDefinitions(1:rowIdx,:);...
        inputLabelDefinitions(rowIdx,:);...
        inputLabelDefinitions(rowIdx+1:end,:)];

        inputLabelDefinitions.LabelType(rowIdx+1)=suportedLabelType;

        hasHierarchyColumn=any(string(inputLabelDefinitions.Properties.VariableNames)=="Hierarchy");

        if hasHierarchyColumn
            hierarchyInfo=inputLabelDefinitions.Hierarchy(rowIdx+1);
            hierarchyInfo{1}.Type=suportedLabelType;
            inputLabelDefinitions.Hierarchy(rowIdx+1)=hierarchyInfo;
        end

        indices(idx+1:end)=indices(idx+1:end)+1;
    end
end
