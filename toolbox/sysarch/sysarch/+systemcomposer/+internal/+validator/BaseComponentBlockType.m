classdef BaseComponentBlockType<handle






    properties
        handleOrPath;
    end

    methods
        function this=BaseComponentBlockType(handleOrPath)
            if nargin==0

                return;
            end
            this.handleOrPath=handleOrPath;
        end






        function[canConvert,allowed]=canAddVariant(this)
            canConvert=false;
            allowed=false;
        end

        function[canConvert,allowed]=canCreateSimulinkBehavior(this)
            canConvert=false;
            allowed=false;
        end

        function[canConvert,allowed]=canCreateStateflowBehavior(this)
            canConvert=false;
            allowed=false;
        end

        function[canConvert,allowed]=canLinkToModel(this)
            canConvert=false;
            allowed=false;
        end

        function[canConvert,allowed]=canSaveAsArchitecture(this)
            canConvert=false;
            allowed=false;
        end

        function[canConvert,allowed]=canSaveAsSoftwareArchitecture(this)
            canConvert=false;
            allowed=false;
        end

        function[canConvert,allowed]=canInline(this)
            canConvert=false;
            allowed=false;
        end

        function[canConvert,allowed]=canConjugatePort(this)
            canConvert=false;
            allowed=false;
        end
    end

end
