
classdef BlockInfo<handle

    methods(Access=public)

        function this=BlockInfo(blockPath)
            this.m_Path=blockPath;
            this.m_Type=this.privateGetBlockType(blockPath);
        end

        function blockPath=getPath(this)
            blockPath=this.m_Path;
        end

        function blockSid=getSid(this)
            blockSid=string(Simulink.ID.getSID(this.m_Path));
        end

        function blockType=getType(this)
            blockType=this.m_Type;
        end





    end

    methods(Access=private)

        function blockType=privateGetBlockType(~,blockPath)
            sfBlockType=get_param(blockPath,'SFBlockType');
            switch sfBlockType
            case 'MATLAB Function'
                blockType=ModelAdvisor.Common.CsEml.BlockType.MATLABFunction;
            case 'Chart'
                blockType=ModelAdvisor.Common.CsEml.BlockType.Chart;
            case 'State Transition Table'
                blockType=ModelAdvisor.Common.CsEml.BlockType.StateTransitionTable;
            case 'Truth Table'
                blockType=ModelAdvisor.Common.CsEml.BlockType.TruthTable;
            otherwise
                blockType=ModelAdvisor.Common.CsEml.BlockType.Invalid;
            end
        end

    end

    properties
        m_Path;
        m_Type;
    end

end

