classdef(StrictDefaults)Simulation3DRadarTruthSensor<AbstractSim3DTruthSensor


    properties(Nontunable)

        DetectionRange=[1,150];


        DetectionProbability=0.9


        ReferenceRange=100


        ReferenceRCS=0


        FalseAlarmRate=1e-6


        FieldOfView=[20,5]


        RangeResolution=2.5


        RangeBiasFraction=0.05


        AzimuthResolution=4


        AzimuthBiasFraction=0.1


        HasElevation(1,1)logical=true

        DisplayProjection(1,1)logical=false










        ElevationResolution=10








        ElevationBiasFraction=0.1







        HasRangeRate(1,1)logical=true









        RangeRateLimits=[-100,100]









        RangeRateResolution=0.5








        RangeRateBiasFraction=0.05

















        DetectionCoordinates='Ego Cartesian'
    end

    properties(SetAccess=private)










RadarLoopGain
    end

    methods
        function val=get.RadarLoopGain(obj)












            rcsdB=obj.ReferenceRCS;
            snrdB=getSNR(obj,obj.DetectionProbability);
            range=obj.ReferenceRange;
            val=snrdB-rcsdB+4*10*log10(range);
        end
    end

    properties(Nontunable)






        HasFalseAlarms(1,1)logical=true
    end


    properties(Constant,Hidden)
        DetectionCoordinatesSet=matlab.system.StringSet({'Ego Cartesian','Sensor Cartesian','Sensor spherical'});
    end

    properties(Constant,Access=protected)
        pBusPrefix='BusSimulation3DRadarTruthSensor'
    end


    properties(Access={?Simulation3DRadarTruthSensor,?matlab.unittest.TestCase})
pTargetPds
pMappedPointTargets
    end


    methods
        function set.DetectionRange(obj,val)
            obj.checkDetectionRange(val);
            obj.DetectionRange=val;
        end

        function set.DetectionProbability(obj,val)
            obj.checkDetectionProbability(val);
            obj.DetectionProbability=val;
        end

        function set.ReferenceRange(obj,val)
            obj.checkReferenceRange(val);
            obj.ReferenceRange=val;
        end

        function set.ReferenceRCS(obj,val)
            obj.checkReferenceRCS(val);
            obj.ReferenceRCS=val;
        end

        function set.FalseAlarmRate(obj,val)
            obj.checkFalseAlarmRate(val);
            obj.FalseAlarmRate=val;
        end

        function set.FieldOfView(obj,val)
            obj.checkFieldOfView(val);
            obj.FieldOfView=val;
        end

        function set.RangeResolution(obj,val)
            obj.checkRangeResolution(val);
            obj.RangeResolution=val;
        end

        function set.RangeBiasFraction(obj,val)
            obj.checkRangeBiasFraction(val);
            obj.RangeBiasFraction=val;
        end

        function set.AzimuthResolution(obj,val)
            obj.checkAzimuthResolution(val);
            obj.AzimuthResolution=val;
        end

        function set.AzimuthBiasFraction(obj,val)
            obj.checkAzimuthBiasFraction(val);
            obj.AzimuthBiasFraction=val;
        end

        function set.ElevationResolution(obj,val)
            obj.checkElevationResolution(val);
            obj.ElevationResolution=val;
        end

        function set.ElevationBiasFraction(obj,val)
            obj.checkElevationBiasFraction(val);
            obj.ElevationBiasFraction=val;
        end

        function set.RangeRateLimits(obj,val)
            obj.checkRangeRateLimits(val);
            obj.RangeRateLimits=val;
        end

        function set.RangeRateResolution(obj,val)
            obj.checkRangeRateResolution(val);
            obj.RangeRateResolution=val;
        end

        function set.RangeRateBiasFraction(obj,val)
            obj.checkRangeRateBiasFraction(val);
            obj.RangeRateBiasFraction=val;
        end
    end


    methods(Access=protected)
        function s=saveObjectImpl(obj)

            s=saveObjectImpl@AbstractSim3DTruthSensor(obj);

            if isLocked(obj)
                s.pTargetPds=obj.pTargetPds;
                s.pMappedPointTargets=obj.pMappedPointTargets;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)

            if wasLocked
                obj.pTargetPds=s.pTargetPds;
                s=rmfield(s,'pTargetPds');

                obj.pMappedPointTargets=s.pMappedPointTargets;
                s=rmfield(s,'pMappedPointTargets');
            end

            loadObjectImpl@AbstractSim3DTruthSensor(obj,s,wasLocked);
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=isInactivePropertyImpl@AbstractSim3DTruthSensor(obj,prop);

            if~obj.HasElevation&&...
                (strcmp(prop,'ElevationResolution')||...
                strcmp(prop,'ElevationBiasFraction'))
                flag=true;
            end

            if~obj.HasRangeRate&&...
                (strcmp(prop,'RangeRateResolution')||...
                strcmp(prop,'RangeRateBiasFraction')||...
                strcmp(prop,'RangeRateLimits'))
                flag=true;
            end
        end

        function group=getPropertyGroups(obj)
            dispGroups=getPropertyGroupsLongImpl(obj);
            group=dispGroups(1:4);


            detGroup=group(4);
            detList=detGroup.PropertyList(1:2);
            detGroup=matlab.mixin.util.PropertyGroup(detList);
            group(4)=detGroup;
        end

        function groups=getPropertyGroupsLongImpl(obj)
            absGroup=getPropertyGroupsLongImpl@AbstractSim3DTruthSensor(obj);

            idList={'SensorIdentifier','VehicleIdentifier','UpdateInterval'};
            idGroup=matlab.mixin.util.PropertyGroup(idList);

            extList={'Translation','Rotation'};
            extGroup=matlab.mixin.util.PropertyGroup(extList);

            fovList={'FieldOfView','RangeRateLimits'};
            fovGroup=matlab.mixin.util.PropertyGroup(fovList);

            detList={...
            'DetectionProbability','FalseAlarmRate','ReferenceRange','ReferenceRCS'};
            detGroup=matlab.mixin.util.PropertyGroup(detList);

            resList={'AzimuthResolution','ElevationResolution',...
            'RangeResolution','RangeRateResolution'};
            resGroup=matlab.mixin.util.PropertyGroup(resList);

            biasList={...
            'AzimuthBiasFraction','ElevationBiasFraction','RangeBiasFraction',...
            'RangeRateBiasFraction'};
            biasGroup=matlab.mixin.util.PropertyGroup(biasList);

            outList=absGroup.PropertyList;
            outList=[{'HasElevation'},{'HasRangeRate'},...
            {'HasNoise'},{'HasFalseAlarms'},...
            outList];
            outGroup=matlab.mixin.util.PropertyGroup(outList);

            groups=[idGroup,extGroup,fovGroup,detGroup,resGroup,biasGroup,outGroup];
        end

        function str=getIconImpl(obj)
            str=sprintf("Radar Detections\nGet\n[Unique sensor ID: %d]",obj.SensorIdentifier);
        end
    end

    methods(Static,Access=protected)

        function groups=getPropertyGroupsImpl
            abstractGroups=getPropertyGroupsImpl@AbstractSim3DTruthSensor;

            pSensorIdentifier=matlab.system.display.internal.Property('SensorIdentifier',...
            'Description',"Unique identifier of sensor");
            pVehicleIdentifier=matlab.system.display.internal.Property('VehicleIdentifier',...
            'Description',"Unique identifier of parent vehicle");
            idList={pSensorIdentifier,pVehicleIdentifier,'UpdateInterval'};
            idSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'abstractDetectionGenerator','SensorIdentification',idList);

            pTranslation=matlab.system.display.internal.Property('Translation');
            pRotation=matlab.system.display.internal.Property('Rotation');

            extList={pTranslation,pRotation};
            extSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'abstractDetectionGenerator','SensorExtrinsics',extList);

            pDetectionRange=matlab.system.display.internal.Property('DetectionRange');
            detList={...
            'FieldOfView',pDetectionRange,'RangeRateLimits',...
            'DetectionProbability','FalseAlarmRate','ReferenceRange','ReferenceRCS'};
            detSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'radarDetectionGenerator','DetectorSettings',detList);

            resList={'AzimuthResolution','ElevationResolution',...
            'RangeResolution','RangeRateResolution'};
            resSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'radarDetectionGenerator','AccuracySettings',resList);

            biasList={...
            'AzimuthBiasFraction','ElevationBiasFraction','RangeBiasFraction',...
            'RangeRateBiasFraction'};
            biasSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'radarDetectionGenerator','BiasSettings',biasList);

            outSection=abstractGroups(1);

            portsSection=abstractGroups(2);

            mainGroup=matlab.system.display.SectionGroup(...
            'Title',getString(message('driving:abstractDetectionGenerator:GroupParameters')),...
            'Sections',[idSection,extSection,portsSection,outSection]);

            pHasNoise=matlabshared.tracking.internal.getPropertyDescription('driving',...
            'abstractDetectionGenerator','HasNoise');
            measList={'HasElevation','HasRangeRate',pHasNoise,'HasFalseAlarms'};
            measSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'radarDetectionGenerator','MeasurementSettings',measList);

            randSection=abstractGroups(3);

            measGroup=matlab.system.display.SectionGroup(...
            'Title',getString(message('driving:abstractDetectionGenerator:GroupMeasurements')),...
            'Sections',[resSection,biasSection,detSection,measSection,randSection]);

            groups=[mainGroup,measGroup];
        end

        function header=getHeaderImpl
            header=matlab.system.display.Header(...
            'Title','driving:block:radarDetectionGeneratorTitle',...
            'Text','driving:block:radarDetectionGeneratorDesc');
        end
    end

    methods
        function obj=Simulation3DRadarTruthSensor(varargin)
            obj@AbstractSim3DTruthSensor(varargin{:});
        end
    end

    methods(Hidden)
        function[vehicleLength,vehicleOverhang]=getVehicleDims(obj,blockPath)
            vehicleID=obj.VehicleIdentifier;
            vehicleType='SimulinkVehicle';
            if~contains(vehicleID,vehicleType)
                vehicleType='Custom';
            end
            allVehicleOverhangs=struct('MuscleCar',0.945,...
            'Sedan',1.119,...
            'Hatchback',0.589,...
            'SmallPickupTruck',1.321,...
            'SportUtilityVehicle',0.939);
            hVehBlk=sim3d.utils.SimPool.getActorBlock(blockPath,vehicleType,vehicleID);
            if isempty(hVehBlk)
                error('Sensor not connected to a vehicle');
            end
            vehicleMesh=sim3d.utils.internal.StringMap.fwd(get_param(hVehBlk,'PassVehMesh'));
            vehicleLength=double(sim3d.auto.internal.(vehicleMesh).FrontBumper.translation(1)-sim3d.auto.internal.(vehicleMesh).RearBumper.translation(1));
            vehicleOverhang=allVehicleOverhangs.(vehicleMesh);
        end

        function[sensorType,sensorIndex,fovAzimuth,maxRange,orientation,...
            location,detCoordSys,detOffset]=getSensorExtrinsicsForBES(obj,blockPath)


            sensorType='RADAR';
            sensorIndex=double(obj.SensorIdentifier);
            fovAzimuth=obj.FieldOfView(1);
            maxRange=obj.DetectionRange(end);
            orientation=double(obj.Rotation).*[1,1,-1];

            [vehicleLength,vehicleOverhang]=obj.getVehicleDims(blockPath);
            xOffset=vehicleLength/2-vehicleOverhang;
            location=[obj.Translation(1)+xOffset,-obj.Translation(2)];

            detCoordSys=['Sim3D ',obj.DetectionCoordinates];
            detOffset=[xOffset,0,0];
        end

    end

    methods(Access=protected)


        function[det,argsToBus]=defaultOutput(obj)

            lenMeas=getNumMeasOut(obj);
            attribs={'TargetIndex',0,'SNR',0};
            addMeasParams=struct('HasElevation',obj.HasElevation,'HasVelocity',obj.HasRangeRate);
            det=assembleDetections(obj,0,zeros(lenMeas,1),zeros(lenMeas),attribs,addMeasParams);

            numDets=0;
            isValidTime=false;
            argsToBus={numDets,isValidTime};
        end


        function numMeas=getNumMeasDims(obj)
            numMeas=2;
            numMeas=numMeas+obj.HasElevation+obj.HasRangeRate;
        end



        function numMeas=getNumMeasOut(obj)


            if strcmp(obj.DetectionCoordinates,'Sensor spherical')
                numMeas=getNumMeasDims(obj);
            else

                numMeas=3;
                if obj.HasRangeRate
                    numMeas=numMeas+3;
                end
            end
        end

        function setupImpl(obj)
            if isempty(obj.NumberOfRays)
                [obj.NumberOfRays,rayStart,rayEnd]=obj.createSphericalRayProjection();
            end

            setupImpl@AbstractSim3DTruthSensor(obj);

            if~isempty(obj.pSim3DSensor)
                obj.pSim3DSensor.write(rayStart,rayEnd,single(obj.Translation),single(deg2rad(obj.Rotation)));
                obj.plotRayProjection(rayStart,rayEnd);
            end
        end

        function resetImpl(obj)
            [obj.NumberOfRays,rayStart,rayEnd]=obj.createSphericalRayProjection();
            resetImpl@AbstractSim3DTruthSensor(obj);

            if coder.target('MATLAB')
                if~isempty(obj.pSim3DSensor)
                    obj.pSim3DSensor.write(rayStart,rayEnd,single(obj.Translation),single(deg2rad(obj.Rotation)));
                end
            end
        end

        function varargout=stepImpl(obj)
            time=getCurrentTime(obj);
            dT=obj.getSampleTime().SampleTime;

            [detections,numDets]=initializeDetections(obj);



            elapsedInterval=time-obj.pTimeLastUpdate;
            numInts=round(elapsedInterval/dT);
            timeOffset=elapsedInterval-numInts*dT;

            validUpdateTime=~obj.pHasFirstUpdate||...
            ((time>obj.pTimeLastUpdate)&&(abs(timeOffset)<=obj.pUpdateIntervalTolerance));

            if validUpdateTime
                [numDets,xPts,vPts,rcsdB,tgtIDs]=generatePointTargets(obj);
                if numDets>0
                    [azTgt,elTgt,rngTgt,rrTgt,rcsdB,tgtIDs]=computeRadarTruth(obj,xPts,vPts,rcsdB,tgtIDs);
                    [dets,covMats,snrdB,tgtIDs]=generateRadarDetections(obj,azTgt,elTgt,rngTgt,rrTgt,rcsdB,tgtIDs);
                    [detsFAs,covMatsFAs,snrdBFAs,tgtIDsFAs]=addFalseAlarms(obj,dets,covMats,snrdB,tgtIDs);


                    numDets=length(tgtIDsFAs);
                    if strcmp(obj.MaxNumDetectionsSource,'Property')
                        numDets=min(numDets,obj.MaxNumDetections);
                    end



                    if numDets>0



                        if strcmp(obj.MaxNumDetectionsSource,'Auto')
                            detections=repmat(defaultOutput(obj),numDets,1);
                        end




                        rngIdx=getMeasIdx(obj,'rng');
                        range=detsFAs(rngIdx,:);
                        [~,iSrt]=sort(range);
                        detsFAs=detsFAs(:,iSrt);
                        covMatsFAs=covMatsFAs(:,:,iSrt);
                        tgtIDsFAs=tgtIDsFAs(iSrt);
                        snrdBFAs=snrdBFAs(iSrt);



                        detsFAs=detsFAs(:,1:numDets);
                        covMatsFAs=covMatsFAs(:,:,1:numDets);
                        tgtIDsFAs=tgtIDsFAs(1:numDets);
                        snrdBFAs=snrdBFAs(1:numDets);


                        switch obj.DetectionCoordinates
                        case 'Sensor Cartesian'
                            [detsCoords,covMatsCoords]=sensorSphToCart(obj,detsFAs,covMatsFAs);
                        case 'Ego Cartesian'
                            [detCart,covCart]=sensorSphToCart(obj,detsFAs,covMatsFAs);
                            [detsCoords,covMatsCoords]=sensorToEgo(obj,detCart,covCart);
                        otherwise
                            detsCoords=detsFAs;
                            covMatsCoords=covMatsFAs;
                        end


                        attribs={'TargetIndex',tgtIDsFAs,'SNR',snrdBFAs};
                        addMeasParams=struct('HasElevation',obj.HasElevation,'HasVelocity',obj.HasRangeRate);
                        detsAssigned=assembleDetections(obj,time,detsCoords,covMatsCoords,attribs,addMeasParams);
                        for m=1:numDets
                            detections{m}=detsAssigned{m};
                        end
                        detections=reshape(detections,[],1);
                    end


                    obj.pHasFirstUpdate=true;
                    obj.pTimeLastUpdate=time;
                end
            end

            if isBusPropagated(obj)
                detectionsOut=sendToBus(obj,detections,numDets,validUpdateTime);
            else
                detectionsOut=detections;
            end

            varargout{1}=detectionsOut;
            if~isBusPropagated(obj)
                varargout{2}=numDets;
                varargout{3}=validUpdateTime;
            end
        end
    end

    methods(Hidden,Access=public)
        function[nRays,rayStart,rayEnd]=createSphericalRayProjection(obj)
            Az=AbstractSim3DTruthSensor.SphericalSpace(obj.FieldOfView(1),obj.AzimuthResolution);
            El=AbstractSim3DTruthSensor.SphericalSpace(obj.FieldOfView(2),obj.ElevationResolution);

            [Az,El]=meshgrid(Az,El');

            if numel(obj.DetectionRange)~=1
                minRange=obj.DetectionRange(1);
                maxRange=obj.DetectionRange(2);
            else
                minRange=0;
                maxRange=obj.DetectionRange;
            end

            rayStart=AbstractSim3DTruthSensor.SphereToCart(Az,El,minRange);
            rayEnd=AbstractSim3DTruthSensor.SphereToCart(Az,El,maxRange);
            nRays=size(rayStart,1);
        end
    end

    methods(Access=private)
        function plotRayProjection(obj,rayStart,rayEnd)
            if(obj.DisplayProjection)
                X=rayStart(:,1);
                Y=rayStart(:,2);
                Z=rayStart(:,3);
                U=rayEnd(:,1);
                V=rayEnd(:,2);
                W=rayEnd(:,3);

                U=U-X;
                V=V-Y;
                W=W-Z;

                figure;
                plot3(0,0,0,'rx');
                hold('on');
                quiver3(X,Y,Z,U,V,W,0);
                title('Spherical Projection');
                xlabel('X (m), Range (m)');
                ylabel('Y (m), Azimuth (deg)');
                zlabel('Z (m), Elevation (deg)');
                set(gca,'YDir','reverse');
                grid('on');
                axis('equal');
                cameratoolbar('SetMode','orbit');
            end
        end

        function[dets,covMats,snrOut,tgtIDsOut]=generateRadarDetections(obj,azTgt,elTgt,rngTgt,rrTgt,rcsdB,tgtIDs)


            if isempty(tgtIDs)
                numMeas=getNumMeasDims(obj);
                dets=zeros(numMeas,0);
                covMats=zeros(numMeas,numMeas,0);
                snrOut=zeros(1,0);
                tgtIDsOut=zeros(1,0);
                return
            end



            snrdB=obj.RadarLoopGain+rcsdB(:)-40*log10(rngTgt(:));
            snr=driving.internal.db2pow(snrdB);


            [resCells,uCells]=getResolutionCells(obj,azTgt,elTgt,rngTgt,rrTgt);
            numResolved=size(uCells,1);


            [azEst,elEst,rngEst,rrEst]=addNoiseToPointTargets(obj,snrdB,azTgt,elTgt,rngTgt,rrTgt);


            numMeas=getNumMeasDims(obj);
            dets=zeros(numMeas,numResolved);
            covMats=zeros(numMeas,numMeas,numResolved);
            tgtIDsOut=NaN(1,numResolved);
            snrOut=NaN(1,numResolved);

            azIdx=getMeasIdx(obj,'az');
            elIdx=getMeasIdx(obj,'el');
            rngIdx=getMeasIdx(obj,'rng');
            rrIdx=getMeasIdx(obj,'rr');


            obj.pTargetPds=NaN(numResolved,1);

            numDets=0;
            for iCell=1:numResolved

                iTgts=find(all(bsxfun(@eq,uCells(iCell,:),resCells),2));

                if isempty(iTgts)
                    continue
                end


                [~,iMax]=max(snrdB(iTgts));
                cellSNR=sum(snr(iTgts));
                cellSNRdB=driving.internal.pow2db(cellSNR);



                if obj.DetectionProbability==1
                    Pd=1;
                else
                    Pd=getPd(obj,cellSNRdB);
                end


                obj.pTargetPds(iCell)=Pd;

                rnddraw=randdraw(obj);
                if rnddraw<Pd
                    numDets=numDets+1;

                    tgtIDsOut(numDets)=tgtIDs(iTgts(iMax));
                    snrOut(numDets)=cellSNRdB;






                    azMerged=centroid(obj,azEst(iTgts),snr(iTgts));
                    azSig=getAzimuthSigma(obj,cellSNR);
                    dets(azIdx,numDets)=azMerged;
                    covMats(azIdx,azIdx,numDets)=azSig^2;

                    if obj.HasElevation
                        elMerged=centroid(obj,elEst(iTgts),snr(iTgts));
                        elSig=getElevationSigma(obj,cellSNR);
                        dets(elIdx,numDets)=elMerged;
                        covMats(elIdx,elIdx,numDets)=elSig^2;
                    end

                    rngMerged=centroid(obj,rngEst(iTgts),snr(iTgts));
                    rngSig=getRangeSigma(obj,cellSNR);
                    dets(rngIdx,numDets)=rngMerged;
                    covMats(rngIdx,rngIdx,numDets)=rngSig^2;

                    if obj.HasRangeRate
                        rrMerged=centroid(obj,rrEst(iTgts),snr(iTgts));
                        rrSig=getRangeRateSigma(obj,cellSNR);
                        dets(rrIdx,numDets)=rrMerged;
                        covMats(rrIdx,rrIdx,numDets)=rrSig^2;
                    end
                end
            end

            dets=dets(:,1:numDets);
            covMats=covMats(:,:,1:numDets);
            tgtIDsOut=tgtIDsOut(1:numDets);
            snrOut=snrOut(1:numDets);
        end

        function[azEst,elEst,rngEst,rrEst]=addNoiseToPointTargets(obj,snrdB,azTgt,elTgt,rngTgt,rrTgt)
            snr=driving.internal.db2pow(snrdB);
            numTgts=numel(snr);

            azEst=azTgt;
            if obj.HasNoise
                azSig=getAzimuthSigma(obj,snr);
                azEst=azEst+azSig.*randn(obj,numTgts,1);
            end

            elEst=[];
            if obj.HasElevation
                elEst=elTgt;
                if obj.HasNoise
                    elSig=getElevationSigma(obj,snr);
                    elEst=elEst+elSig.*randn(obj,numTgts,1);
                end
            end

            rngEst=rngTgt;
            if obj.HasNoise
                rngSig=getRangeSigma(obj,snr);
                rngEst=rngEst+rngSig.*randn(obj,numTgts,1);
            end

            rrEst=[];
            if obj.HasRangeRate
                rrEst=rrTgt;
                if obj.HasNoise
                    rrSig=getRangeRateSigma(obj,snr);
                    rrEst=rrEst+rrSig.*randn(obj,numTgts,1);
                end
            end
        end

        function[resCells,uCells]=getResolutionCells(obj,azEst,elEst,rngEst,rrEst)


            azCells=roundres(obj,azEst,obj.AzimuthResolution);
            rngCells=roundres(obj,rngEst,obj.RangeResolution);
            resCells=[azCells,rngCells];
            if obj.HasElevation
                elCells=roundres(obj,elEst,obj.ElevationResolution);
                resCells=[resCells,elCells];
            end
            if obj.HasRangeRate
                rrCells=roundres(obj,rrEst,obj.RangeRateResolution);
                resCells=[resCells,rrCells];
            end
            uCells=unique(resCells,'rows');
        end

        function[azTgt,elTgt,rngTgt,rrTgt,rcsdB,tgtIDs]=computeRadarTruth(obj,xPts,vPts,rcsdB,tgtIDs)



            azTgt=[];
            elTgt=[];
            rngTgt=[];
            rrTgt=[];
            if~isempty(tgtIDs)


                [azTgt,elTgt,rngTgt]=cart2sph(xPts(1,:),xPts(2,:),xPts(3,:));
                azTgt=rad2deg(azTgt)';
                elTgt=rad2deg(elTgt)';
                rngTgt=rngTgt';

                len=max(rngTgt(:),eps('double'))';
                runit=bsxfun(@rdivide,xPts,len);
                rrTgt=dot(vPts,runit)';


                if obj.HasRangeRate
                    inRangeRate=rrTgt>=obj.RangeRateLimits(1)&rrTgt<=obj.RangeRateLimits(2);
                    tgtIDs=tgtIDs(inRangeRate);
                    rcsdB=rcsdB(inRangeRate);
                    azTgt=azTgt(inRangeRate);
                    elTgt=elTgt(inRangeRate);
                    rngTgt=rngTgt(inRangeRate);
                    rrTgt=rrTgt(inRangeRate);
                end
            end
        end

        function[numTgts,xPts,vPts,rcsdB,tgtIDs]=generatePointTargets(obj)


            [ClassIDs,~,ImpactPoints,~,RelativeAngles,Velocities]=obj.pSim3DSensor.read();

            numTgts=nnz(ClassIDs);
            tgts=ClassIDs>0;
            xPts=ImpactPoints(:,tgts);
            vPts=Velocities(:,tgts);
            tgtIDs=ClassIDs(:,tgts);

            rcsdB=zeros(numTgts,1);
            for i=1:numTgts
                theta=mod(RelativeAngles(1,i),pi);
                phi=mod(RelativeAngles(2,i),2*pi);




                rcsdB(i)=sim3d.utils.internal.RadarProfileManager.interpolatedRCS(...
                tgtIDs(i),theta,phi);
            end
        end


        function sigma=getRangeSigma(obj,snr)





            fn=sqrt(12)./sqrt(8*pi^2*snr);
            fb=obj.RangeBiasFraction;
            sigma=obj.RangeResolution*sqrt(fn.^2+fb.^2);
        end

        function sigma=getAzimuthSigma(obj,snr)


            fn=1./(1.6*sqrt(2*snr));
            fb=obj.AzimuthBiasFraction;
            sigma=obj.AzimuthResolution*sqrt(fn.^2+fb.^2);
        end

        function sigma=getElevationSigma(obj,snr)


            fn=1./(1.6*sqrt(2*snr));
            fb=obj.ElevationBiasFraction;
            sigma=obj.ElevationResolution*sqrt(fn.^2+fb.^2);
        end

        function sigma=getRangeRateSigma(obj,snr)


            fn=sqrt(6)./sqrt((2*pi)^2*snr);
            fb=obj.RangeRateBiasFraction;
            sigma=obj.RangeRateResolution*sqrt(fn.^2+fb.^2);
        end

        function[detsOut,covmatsOut,snrOut,tgtIDsOut]=addFalseAlarms(obj,dets,covmats,snr,tgtIDs)


            if~obj.HasFalseAlarms
                detsOut=dets;
                covmatsOut=covmats;
                snrOut=snr;
                tgtIDsOut=tgtIDs;
                return
            end

            maxRange=obj.DetectionRange(end);

            numRng=maxRange/obj.RangeResolution;
            numAz=obj.FieldOfView(1)/obj.AzimuthResolution;
            if obj.HasElevation
                numEl=obj.FieldOfView(2)/obj.ElevationResolution;
            else
                numEl=1;
            end
            if obj.HasRangeRate
                numRate=diff(obj.RangeRateLimits)/obj.RangeRateResolution;
            else
                numRate=1;
            end
            numCells=numRng*numAz*numEl*numRate;

            numFalse=numCells*obj.FalseAlarmRate;
            fracNumFalse=rem(numFalse,1);
            rnddraw=randdraw(obj);
            numFalse=floor(numFalse)+(rnddraw<fracNumFalse);

            if numFalse>0
                numDets=size(dets,2);
                newDets=numDets+numFalse;

                numMeas=getNumMeasDims(obj);

                detsOut=zeros(numMeas,newDets,'like',dets);
                covmatsOut=zeros(numMeas,numMeas,newDets,'like',covmats);
                snrOut=zeros(1,newDets,'like',snr);
                tgtIDsOut=zeros(1,newDets,'like',tgtIDs);

                detsOut(1:numMeas,1:numDets)=dets(:,:);
                covmatsOut(1:numMeas,1:numMeas,1:numDets)=covmats(:,:,:);
                snrOut(1:numDets)=snr;
                tgtIDsOut(1:numDets)=tgtIDs;

                azIdx=getMeasIdx(obj,'az');
                elIdx=getMeasIdx(obj,'el');
                rngIdx=getMeasIdx(obj,'rng');
                rrIdx=getMeasIdx(obj,'rr');



                snr=driving.internal.albersheim(obj.DetectionProbability,obj.FalseAlarmRate);
                snrOut(numDets+1:end)=snr;
                tgtIDsOut(numDets+1:end)=-(1:numFalse);


                range=rand(obj,numFalse,1)*maxRange;
                sigRng=getRangeSigma(obj,snr);
                detsOut(rngIdx,numDets+1:end)=range;
                covmatsOut(rngIdx,rngIdx,numDets+1:end)=sigRng.^2;

                az=(rand(obj,numFalse,1)-0.5)*obj.FieldOfView(1);
                sigAz=getAzimuthSigma(obj,snr);
                detsOut(azIdx,numDets+1:end)=az;
                covmatsOut(azIdx,azIdx,numDets+1:end)=sigAz.^2;

                if obj.HasElevation
                    el=(rand(obj,numFalse,1)-0.5)*obj.FieldOfView(2);
                    sigEl=getElevationSigma(obj,snr);
                    detsOut(elIdx,numDets+1:end)=el;
                    covmatsOut(elIdx,elIdx,numDets+1:end)=sigEl.^2;
                end
                if obj.HasRangeRate
                    span=diff(obj.RangeRateLimits);
                    cntr=mean(obj.RangeRateLimits);
                    rate=(rand(obj,numFalse,1)-0.5)*span+cntr;
                    sigRate=getRangeRateSigma(obj,snr);
                    detsOut(rrIdx,numDets+1:end)=rate;
                    covmatsOut(rrIdx,rrIdx,numDets+1:end)=sigRate.^2;
                end
            else
                detsOut=dets;
                covmatsOut=covmats;
                snrOut=snr;
                tgtIDsOut=tgtIDs;
            end
        end

        function[measCart,covCart]=sensorSphToCart(obj,measSph,covSph)

            hasCov=nargin>2;
            numDet=size(measSph,2);

            rgIdx=getMeasIdx(obj,'rng');
            rg=measSph(rgIdx,:);

            azIdx=getMeasIdx(obj,'az');
            az=measSph(azIdx,:);

            elIdx=getMeasIdx(obj,'el');

            azElRgCov=zeros(3,3,numDet);

            if elIdx>0
                el=measSph(elIdx,:);
                if hasCov
                    azElRgCov=covSph([azIdx,elIdx,rgIdx],[azIdx,elIdx,rgIdx],:);
                end
            else

                el=zeros(1,numDet);
                if hasCov
                    azElRgCov(1,1,:)=covSph(azIdx,azIdx,:);
                    azElRgCov(3,3,:)=covSph(rgIdx,rgIdx,:);
                    fov=obj.FieldOfView;
                    elCov=(fov(2)/sqrt(12))^2;
                    azElRgCov(2,2,:)=elCov;
                end
            end

            [x,y,z]=sph2cart(deg2rad(az),deg2rad(el),rg);
            posCart=[x;y;z];

            rrIdx=getMeasIdx(obj,'rr');


            if rrIdx>0
                rr=measSph(rrIdx,:);

                ur=bsxfun(@rdivide,posCart,rg);
                velCart=bsxfun(@times,rr,ur);
                measCart=[posCart;velCart];

                if hasCov
                    rrCov=covSph(rrIdx,rrIdx,:);





                    covCart=zeros(6,6,numDet);
                    for m=1:numDet
                        covPosVel=blkdiag(azElRgCov(:,:,m),rrCov(:,:,m));
                        [posCov,velCov]=matlabshared.tracking.internal.fusion.sph2cartcov(covPosVel,az(m),el(m),rg(m));
                        covCart(:,:,m)=blkdiag(posCov,velCov);
                    end
                end
            else
                measCart=posCart;
                if hasCov
                    covCart=zeros(3,3,numDet);
                    for m=1:numDet
                        posCov=matlabshared.tracking.internal.fusion.sph2cartcov(azElRgCov(:,:,m),az(m),el(m),rg(m));
                        covCart(:,:,m)=posCov;
                    end
                end
            end
        end

        function pd=getPd(obj,snrdB)
            roc=getROC(obj);

            pd=linearExtrap(obj,roc(:,1),roc(:,2),snrdB);


            pd=max(min(pd,1),0);
        end

        function snrdB=getSNR(obj,Pd)
            roc=getROC(obj);

            snrdB=linearExtrap(obj,roc(:,2),roc(:,1),Pd);
        end

        function roc=getROC(obj)



            minSNR=max(driving.internal.albersheim(0.1,obj.FalseAlarmRate),0);
            maxSNR=driving.internal.albersheim(0.9,obj.FalseAlarmRate);

            snrdB=linspace(minSNR-5,maxSNR+5,101);
            snrlin=10.^(snrdB./10);

            Pd=phasedfusion.internal.rocpdcalc(obj.FalseAlarmRate,...
            snrlin,1,'NonfluctuatingCoherent');

            roc=[snrdB(:),Pd(:)];
        end

        function idx=getMeasIdx(obj,meastype)
            idx=0;

            idx=idx+1;
            if meastype(1)=='a'
                return;
            end

            if obj.HasElevation
                idx=idx+1;
                if meastype(1)=='e'
                    return;
                end
            end

            idx=idx+1;
            if meastype(2)=='n'
                return;
            end

            if obj.HasRangeRate
                idx=idx+1;
                if meastype(2)=='r'
                    return;
                end
            end

            idx=-1;
        end
    end

    methods(Static)
        function busName=createBus(varargin)



















            busName=createBus@AbstractSim3DTruthSensor(varargin{:});
        end

        function fov=fieldOfView(varargin)











            fov=fieldOfView@AbstractSim3DTruthSensor(varargin{:});
        end

        function seed=lastInitialSeed(varargin)
















            seed=lastInitialSeed@AbstractSim3DTruthSensor(varargin{:});
        end
    end

    methods(Static,Hidden)
        function checkDetectionRange(detectionRange)
            validateattributes(detectionRange,...
            {'numeric'},{'vector','finite','real','positive'},...
            mfilename,'DetectionRange')
        end

        function checkDetectionProbability(detectionProbability)
            validateattributes(detectionProbability,...
            {'double','single'},{'scalar','real','>',0,'<=',1},...
            mfilename,'DetectionProbability');
        end

        function checkReferenceRange(referenceRange)
            validateattributes(referenceRange,...
            {'double','single'},{'scalar','finite','real','positive'},...
            mfilename,'ReferenceRange');
        end

        function checkReferenceRCS(referenceRCS)
            validateattributes(referenceRCS,...
            {'double','single'},{'scalar','finite','real'},...
            mfilename,'ReferenceRCS');
        end

        function checkFalseAlarmRate(falseAlarmRate)
            validateattributes(falseAlarmRate,...
            {'double','single'},{'scalar','finite','real','>=',1e-7,'<=',1e-3},...
            mfilename,'FalseAlarmRate');
        end

        function checkFieldOfView(fieldOfView)
            validateattributes(fieldOfView,...
            {'double','single'},{'row','numel',2,'finite','real','positive'},...
            mfilename,'FieldOfView');
        end

        function checkRangeResolution(rangeResolution)
            Simulation3DRadarTruthSensor.checkResolution(rangeResolution,'RangeResolution');
        end

        function checkRangeBiasFraction(rangeBiasFraction)
            Simulation3DRadarTruthSensor.checkBiasFraction(rangeBiasFraction,'RangeBiasFraction');
        end

        function checkAzimuthResolution(azimuthResolution)
            Simulation3DRadarTruthSensor.checkResolution(azimuthResolution,'AzimuthResolution');
        end

        function checkAzimuthBiasFraction(azimuthBiasFraction)
            Simulation3DRadarTruthSensor.checkBiasFraction(azimuthBiasFraction,'AzimuthBiasFraction');
        end

        function checkElevationResolution(elevationResolution)
            Simulation3DRadarTruthSensor.checkResolution(elevationResolution,'ElevationResolution');
        end

        function checkElevationBiasFraction(elevationBiasFraction)
            Simulation3DRadarTruthSensor.checkBiasFraction(elevationBiasFraction,'ElevationBiasFraction');
        end

        function checkRangeRateLimits(rangeRateLimits)
            validateattributes(rangeRateLimits,...
            {'double','single'},{'row','numel',2,'finite','real','increasing'},...
            mfilename,'RangeRateLimits');
        end

        function checkRangeRateResolution(rangeRateResolution)
            Simulation3DRadarTruthSensor.checkResolution(rangeRateResolution,'RangeRateResolution');
        end

        function checkRangeRateBiasFraction(rangeRateBiasFraction)
            Simulation3DRadarTruthSensor.checkBiasFraction(rangeRateBiasFraction,'RangeRateBiasFraction');
        end

        function checkResolution(res,name)
            validateattributes(res,...
            {'double','single'},{'scalar','finite','real','positive'},...
            mfilename,name);
        end

        function checkBiasFraction(bias,name)
            validateattributes(bias,...
            {'double','single'},{'scalar','finite','real','nonnegative'},...
            mfilename,name);
        end
    end
end