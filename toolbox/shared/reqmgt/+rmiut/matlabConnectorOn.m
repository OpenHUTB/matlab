function result=matlabConnectorOn(varargin)







    persistent status;

    if nargin>0&&strcmp(varargin{1},'force')

        status=[];
    elseif~isempty(status)&&status



        isMcRunning=connector.internal.isRestMatlabRunning;
        if~isMcRunning
            display(getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorRestarting')));
            status=[];
        end
    end

    if isempty(status)
        try



            if~rmipref('UnsecureHttpRequests')
                rmipref('UnsecureHttpRequests',true);
            else

                connector.internal.ensureRestMatlabOn();
            end
            result=true;
        catch Ex
            warning(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorFailed',Ex.message));
            result=false;
        end
        status=result;
    else
        result=status;
    end
end

