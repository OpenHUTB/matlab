function[data,c]=createValidTrip(params,constraints,varargin)














    p=inputParser();
    addParameter(p,'StartupTime',20);
    parse(p,varargin{:});
    l=p.Results.StartupTime;

    n=params.NumberOfIterations;
    cVal=nan(n,numel(constraints));
    for k=1:n

        tEnd=params.TripDurationRange(1)+rand()*diff(params.TripDurationRange);
        t=(0:params.dt:tEnd)';

        try

            v=RDE.functions.createTripGamma(t,params);


            v=max(0,min(t/l,1)).*v;

            opMode=RDE.functions.calcOperationMode(v,params);

            data=RDE.functions.createDriveCycleTimetable(t,v,opMode);

            c=cellfun(@(x)x(data,params),constraints);
            cVal(k,:)=c;
        catch ME
            disp(ME.identifier);
            continue
        end


        if max(c)<=0
            fprintf('RDE compliant drive cycle successfully generated in %i iterations\n',k)
            return;
        end
    end
    fprintf('Could not generate an RDE compliant drive cycle in %i iterations\n',k)
end