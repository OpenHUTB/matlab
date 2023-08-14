classdef DataDictionaryHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types={dependencies.internal.analysis.simulink.DataDictionaryAnalyzer.DataDictionaryType};
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            [~,~,ext]=fileparts(dependency.UpstreamNode.Location{1});
            [~,newRef,newExt]=fileparts(string(newPath));

            if strcmp(ext,".sldd")
                i_updateDataDictionaryDependency(dependency,newRef);
            else
                i_updateModelDependency(dependency.UpstreamNode,newRef+newExt);
            end
        end
    end

end

function i_updateDataDictionaryDependency(dependency,newRef)
    upstreamDictionary=dependency.UpstreamNode.Location{1};
    downstreamDictionary=dependency.DownstreamNode.Location{1};
    [~,oldRef]=fileparts(downstreamDictionary);

    orig_state=warning('off','SLDD:sldd:DictionaryNotFound');
    restore=onCleanup(@()warning(orig_state));

    i_closeDataDictionaryIfOpen(downstreamDictionary);
    i_closeDataDictionaryIfOpen(upstreamDictionary);
    dictionaryObj=Simulink.data.dictionary.open(upstreamDictionary,'SubdictionaryErrorAction','warn');

    removeDataSource(dictionaryObj,oldRef+".sldd");
    addDataSource(dictionaryObj,newRef+".sldd");
    dictionaryObj.saveChanges;
    dictionaryObj.close;
end

function i_closeDataDictionaryIfOpen(dataDict)
    openDict=Simulink.data.dictionary.getOpenDictionaryPaths;
    if any(strcmp(dataDict,openDict))
        [~,name,ext]=fileparts(dataDict);
        Simulink.data.dictionary.closeAll([name,ext]);
    end
end

function i_updateModelDependency(upstreamNode,newDictionary)
    if upstreamNode.Type==dependencies.internal.graph.Type.TEST_HARNESS
        blockDiagram=upstreamNode.Location{3};
    else
        [~,blockDiagram]=fileparts(upstreamNode.Location{1});
    end

    set_param(blockDiagram,"DataDictionary",newDictionary);
end
