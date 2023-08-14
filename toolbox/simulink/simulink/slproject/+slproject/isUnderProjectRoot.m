function[b,projectRoot]=isUnderProjectRoot(f)
















    if nargin<1||(~ischar(f)&&~iscell(f)&&~isstring(f))
        error(message('MATLAB:project:api:isUnderProjectRootInvalidArguments'))
    end

    [b,projectRoot]=matlab.internal.project.util.isUnderProjectRoot(f);

end
