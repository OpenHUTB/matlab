classdef TruthTable<hdlimplbase.SFBase



    methods
        function this=TruthTable(block)

            supportedBlocks={...
            'sflib/Truth Table',...
            };
            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'TruthTable'});
        end

    end

    methods
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
        v=getHelpInfo(this,blkTag)
    end

end

