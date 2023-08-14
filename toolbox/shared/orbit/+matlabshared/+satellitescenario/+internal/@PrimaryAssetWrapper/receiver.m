function rx=receiver(asset,varargin)%#codegen



































































































































































    coder.allowpcode('plain');

    if coder.target('MATLAB')

        try


            toolboxdir('satcom');
        catch ME
            if strcmpi(ME.identifier,'MATLAB:toolboxdir:DirectoryNotFound')
                error(message('shared_orbit:orbitPropagator:SatcomToolboxNotFilesMissing','receiver'));
            else
                rethrow(ME);
            end
        end
    end

    if nargin>1
        rx=satcom.satellitescenario.internal.AddAssetsAndAnalyses.receiver(asset,varargin{:});
    else
        rx=satcom.satellitescenario.internal.AddAssetsAndAnalyses.receiver(asset);
    end

    if coder.target('MATLAB')

        updateViewersIfAutoShow(asset);
    end
end

