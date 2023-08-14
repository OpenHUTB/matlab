classdef Stateflow<hdlimplbase.SFBase



    methods
        function this=Stateflow(block)

            supportedBlocks={'sflib/Chart'};
            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'Stateflow'},...
            'Deprecates','hdlstateflow.StateflowHDLInstantiation');
        end

    end

    methods
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
        v=getHelpInfo(this,blkTag)
        params=hideImplParams(this,blockHandle,implInfo)
    end

    methods(Hidden)
        v=validate(this,hC)
        v=baseValidateImplParams(this,hC)
        registerImplParamInfo(this)
    end

end

