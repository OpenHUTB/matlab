function tx=transmitter(asset,varargin)%#codegen




































































































































































    coder.allowpcode('plain');

    if coder.target('MATLAB')

        try


            toolboxdir('satcom');
        catch ME
            if strcmpi(ME.identifier,'MATLAB:toolboxdir:DirectoryNotFound')
                error(message('shared_orbit:orbitPropagator:SatcomToolboxNotFilesMissing','transmitter'));
            else
                rethrow(ME);
            end
        end
    end

    if nargin>1
        tx=satcom.satellitescenario.internal.AddAssetsAndAnalyses.transmitter(asset,varargin{:});
    else
        tx=satcom.satellitescenario.internal.AddAssetsAndAnalyses.transmitter(asset);
    end
end

