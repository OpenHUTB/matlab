function sat=walkerDelta(SCENARIO,varargin)%#codegen





















































































    coder.allowpcode('plain');

    if coder.target('MATLAB')

        try


            toolboxdir('aero');
        catch ME
            if strcmpi(ME.identifier,'MATLAB:toolboxdir:DirectoryNotFound')
                error(message('shared_orbit:orbitPropagator:AerospaceToolboxFilesMissing','walkerDelta'));
            else
                rethrow(ME);
            end
        end
    end

    if nargin>1
        sat=Aero.spacecraft.internal.satellitescenario.walkerDelta(SCENARIO,varargin{:});
    else
        sat=Aero.spacecraft.internal.satellitescenario.walkerDelta(SCENARIO);
    end

end

