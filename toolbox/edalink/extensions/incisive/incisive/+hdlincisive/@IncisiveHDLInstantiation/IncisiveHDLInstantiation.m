classdef IncisiveHDLInstantiation<hdldefaults.abstractBBox































    methods
        function this=IncisiveHDLInstantiation(block)





            supportedBlocks={'lfilinklib/HDL Cosimulation'};

            if nargin==0

                block='';
            end

            desc=struct(...
            'ShortListing','Xcelium HDL instantiation',...
            'HelpText','Xcelium code generation via direct HDL instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','instantiation',...
            'Description',desc);

        end

    end

    methods

        v_settings=block_validate_settings(this,hC)
        hdlcode=emit(this,hC)
        name=getClockInputPort(this,hC)
        [path,name]=incisivedehierarchyname(this,namestr)
    end


    methods(Hidden)

        category=libcategory(this,blk)
    end
end



