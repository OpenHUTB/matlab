classdef ModelSimHDLInstantiation<hdldefaults.abstractBBox



    methods
        function this=ModelSimHDLInstantiation(block)
            supportedBlocks={'modelsimlib/HDL Cosimulation'};

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','ModelSim HDL instantiation',...
            'HelpText','ModelSim code generation via direct HDL instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','instantiation',...
            'Description',desc);

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hdlcode=emit(this,hC)
        name=getClockInputPort(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        [path,name]=mtidehierarchyname(this,namestr)
        v=getHelpInfo(this,blkTag)
    end


    methods(Hidden)
        category=libcategory(this,blk)
    end

end

