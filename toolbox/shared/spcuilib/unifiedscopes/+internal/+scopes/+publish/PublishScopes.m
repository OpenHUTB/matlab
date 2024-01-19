classdef PublishScopes<internal.matlab.publish.PublishFigures

    methods
        function obj=PublishScopes(options)
            obj=obj@internal.matlab.publish.PublishFigures(options);
        end
    end


    methods(Static)
        function imgFilename=snapFigure(f,varargin)

            scope=f.UserData;
            if(isa(scope,'matlabshared.scopes.UnifiedScope')||...
                isa(scope,'uiscopes.Framework'))&&...
                ~isSynchronous(scope.DataSource)

                try
                    convertToSynchronous(scope.DataSource.Updater);
                catch me %#ok<NASGU>

                end
            end

            imgFilename=snapFigure@internal.matlab.publish.PublishFigures(f,varargin{:});
        end
    end
end


