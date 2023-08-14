


classdef ReferenceDesignQsys<hdlturnkey.plugin.ReferenceDesignIntel


    methods

        function obj=ReferenceDesignQsys()

            obj=obj@hdlturnkey.plugin.ReferenceDesignIntel();

            obj.SupportedTool='Altera QUARTUS II';
        end

    end

end
