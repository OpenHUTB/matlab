classdef BaseWorkspaceNodeAnalyzer<dependencies.internal.analysis.NodeAnalyzer




    properties(Constant)
        BaseType="BaseWorkspace";
        NodeType=dependencies.internal.graph.Nodes.BaseWorkspaceNode.Type;
        Extensions=string.empty;
    end

    methods
        function analyze=canAnalyze(this,~,node)
            analyze=node.Type==this.NodeType;
        end

        function deps=analyze(this,handler,wsNode)
            import dependencies.internal.buses.util.analyzeBusObjects;
            import dependencies.internal.buses.util.analyzeBusElementObjects;
            import dependencies.internal.buses.util.analyzeSignalObjects;
            import dependencies.internal.buses.util.analyzeBusStructs;
            deps=dependencies.internal.graph.Dependency.empty;

            ws=evalin("base","whos")';
            names=string({ws.name});
            classes=string({ws.class});

            isBus=strcmp(classes,"Simulink.Bus");
            if any(isBus)
                buses=i_createStruct(names(isBus));
                deps=[deps,analyzeBusObjects(handler.Analyzers.Bus.BusNode,wsNode,buses,this.BaseType)];
            end

            isElement=strcmp(classes,"Simulink.BusElement");
            if any(isElement)
                buses=i_createStruct(names(isElement));
                deps=[deps,analyzeBusElementObjects(handler.Analyzers.Bus.BusNode,wsNode,buses,this.BaseType)];
            end

            isSignal=strcmp(classes,"Simulink.Signal");
            if any(isSignal)
                signals=i_createStruct(names(isSignal));
                deps=[deps,analyzeSignalObjects(handler.Analyzers.Bus.BusNode,wsNode,signals,this.BaseType)];
            end

            isStruct=strcmp(classes,"struct");
            if any(isStruct)
                structs=i_createStruct(names(isStruct));
                deps=[deps,analyzeBusStructs(handler.Analyzers.Bus.BusNode,wsNode,structs,this.BaseType)];
            end

        end
    end

end

function values=i_createStruct(names)
    values=struct;
    for name=names
        values.(name)=evalin("base",name);
    end
end
