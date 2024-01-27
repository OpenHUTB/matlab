classdef Block<handle

    properties
        path=''
    end


    methods
        function this=Block(path)
            this.path=path;
        end


        function blockPath=getPath(this)
            blockPath=this.path;
        end


        function priority=getSequenceNumber(this)
            priority=ASCET2Simulink.BlockSequenceNumber(this);
        end

    end
end
