classdef DataDictionaryHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="DataDictionary";
        HandleToDlg=containers.Map('KeyType','double','ValueType','any');
    end

    methods
        function unhilite=openUpstream(this,dependency)
            unhilite=@()[];
            import dependencies.internal.graph.Type;

            upstreamNode=dependency.UpstreamNode;
            location=upstreamNode.Location{1};
            [~,filename,ext]=fileparts(location);
            if ismember(ext,[".slx",".mdl"])
                if upstreamNode.Type==Type.TEST_HARNESS
                    blockDiagram=upstreamNode.Location{3};
                else
                    blockDiagram=filename;
                end
                h=get_param(blockDiagram,'Object');
                doubleHandle=h.Handle;
                if this.HandleToDlg.isKey(doubleHandle)&&ishandle(this.HandleToDlg(doubleHandle))
                    dlg=this.HandleToDlg(doubleHandle);
                    dlg.setActiveTab('Tabcont',4);
                    dlg.show;
                else
                    dlg=DAStudio.Dialog(h);
                    dlg.setActiveTab('Tabcont',4);
                    this.HandleToDlg(doubleHandle)=dlg;
                end
            end
        end
    end
end
