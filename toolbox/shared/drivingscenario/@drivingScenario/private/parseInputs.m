function parseInputs(obj,varargin)
    if~checkoutFirstAvailableLicense({'Automated_Driving_Toolbox','Vehicle_Dynamics_Blockset'})
        id='driving:scenario:NoLicenseAvailable';
        throwAsCaller(MException(id,getString(message(id))));
    end

    p=inputParser;
    p.addParameter('SampleTime',0.01);
    p.addParameter('StopTime',Inf);
    p.addParameter('AxesOrientation','ENU');
    p.addParameter('VerticalAxis',driving.scenario.Plot.DefaultVerticalAxis,@(x)mustBeMember(x,{'X','Y'}));
    p.addParameter('GeographicReference',[]);
    p.addParameter('GeoReference',[]);
    p.parse(varargin{:});
    r=p.Results;
    obj.SampleTime=r.SampleTime;
    obj.StopTime=r.StopTime;
    obj.AxesOrientation=r.AxesOrientation;
    obj.VerticalAxis=r.VerticalAxis;
    obj.GeographicReference=r.GeographicReference;
    if~isempty(r.GeoReference)
        obj.GeographicReference=r.GeoReference;
    end
    obj.Barriers=driving.scenario.Barrier.empty;
    obj.Actors=driving.scenario.Actor.empty;
    obj.ParkingLots=driving.scenario.ParkingLot.empty;
    obj.Plots=driving.scenario.Plot.empty;

end

function success=checkoutFirstAvailableLicense(products)

    success=true;
    for index=1:numel(products)
        prod=products{index};

        if builtin('license','test',prod)&&~isempty(builtin('license','inuse',prod))

            [avail,~]=builtin('license','checkout',prod);
            if avail

                return;
            end
        end
    end

    for index=1:numel(products)
        prod=products{index};


        if builtin('license','test',prod)
            [checkAvail,~]=builtin('license','checkout',prod);
            if checkAvail

                return;
            end
        end
    end
    success=false;

end