classdef StateTransitionTable<hdlimplbase.SFBase



    methods
        function this=StateTransitionTable(block)

            supportedBlocks={'sflib/State Transition Table'};
            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'StateTransitionTable'});
        end

    end

    methods
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
        v=getHelpInfo(this,blkTag)
    end

end

