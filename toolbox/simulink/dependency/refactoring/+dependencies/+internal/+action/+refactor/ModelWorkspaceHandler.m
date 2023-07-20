classdef ModelWorkspaceHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types;
        RenameOnly;
    end
    properties(SetAccess=immutable,GetAccess=private)
        FunctionCallType;
    end

    methods
        function this=ModelWorkspaceHandler()
            import dependencies.internal.analysis.simulink.ModelWorkspaceAnalyzer;
            import dependencies.internal.graph.Type;
            baseType=ModelWorkspaceAnalyzer.ModelWorkspaceType;
            this.FunctionCallType=Type([baseType,"FunctionCall"]);
            this.Types={baseType,char(this.FunctionCallType.ID)};
            this.RenameOnly=false;
        end

        function refactor(this,dependency,newPath)
            [~,newRef,newExt]=fileparts(newPath);
            [~,model,~]=fileparts(dependency.UpstreamNode.Location{1});
            ws=get_param(model,'modelworkspace');
            if dependency.Type==this.FunctionCallType
                text=ws.MATLABCode;
                updated=dependencies.internal.action.refactor.updateMatlabCode(...
                dependency.UpstreamNode,text,dependency.DownstreamNode,newPath,false);
                ws.MATLABCode=updated;
            else
                [folder,~]=fileparts(ws.FileName);
                if~isempty(folder)
                    ws.FileName=newPath;
                else
                    ws.FileName=[newRef,newExt];
                end
            end
            ws.reload;
        end

    end

end
