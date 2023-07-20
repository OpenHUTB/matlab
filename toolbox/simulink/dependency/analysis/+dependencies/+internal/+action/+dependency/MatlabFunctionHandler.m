classdef MatlabFunctionHandler<dependencies.internal.action.DependencyHandler





    properties(Constant)
        Types=["MATLABFcn","StateflowMATLABFcn"];
    end

    properties(Constant,Access=private)
        UnsupportedSSIDType=dependencies.internal.graph.Type("UnsupportedSSID");
    end

    methods
        function unhilite=openUpstream(this,dependency)
            if dependency.Type.Leaf==this.UnsupportedSSIDType
                unhilite=@()[];
                open_system(dependency.UpstreamComponent.Path);
                return;
            end

            unhilite=@()Simulink.ID.hilite('');

            [blockFullSID,isMATLABFcn]=this.getBlockSID(dependency);

            Simulink.ID.hilite(blockFullSID,"find");

            if isMATLABFcn
                open_system(blockFullSID);
            end
        end
    end

    methods(Hidden,Static,Access=public)
        function[blockFullSID,isMATLABFcn]=getBlockSID(dependency)
            isMATLABFcn=(dependency.Type.Base==...
            dependencies.internal.graph.Type("MATLABFcn"));

            if isMATLABFcn
                sid=dependency.UpstreamComponent.BlockPath;
                ssid="";
            else
                location=dependency.UpstreamComponent.Path;
                colonIdx=strfind(location,":");
                colonIdx=colonIdx(end);
                sid=extractBefore(location,colonIdx);
                ssid=":"+extractAfter(location,colonIdx);
            end

            if~Simulink.ID.isValid(sid)
                sid=Simulink.ID.getSID(sid);
            end

            blockFullSID=sid+ssid;
        end
    end
end
