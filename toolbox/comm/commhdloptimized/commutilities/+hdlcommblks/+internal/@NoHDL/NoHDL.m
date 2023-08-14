classdef NoHDL<imported.hdldefaults.NoHDL






























    methods
        function this=NoHDL(block)












            supportedBlocks={...
            'commsink2/Error Rate Calculation',...
            'commsink2/Discrete-Time Signal Trajectory Scope',...
'built-in/ConstellationDiagram'...
            ,'built-in/EyeDiagram'...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Sinks',...
            'HelpText','HDL Support for Sinks');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'No HDL'},...
            'Description',desc);

        end

    end

    methods
        val=mustElaborateInPhase1(~,~,~)
    end

end

