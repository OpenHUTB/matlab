function propagator=orbitPropagator(varargin)



















































































































    narginchk(1,6);





    validateattributes(varargin{1},{'numeric','struct'},{},1);
    if isnumeric(varargin{1})






        initializationType='inertialVector';


        initialPosition=varargin{1};
        initialVelocity=varargin{2};



        switch nargin
        case 2



            if~coder.target('MATLAB')
                msg=message(...
                'shared_orbit:orbitPropagator:NameValuePairsNotSpecified');
                error(msg);
            end
            initialTime=NaT;
            propagatorType="";
        case 4



            if~coder.target('MATLAB')
                msg=message(...
                'shared_orbit:orbitPropagator:NameValuePairsNotSpecified');
                error(msg);
            end
            switch lower(varargin{3})
            case 'initialtime'
                initialTime=varargin{4};
                propagatorType="";
            case 'type'
                propagatorType=varargin{4};
                initialTime=NaT;
            otherwise
                msg=message(...
                'shared_orbit:orbitPropagator:InvalidParameterName',...
                varargin{3});
                error(msg);
            end
        case 6

            switch lower(varargin{3})
            case 'initialtime'
                initialTime=varargin{4};
                if~strcmpi(varargin{5},'Type')
                    msg=message(...
                    'shared_orbit:orbitPropagator:InvalidParameterName',...
                    varargin{5});
                    error(msg);
                end
                propagatorType=varargin{6};
            case 'type'
                propagatorType=varargin{4};
                if~strcmpi(varargin{5},'InitialTime')
                    msg=message(...
                    'shared_orbit:orbitPropagator:InvalidParameterName',...
                    varargin{5});
                    error(msg);
                end
                initialTime=varargin{6};
            otherwise
                msg=message(...
                'shared_orbit:orbitPropagator:InvalidParameterName',...
                varargin{3});
                error(msg);
            end
        otherwise
            msg=message(...
            'shared_orbit:orbitPropagator:InvalidInputCount');
            error(msg);
        end
    else





        initializationType='tle';


        tleData=varargin{1};



        switch nargin
        case 1



            if~coder.target('MATLAB')
                msg=message(...
                'shared_orbit:orbitPropagator:NameValuePairsNotSpecified');
                error(msg);
            end
            initialTime=NaT;
            propagatorType="";
        case 3



            if~coder.target('MATLAB')
                msg=message(...
                'shared_orbit:orbitPropagator:NameValuePairsNotSpecified');
                error(msg);
            end
            switch lower(varargin{2})
            case 'initialtime'
                initialTime=varargin{3};
                propagatorType="";
            case 'type'
                propagatorType=varargin{3};
                initialTime=NaT;
            otherwise
                msg=message(...
                'shared_orbit:orbitPropagator:InvalidParameterName',...
                varargin{2});
                error(msg);
            end
        case 5

            switch lower(varargin{2})
            case 'initialtime'
                initialTime=varargin{3};
                if~strcmpi(varargin{4},'Type')
                    msg=message(...
                    'shared_orbit:orbitPropagator:InvalidParameterName',...
                    varargin{4});
                    error(msg);
                end
                propagatorType=varargin{5};
            case 'type'
                propagatorType=varargin{3};
                if~strcmpi(varargin{4},'InitialTime')
                    msg=message(...
                    'shared_orbit:orbitPropagator:InvalidParameterName',...
                    varargin{4});
                    error(msg);
                end
                initialTime=varargin{5};
            otherwise
                msg=message(...
                'shared_orbit:orbitPropagator:InvalidParameterName',...
                varargin{2});
                error(msg);
            end
        otherwise
            msg=message(...
            'shared_orbit:orbitPropagator:InvalidInputCount');
            error(msg);
        end
    end


    if coder.target('MATLAB')
        validateattributes(initialTime,{'datetime'},{'scalar'},...
        'orbitPropagator','initialTime');
    end


    initialTime.TimeZone="UTC";



    switch initializationType
    case 'inertialVector'

        validateattributes(initialPosition,...
        {'numeric'},...
        {'nonempty','real','finite','vector','numel',3},...
        'orbitPropagator','initialPosition',1);
        validateattributes(initialVelocity,...
        {'numeric'},...
        {'nonempty','real','finite','vector','numel',3},...
        'orbitPropagator','initialVelocity',2);



        if isnat(initialTime)
            initialTime=datetime("now","TimeZone","UTC");
        end
    otherwise

        validateattributes(tleData,{'struct'},...
        {'nonempty','scalar'},'orbitPropagator','tleData',1);





        messageCatalogString='shared_orbit:orbitPropagator:MissingTLEStructField';


        if~isfield(tleData,'Name')
            msg=message(messageCatalogString,'Name');
            error(msg);
        end


        if~isfield(tleData,'Epoch')
            msg=message(messageCatalogString,'Epoch');
            error(msg);
        end


        if~isfield(tleData,'BStar')
            msg=message(messageCatalogString,'BStar');
            error(msg);
        end


        if~isfield(tleData,'RightAscensionOfAscendingNode')
            msg=message(messageCatalogString,...
            'RightAscensionOfAscendingNode');
            error(msg);
        end


        if~isfield(tleData,'Eccentricity')
            msg=message(messageCatalogString,'Eccentricity');
            error(msg);
        end


        if~isfield(tleData,'Inclination')
            msg=message(messageCatalogString,'Inclination');
            error(msg);
        end


        if~isfield(tleData,'ArgumentOfPeriapsis')
            msg=message(messageCatalogString,'ArgumentOfPeriapsis');
            error(msg);
        end


        if~isfield(tleData,'MeanAnomaly')
            msg=message(messageCatalogString,'MeanAnomaly');
            error(msg);
        end


        if~isfield(tleData,'MeanMotion')
            msg=message(messageCatalogString,'MeanMotion');
            error(msg);
        end



        if isnat(initialTime)
            initialTime=tleData.Epoch;
        end
    end







    orbitPropagatorType=string(propagatorType);
    if strcmp(propagatorType,"")
        if strcmp(initializationType,"inertialVector")
            orbitPropagatorType="two-body-keplerian";
        else
            meanMotion=tleData.MeanMotion;
            period=2*pi/meanMotion;
            if period<225*60
                orbitPropagatorType="sgp4";
            else
                orbitPropagatorType="sdp4";
            end
        end
    end




    if isequal(orbitPropagatorType,'two-body-keplerian')


        if~isequal(initializationType,'inertialVector')




            minSDP4Period=225*60;
            meanMotionTLE=tleData.MeanMotion;
            periodTLE=2*pi/meanMotionTLE;
            if periodTLE<minSDP4Period
                [initialPositionTEME,initialVelocityTEME]=...
                matlabshared.orbit.internal.SGP4.propagate(tleData,initialTime);
            else
                [initialPositionTEME,initialVelocityTEME]=...
                matlabshared.orbit.internal.SDP4.propagate(tleData,initialTime);
            end



            initialPositionITRF=matlabshared.orbit.internal.Transforms.teme2itrf(...
            initialPositionTEME,initialTime);
            initialVelocityITRF=matlabshared.orbit.internal.Transforms.teme2itrf(...
            initialVelocityTEME,initialTime);


            itrf2gcrfTransform=...
            matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(initialTime);
            initialPosition=itrf2gcrfTransform*initialPositionITRF;
            initialVelocity=itrf2gcrfTransform*initialVelocityITRF;
        end

        [semiMajorAxis,eccentricity,rightAscensionOfAscendingNode,...
        inclination,argumentOfPeriapsis,trueAnomaly]=...
        matlabshared.orbit.internal.TwoBodyKeplerian.inertialVectorToOrbitalElements(...
        initialPosition,initialVelocity);
    end


    orbitPropagatorType=string(validatestring(orbitPropagatorType,...
    {'two-body-keplerian','sgp4','sdp4'},'orbitPropagator','Type'));


    switch orbitPropagatorType
    case "two-body-keplerian"
        propagator=...
        matlabshared.orbit.internal.TwoBodyKeplerian(semiMajorAxis,...
        eccentricity,inclination,rightAscensionOfAscendingNode,...
        argumentOfPeriapsis,trueAnomaly,initialTime);
    case "sgp4"
        propagator=matlabshared.orbit.internal.SGP4(tleData,initialTime);
    case "sdp4"
        propagator=...
        matlabshared.orbit.internal.SDP4(tleData,initialTime);
    otherwise
        msg=message(...
        'shared_orbit:orbitPropagator:InvalidPropagatorType',...
        orbitPropagatorType);
        error(msg);
    end
end