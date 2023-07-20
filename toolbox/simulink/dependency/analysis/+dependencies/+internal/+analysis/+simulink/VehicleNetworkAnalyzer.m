classdef VehicleNetworkAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        VehicleNetworkType=dependencies.internal.graph.Type("VehicleNetwork");
        Blocks=[
        "canmsglib/CAN Unpack","CANdbFile",".dbc";
        "canmsglib/CAN Pack","CANdbFile",".dbc";
        "canlib/CAN Replay","FullPathFileName",".mat";
        "canlib/CAN Log","FullPathFileName",".mat";
        "canfdmsglib/CAN FD Unpack","CANdbFile",".dbc";
        "canfdmsglib/CAN FD Pack","CANdbFile",".dbc";
        "canfdlib/CAN FD Replay","FullPathFileName",".mat";
        "canfdlib/CAN FD Log","FullPathFileName",".mat";
        sprintf("j1939protocollib/J1939 Network\nConfiguration"),"DbFile",".dbc"
        "xcpprotocollib/CAN/XCP CAN Configuration","A2LFile",".a2l";
        "xcpprotocollib/CAN/XCP CAN Configuration","SeedKeyLib",".dll";
        "xcpprotocollib/UDP/XCP UDP Configuration","A2LFile",".a2l";
        "xcpprotocollib/UDP/XCP UDP Configuration","SeedKeyLib",".dll";
        ];
    end

    methods

        function this=VehicleNetworkAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createInstanceDataParameterQuery;

            for n=1:length(this.Blocks)
                queries.("Query"+n)=createInstanceDataParameterQuery(this.Blocks(n,2),"SourceBlock",this.Blocks(n,1));
            end

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty(1,0);

            for n=1:length(this.Blocks)
                files=matches.("Query"+n).Value;
                blocks=matches.("Query"+n).BlockPath;
                extensions=this.Blocks(n,3);

                for m=1:length(files)
                    if files{m}~=""
                        upComp=Component.createBlock(node,blocks{m},handler.getSID(blocks{m}));
                        target=handler.Resolver.findFile(node,files{m},extensions);
                        deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                        upComp,target,this.VehicleNetworkType);%#ok<AGROW>
                    end
                end
            end
        end

    end

end
