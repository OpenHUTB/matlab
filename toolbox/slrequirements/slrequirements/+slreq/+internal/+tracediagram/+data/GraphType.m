classdef GraphType

    enumeration
Artifact
Element
Unset
    end
    methods
        function out=isArtifact(this)
            out=this=="Artifact";
        end

        function out=isElement(this)
            out=this=="Element";
        end

    end
end
