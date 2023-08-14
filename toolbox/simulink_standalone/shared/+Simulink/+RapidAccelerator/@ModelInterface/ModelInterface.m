classdef ModelInterface<handle
    methods(Access='private')
        function obj=SimulinkModelInterface(modelName)
        end
    end
    methods(Abstract=true)
        val=get_param(obj,parameter)
        val=get_block_param(obj,path,parameter)
        set_param(obj,parameter,val)

        blocks=find_root_blocks(obj,blockType)

        report_warning(obj,id,varargin)
        report_error(obj,id,varargin)

        val=slfeature(obj,feature)

        set_rtp(rtp)
        rtp=get_rtp(obj)

        populate(obj)
        serializeData(obj,filename)
        deserializeData(obj,filename)
    end
end