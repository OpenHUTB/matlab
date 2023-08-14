


classdef ReferenceDesignQsysQpro<hdlturnkey.plugin.ReferenceDesignIntel


    methods

        function obj=ReferenceDesignQsysQpro()

            obj=obj@hdlturnkey.plugin.ReferenceDesignIntel();

            obj.SupportedTool='Intel Quartus Pro';
        end

    end

end
