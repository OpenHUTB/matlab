classdef SimulinkProjectAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions;
        MinimumArguments=0;
        StringArguments=[];
        AllowedArguments=[];
        TypeMap;
    end

    methods

        function this=SimulinkProjectAnalyzer
            [this.Functions,this.TypeMap]=i_createTypeMap;
        end

        function refs=analyze(this,~,ref,~)
            refs=dependencies.internal.analysis.matlab.Reference.empty;

            if isempty(ref.OutputArguments)
                return;
            end


            func=i_getFunction(ref.Function.Value);
            type=this.TypeMap(func);


            symbol=ref.OutputArguments(1).Value;
            var=dependencies.internal.analysis.matlab.Variable(symbol,{type});
            ref.Workspace.addVariables(var);
        end
    end
end


function[funcs,map]=i_createTypeMap

    map=containers.Map;

    funcs={
    i_updateTypeMap(map,'simulinkproject','slproject.ProjectManager')
    i_updateTypeMap(map,'slproject.getCurrentProject','slproject.ProjectManager')
    i_updateTypeMap(map,'slproject.loadProject','slproject.ProjectManager')
    i_updateTypeMap(map,'slproject.create','slproject.ProjectManager')
    i_updateTypeMap(map,'slproject.ProjectManager.addFile','slproject.ProjectFile')
    i_updateTypeMap(map,'slproject.ProjectManager.addFolderIncludingChildFiles','slproject.ProjectFile')
    i_updateTypeMap(map,'slproject.ProjectManager.addPath','slproject.PathFolder')
    i_updateTypeMap(map,'slproject.ProjectManager.addReference','slproject.ProjectReference')
    i_updateTypeMap(map,'slproject.ProjectManager.addShortcut','slproject.Shortcut')
    i_updateTypeMap(map,'slproject.ProjectManager.findFile','slproject.ProjectFile')
    i_updateTypeMap(map,'slproject.ProjectManager.findCategory','slproject.Category')
    i_updateTypeMap(map,'slproject.ProjectManager.createCategory','slproject.Category')
    i_updateTypeMap(map,'slproject.ProjectFile.addLabel','slproject.Label')
    i_updateTypeMap(map,'slproject.ProjectFile.findLabel','slproject.Label')
    };

end


function symbol=i_updateTypeMap(map,symbol,type)
    func=i_getFunction(symbol);
    map(func)=type;%#ok<NASGU>
end


function func=i_getFunction(symbol)
    func=split(symbol,'.');
    func=func{end};
end
