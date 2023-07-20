





function UKF=initUKFCustom(t,pos)
    classToUse=class(pos);
    scaleAccel=ones(1,classToUse);
    dt=ones(1,classToUse);
    G1d=[dt^2/2;dt]*scaleAccel;
    Q1d=G1d*G1d';
    Qdim=1;
    Q=blkdiag(Q1d,Q1d,Q1d,Qdim,Qdim,Qdim);









    H1d=cast([1,0],classToUse);
    H=blkdiag(H1d,H1d,H1d,1,1,1);
    state=H'*pos(:);






    l=0.001;
    L=1;
    ldim=0.01;

    measureNoise=MeasurementNoise(pos,t);
    if isscalar(measureNoise)
        n=numel(pos);
        measurementNoise=matlabshared.tracking.internal.expandScalarValue(measureNoise,[n,n]);
    else
        measurementNoise=measureNoise;
    end
    stateCov=H'*measurementNoise*H+diag([l,L,l,L,l,L,ldim,ldim,ldim]);




    UKF=lidar.internal.lidarObjectTracker.lidarTrackingUKF(@i_constvel,@i_cvmeas,state,...
    'StateCovariance',stateCov,...
    'MeasurementNoise',measurementNoise,...
    'ProcessNoise',Q,...
    'Alpha',0.03);
end


function state=i_constvel(state,varargin)


    if nargin==1
        dt=ones(1,1,'like',state);
    else
        dt=varargin{1};
    end




    for i=[1,3,5]
        state(i)=state(i)+state(i+1)*dt;
    end
end

function measurement=i_cvmeas(state)



    measurement=state([1,3,5,7,8,9]);
end

function measurementNoise=MeasurementNoise(positions,value)



    stateDims=size(positions(:),1);
    validateattributes(value,{'numeric'},{'real',...
    'square','nonsparse','finite'},...
    'objectDetection','MeasurementNoise');
    if~isempty(value)
        if isscalar(value)

            measurementNoise=value*eye(stateDims,...
            'like',positions);
        else

            validateattributes(value,{'numeric'},{'size',[stateDims,stateDims]},...
            'objectDetection','MeasurementNoise');


            matlabshared.tracking.internal.isSymmetricPositiveSemiDefinite('MeasurementNoise',value);
            measurementNoise=...
            cast(value,class(positions));
        end
    else
        measurementNoise=eye(stateDims,...
        'like',positions);
    end
end