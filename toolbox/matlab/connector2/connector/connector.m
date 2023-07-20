function[isRunning,hostInfo]=connector(arg,varargin)

    try
        if system_dependent('isdmlworker')

            return;
        end


        if nargin==0




            disp(message('MATLAB:connector:connector:NotSupported'));

        elseif nargin>0
            if strcmpi(arg,'on')||strcmpi(arg,'off')
                error(message('MATLAB:connector:connector:NotSupported'));

            elseif strcmpi(arg,'localhostonly')
                connector.ensureServiceOn;

            elseif strcmpi(arg,'dev')
                warning('Dev mode is not longer supported, use an explicit reverse proxy');
                connector.ensureServiceOn;

            elseif strcmpi(arg,'shutdown')
                disp('Do not shutdown connector (or at least switch to connector.internal.shutdown)!');
                connector.internal.shutdown();


            elseif~strcmpi(arg,'status')
                error(message('MATLAB:connector:connector:InvalidInput'));
            end
        end


        if nargout>0
            isRunning=connector.isRunning;
            if nargout>1
                info=connector.internal.getHostInfo();
                hostInfo=rmfield(info,'running');
            end
        end

    catch exception
        exception.throwAsCaller;
    end

end
