classdef FigureAnimationsSynchronizer









    methods(Static)

        function synchronizeScopeFigure(hFig)
            scope=hFig.UserData;
            if(isa(scope,'matlabshared.scopes.UnifiedScope')||...
                isa(scope,'uiscopes.Framework'))&&...
                ~isSynchronous(scope.DataSource)


                try
                    convertToSynchronous(scope.DataSource.Updater);
                catch me %#ok<NASGU>






                end
            end
        end
    end
end