classdef PortSpecificationForCScriptUI<handle



    properties(Access=private)
        m_BlockHandle;
        m_SSHandle;
    end

    properties(Access=private,Constant=true)
        refreshTypeMessage=DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace');
    end

    methods(Hidden)
        function this=PortSpecificationForCScriptUI(hBlk)
            import SLCC.blocks.ui.PortSpec.*;
            this.m_BlockHandle=hBlk;
            this.m_SSHandle=CScriptPortSS(this);
        end

        function updatePortStruct(this,affectedUITableCells)
            if~isempty(this.m_SSHandle)&&isvalid(this.m_SSHandle)
                this.m_SSHandle.updateSSWidget(affectedUITableCells);
            end
        end

        function hSS=getSSSource(this)
            import SLCC.blocks.ui.PortSpec.*;
            if isempty(this.m_SSHandle)||~isvalid(this.m_SSHandle)
                this.m_SSHandle=CScriptPortSS(this);
            end
            hSS=this.m_SSHandle;
        end

    end

    methods(Hidden,Static)

    end
end




