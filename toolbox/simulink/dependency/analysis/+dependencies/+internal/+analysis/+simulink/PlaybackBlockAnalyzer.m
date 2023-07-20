classdef PlaybackBlockAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        PlaybackBlockType=dependencies.internal.graph.Type("PlaybackBlock");
        ValidExtensions=Simulink.sdi.internal.import.FileImporter.getDefault().getAllValidFileExtensions();
    end

    methods

        function this=PlaybackBlockAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.SignalSources=createParameterQuery('Array[Type="Simulink.playback.LinkedSignalMetadata"]/Object/SignalSource','BlockType','Playback');
            queries.SingleSignalSource=createParameterQuery('Object[ClassName="Simulink.playback.LinkedSignalMetadata"]/SignalSource','BlockType','Playback');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            dependencyInfo=locExtractDependencyInfo(matches);
            numPlaybackBlocks=length(dependencyInfo);
            blocks=dependencyInfo.keys();
            for i=1:numPlaybackBlocks

                files=unique(dependencyInfo(blocks{i}));

                for n=1:length(files)
                    file=files{n};
                    if~isempty(file)
                        blockComp=Component.createBlock(node,blocks{i},handler.getSID(blocks{i}));

                        target=handler.Resolver.findFile(node,file,...
                        this.ValidExtensions);
                        if~target.Resolved

                            folder=fileparts(node.Path);
                            relative=handler.Resolver.findFile(node,...
                            fullfile(folder,file),this.ValidExtensions);
                            if relative.Resolved
                                target=relative;
                            end
                        end
                        deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                        blockComp,target,this.PlaybackBlockType);%#ok<AGROW>
                    end
                end
            end
        end
    end
end



function depdendecyInfo=locExtractDependencyInfo(queryMatches)
    depdendecyInfo=containers.Map;
    filePaths=[queryMatches.SignalSources.Value,queryMatches.SingleSignalSource.Value];
    blockPaths=[queryMatches.SignalSources.BlockPath,queryMatches.SingleSignalSource.BlockPath];
    for i=1:numel(blockPaths)
        blockPath=blockPaths{i};
        files={};
        if(depdendecyInfo.isKey(blockPath))
            files=depdendecyInfo(blockPath);
        end
        filePath=filePaths{i};
        if(~isempty(filePath)&&filePath~="workspace")

            files{numel(files)+1}=filePath;%#ok<AGROW>
            depdendecyInfo(blockPath)=files;
        end
    end
end
