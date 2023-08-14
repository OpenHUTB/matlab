classdef CurrentWindowPositionSupplier<handle




    methods(Access=public,Static)

        function obj=getInstance()
            import slxmlcomp.internal.highlight.CurrentWindowPositionSupplier;
            obj=CurrentWindowPositionSupplier.getSetInstance();
        end







        function obj=setInstance(instance)
            import slxmlcomp.internal.highlight.CurrentWindowPositionSupplier;
            obj=CurrentWindowPositionSupplier.getSetInstance(instance);
        end
    end


    methods(Access=private,Static)
        function toReturn=getSetInstance(varargin)
            persistent instance

            if nargin>0
                instance=varargin{1};
            end

            toReturn=instance;
        end

    end


end
