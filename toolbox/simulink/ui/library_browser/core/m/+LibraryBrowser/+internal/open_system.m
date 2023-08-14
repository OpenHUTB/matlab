function open_system(sys)


    sys=strrep(sys,';','');

    if exist(sys,'file')~=4&&~strcmpi(sys,'simulink')

        [lib,subsystem]=strtok(sys,'/');

        if exist(lib,'file')~=4&&~strcmpi(lib,'simulink')

            [lib,subsystem]=i_findLibraryAndSubsystem(sys);

            if isempty(subsystem)
                if isempty(lib)||exist(lib,'file')~=4

                    return;
                else

                    sys=lib;
                end
            else
                sys=subsystem;
            end
        end


        if~isempty(subsystem)

            if exist(lib,'file')==4||strcmpi(lib,'simulink')
                load_system(lib);
            else
                return;
            end
        end
    end

    open_system(sys);
end

function[varargout]=i_parseArgs(varargin)%#ok
    [varargout{1:nargin}]=varargin{:};
    i=nargin+1;
    while i<(nargout+1)
        varargout{i}=[];
        i=i+1;
    end
end

function[lib,subsystem]=i_findLibraryAndSubsystem(graphOpenFcn)
    lib=[];
    subsystem=[];
    functionmatch='load_open_subsystem';
    if isempty(strfind(graphOpenFcn,functionmatch))
        functionmatch='open_system';
        if isempty(strfind(graphOpenFcn,functionmatch))
            return;
        end
    end
    cmd=strrep(graphOpenFcn,functionmatch,'i_parseArgs');
    try
        [lib,subsystem]=eval(cmd);
    catch

    end
end
