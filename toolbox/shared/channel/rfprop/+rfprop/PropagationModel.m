classdef(Abstract)PropagationModel<matlab.mixin.Heterogeneous




    methods(Access=protected)
        function pathlossOverDistance(varargin)
            error(message('shared_channel:rfprop:PropagationModelNoPathlossOverDistance'));
        end

        function pathlossOverTerrain(varargin)
            error(message('shared_channel:rfprop:PropagationModelNoPathlossOverTerrain'));
        end

        function pathlossMultipath(varargin)
            error(message('shared_channel:rfprop:PropagationModelNoMultiPathloss'));
        end
    end

    properties(Hidden,Constant)
        PropagationModelChoices={'freespace','rain','gas','fog','close-in','longley-rice','tirem','raytracing'}
    end

    methods
        function pm=PropagationModel(varargin)


            try

                rfprop.PropagationModel.initializePropModels;


                p=inputParser;
                allParamNames=string(properties(pm));
                if isa(pm,'rfprop.RayTracing')
                    allParamNames{end+1}='MaxNumDiffractions';
                end
                for k=1:numel(allParamNames)
                    p.addParameter(allParamNames(k),[]);
                end
                p.parse(varargin{:});


                nondefaultParamNames=setdiff(allParamNames,p.UsingDefaults);
                paramValues=p.Results;
                for k=1:numel(nondefaultParamNames)
                    paramName=nondefaultParamNames(k);
                    pm.(paramName)=paramValues.(paramName);
                end
            catch e
                throwAsCaller(e);
            end
        end

        function[pl,info]=pathloss(pm,rxs,txs,varargin)














































            validateattributes(pm,{'rfprop.PropagationModel'},...
            {'scalar'},'pathloss','',1);
            validateattributes(rxs,{'rxsite'},{'nonempty'},'pathloss','',2);
            validateattributes(txs,{'txsite'},{'nonempty'},'pathloss','',3);


            if~pm.includesFreeSpaceContribution
                pm=rfprop.FreeSpace+pm;
            end


            p=inputParser;
            p.addParameter('TerrainProfiles',[]);
            p.addParameter('Map',[]);
            p.addParameter('TransmitterAntennaSiteCoordinates',[]);
            p.addParameter('ReceiverAntennaSiteCoordinates',[]);
            p.addParameter('ComputeAngleOfArrival',true);
            p.parse(varargin{:});



            if isempty(p.Results.TransmitterAntennaSiteCoordinates)
                usingCartesian=rfprop.internal.Validators.validateCoordinateSystem(rxs,txs);
            else
                usingCartesian=strcmp(p.Results.TransmitterAntennaSiteCoordinates.CoordinateSystem,'cartesian');
            end


            if requiresTerrain(pm)&&usingCartesian
                error(message('shared_channel:rfprop:CartesianSiteInvalidPropagationModel'));
            end


            if usingCartesian
                map=rfprop.internal.Validators.validateCartesianMap(p);
            else
                map=rfprop.internal.Validators.validateMapTerrainSource(p,'pathloss');
            end


            if isMultipathModel(pm)

                pm.validateTransmitterSites(txs);
                pm.validateReceiverSites(rxs);

                [pl,info]=pathlossMultipath(pm,rxs,txs,map);
                return
            end


            txsCoords=rfprop.internal.Validators.validateAntennaSiteCoordinates(...
            p.Results.TransmitterAntennaSiteCoordinates,txs,map,'pathloss');
            rxsCoords=rfprop.internal.Validators.validateAntennaSiteCoordinates(...
            p.Results.ReceiverAntennaSiteCoordinates,rxs,map,'pathloss');


            [ds,txsAz,txsEl]=distanceangle(txs,rxs,'Map',map,...
            'SourceAntennaSiteCoordinates',txsCoords,...
            'TargetAntennaSiteCoordinates',rxsCoords);
            if p.Results.ComputeAngleOfArrival
                [rxsAz,rxsEl]=angle(rxs,txs,'Map',map,...
                'SourceAntennaSiteCoordinates',rxsCoords,...
                'TargetAntennaSiteCoordinates',txsCoords);
            else
                rxsAz=nan(numel(txs),numel(rxs));
                rxsEl=rxsAz;
            end


            if requiresTerrain(pm)
                terrainProfiles=p.Results.TerrainProfiles;
                rfprop.internal.Validators.validateTerrainAvailability(map,pm);
                if~isempty(terrainProfiles)
                    [pl,txsEl,rxsEl]=terrainPathlossUsingProfiles(pm,rxs,txs,ds,...
                    txsEl,txsCoords,rxsEl,rxsCoords,map,terrainProfiles);
                else
                    [pl,txsEl,rxsEl]=terrainPathloss(pm,rxs,txs,ds,...
                    txsEl,txsCoords,rxsEl,rxsCoords,map);
                end
            else
                pl=distancePathloss(pm,rxs,txs,ds,txsEl);
            end


            aodCell=cell(numel(txs),numel(rxs));
            aoaCell=aodCell;
            for txInd=1:numel(txs)
                for rxInd=1:numel(rxs)
                    aodCell{txInd,rxInd}=[txsAz(rxInd,txInd);txsEl(rxInd,txInd)];
                    aoaCell{txInd,rxInd}=[rxsAz(txInd,rxInd);rxsEl(txInd,rxInd)];
                end
            end
            info=struct(...
            'PropagationDistance',num2cell(ds'),...
            'AngleOfDeparture',aodCell,...
            'AngleOfArrival',aoaCell);
        end

        function pm3=add(pm1,pm2)











































            validateattributes(pm1,{'rfprop.PropagationModel'},{'scalar'},'add','',1);
            validateattributes(pm2,{'rfprop.PropagationModel'},{'scalar'},'add','',2);
            pm3=pm1+pm2;
        end

        function r=range(pm,txs,pl)












            validateattributes(pm,{'rfprop.PropagationModel'},...
            {'scalar'},'range','',1);
            validateattributes(txs,{'txsite'},{'nonempty'},'range','',2);
            validateattributes(pl,{'numeric'},...
            {'real','finite','nonnan','scalar','nonsparse'},'range','',3);


            pm.validateTransmitterSites(txs);

            if requiresTerrain(pm)||isMultipathModel(pm)
                error(message('shared_channel:rfprop:PropagationModelNoRange'));
            end


            if~pm.includesFreeSpaceContribution
                pm=rfprop.FreeSpace+pm;
            end





            el=0;


            rx=rxsite('Name','internal.rangesite');

            numTx=numel(txs);
            r=zeros(numTx,1);
            for txInd=1:numel(txs)
                tx=txs(txInd);




                fq=tx.TransmitterFrequency;
                dmin=0;
                dmax=rfprop.FreeSpace.fsrange(fq,pl);




                plmax=pathlossOverDistance(pm,rx,tx,dmax,el);
                if plmax<=pl


                    maxrange=dmax;
                else
                    objfcn=@(df)pl-pathlossOverDistance(pm,rx,tx,df,el);
                    opts=optimset('TolX',1e-5);
                    maxrange=fzero(objfcn,[dmin,dmax],opts);
                end
                r(txInd)=validateRange(pm,maxrange);
            end
        end
    end

    methods(Access=protected)
        function pm=pathlossSetup(pm,varargin)


        end

        function pl=distancePathloss(pm,rxs,txs,ds,els)



            pm.validateTransmitterSites(txs);
            pm.validateReceiverSites(rxs);





            if any(ds>rfprop.Constants.MaxPropagationDistance)
                maxPropDistance=rfprop.Constants.MaxPropagationDistance;
                error(message('shared_channel:rfprop:PathlossDistanceGreaterThanMax',round(maxPropDistance/1000)));
            end


            pm=pm.pathlossSetup(rxs,txs);

            numTx=numel(txs);
            numRx=numel(rxs);
            pl=zeros(numTx,numRx);
            for txInd=1:numel(txs)
                tx=txs(txInd);





                d=ds(:,txInd)';
                el=els(:,txInd)';


                pl(txInd,:)=pathlossOverDistance(pm,rxs,tx,d,el);
            end
        end

        function[pl,txsAngles,rxsAngles]=terrainPathloss(pm,rxs,txs,ds,txsAngles,txsCoords,rxsAngles,rxsCoords,map)



            pm.validateTransmitterSites(txs);
            pm.validateReceiverSites(rxs);


            pm=pm.pathlossSetup(rxs,txs);

            numTx=numel(txs);
            numRx=numel(rxs);
            pl=zeros(numTx,numRx);
            res=terrainProfileResolution(pm,map);
            rxAntennaHts=rxsCoords.AntennaHeight;
            for txInd=1:numTx
                tx=txs(txInd);
                txCoords=txsCoords.extract(txInd);
                Z0=txCoords.SurfaceHeightAboveGeoid;


                dtx=ds(:,txInd)';
                txAngles=txsAngles(:,txInd)';
                rxAngles=rxsAngles(txInd,:);





                [lats,lons,actualResolutions,dgeos]=sampleGreatCircle(tx,rxs,res,'Map',map,...
                'SourceAntennaSiteCoordinates',txCoords,...
                'TargetAntennaSiteCoordinates',rxsCoords);
                validateTerrainPropagationDistance(pm,dgeos);


                if isnumeric(lats)
                    lats={lats};
                end
                if isnumeric(lons)
                    lons={lons};
                end
                numProfiles=numel(lats);
                profileLengths=zeros(numProfiles,1);
                allLats=[];
                allLons=[];
                for profileInd=1:numProfiles


                    profileLats=lats{profileInd};
                    profileLons=lons{profileInd};
                    profileLats=profileLats(2:end);
                    profileLons=profileLons(2:end);
                    profileLengths(profileInd)=numel(profileLats);


                    allLats=[allLats;profileLats];%#ok<AGROW>
                    allLons=[allLons;profileLons];%#ok<AGROW>
                end


                Zprofiles=rfprop.internal.AntennaSiteCoordinates.querySurfaceHeightAboveGeoid(allLats,allLons,map);

                profileInd=1;
                for rxInd=1:numRx
                    rx=rxs(rxInd);


                    profileIndEnd=profileInd+profileLengths(rxInd)-1;
                    Z=[Z0,Zprofiles(profileInd:profileIndEnd)'];
                    profileInd=profileIndEnd+1;

                    if dgeos(rxInd)==0


                        vertHt=txCoords.AntennaHeight-rxAntennaHts(rxInd);
                        d=abs(vertHt);
                        el=-90*sign(vertHt);
                        pl(txInd,rxInd)=pathlossOverVerticalDistance(pm,rx,tx,d,el);
                    else

                        d=dtx(rxInd);
                        txAngle=txAngles(rxInd);
                        rxAngle=rxAngles(rxInd);
                        actualRes=actualResolutions(rxInd);
                        [pl(txInd,rxInd),txsAngles(rxInd,txInd),rxsAngles(txInd,rxInd)]=...
                        pathlossOverTerrain(pm,rx,tx,actualRes,Z,d,txAngle,rxAngle);
                    end
                end
            end
        end

        function pl=pathlossOverVerticalDistance(pm,rx,tx,d,el)
            pl=pathlossOverDistance(pm,rx,tx,d,el);
        end

        function[pl,txsAngles,rxsAngles]=terrainPathlossUsingProfiles(pm,rxs,tx,ds,txsAngles,txCoords,rxsAngles,rxsCoords,map,terrainProfiles)



            pm.validateTransmitterSites(tx);
            pm.validateReceiverSites(rxs(1));


            pm=pm.pathlossSetup(rxs,tx);



            Zfirst=txCoords.SurfaceHeightAboveGeoid;


            dtx=ds';
            txAngles=txsAngles';
            rxAngles=rxsAngles;


            Zprofiles=terrainProfiles{1};
            res=terrainProfiles{2};
            skipFactor=terrainProfiles{3};
            numradials=numel(res);





            pl=zeros(1,numel(rxs));
            rxCounter=1;




            mapHasBuildings=isa(map,'siteviewer')&&map.HasBuildings;
            if mapHasBuildings
                rxGroundElevations=rxsCoords.GroundHeightAboveGeoid;
            end


            updateProgressDlg=isa(map,'siteviewer')&&~isempty(map.ProgressDialogHandle)&&...
            isvalid(map.ProgressDialogHandle)&&strcmp(map.ProgressDialogHandle.Indeterminate,'off');
            if updateProgressDlg
                txInd=txCoords.CustomData.TxInd;
                txsNumRadials=txCoords.CustomData.NumRadials;
                totalNumRadials=sum(txsNumRadials);
                numPreviousTxsRadials=sum(txsNumRadials(1:txInd-1));
            end

            for radInd=1:numradials
                Zprofile=Zprofiles{radInd};
                radres=res(radInd);


                rxIndEnd=rxCounter+numel(Zprofile(1:skipFactor:end))-1;

                for rxInd=rxCounter:rxIndEnd

                    rxRankInProfile=rxInd-rxCounter+1;
                    rxIndInProfile=(rxRankInProfile-1)*skipFactor+1;
                    if mapHasBuildings
                        Z=[Zfirst;Zprofile(1:rxIndInProfile-1);rxGroundElevations(rxInd)]';
                    else
                        Z=[Zfirst;Zprofile(1:rxIndInProfile)]';
                    end


                    d=dtx(rxInd);
                    txAngle=txAngles(rxInd);
                    rxAngle=rxAngles(rxInd);
                    [pl(1,rxInd),txsAngles(rxInd,1),rxsAngles(1,rxInd)]=...
                    pathlossOverTerrain(pm,rxs(rxInd),tx,radres,Z,d,txAngle,rxAngle);
                end
                rxCounter=rxIndEnd+1;

                if updateProgressDlg

                    if map.ProgressDialogHandle.CancelRequested
                        error(message('shared_channel:rfprop:ProgressDialogCancelled'));
                    end


                    thisIdx=numPreviousTxsRadials+radInd;
                    if mod(thisIdx,rfprop.Constants.ProgressDialogUpdateSkipFactor)==0
                        map.ProgressDialogHandle.Value=thisIdx/totalNumRadials;
                    end
                end
            end
        end
    end

    methods(Hidden)
        function pmNew=plus(pm,pmOther)
            pmNew=rfprop.CompositePropagationModel(pm,pmOther);
        end


        function rt=requiresTerrain(~)
            rt=false;
        end

        function rt=isMultipathModel(~)
            rt=false;
        end

        function res=terrainProfileResolution(varargin)
            res=Inf;
        end
    end

    methods(Access={?rfprop.PropagationModel,?rfprop.AntennaSite})
        function validateReceiverSites(pm,rxs)


            try
                rxHts=[rxs.AntennaHeight];
                validateReceiverHeights(pm,rxHts);
            catch e
                throwAsCaller(e);
            end
        end

        function validateTransmitterSites(pm,txs)


            try
                fqs=[txs.TransmitterFrequency];
                txHts=[txs.AntennaHeight];

                validateFrequency(pm,fqs);
                validateTransmitterHeights(pm,txHts);
            catch e
                throwAsCaller(e);
            end
        end
    end

    methods(Access=protected)
        function fs=includesFreeSpaceContribution(pm)
            fs=~(isa(pm,'rfprop.Rain')||isa(pm,'rfprop.Gas')||isa(pm,'rfprop.Fog'));
        end

        function lim=frequencyLimits(~)
            lim=[0,Inf];
        end

        function lim=antennaHeightLimits(~)
            lim=[0,rfprop.Constants.MaxPropagationDistance];
        end

        function validateFrequency(pm,fqs)


            try
                fqlim=pm.frequencyLimits;
                if any(fqs<fqlim(1))
                    error(message('shared_channel:rfprop:TransmitterFrequencyTooLow',sprintf('%.1e',fqlim(1))));
                elseif any(fqs>fqlim(2))
                    error(message('shared_channel:rfprop:TransmitterFrequencyTooGreat',sprintf('%.1e',fqlim(2))));
                end
            catch e
                throwAsCaller(e);
            end
        end

        function validateTransmitterHeights(pm,txHeights)


            try
                htlim=pm.antennaHeightLimits;
                if any(txHeights<htlim(1))
                    error(message('shared_channel:rfprop:TransmitterHeightTooLow',mat2str(htlim(1))));
                elseif any(txHeights>htlim(2))
                    error(message('shared_channel:rfprop:TransmitterHeightTooGreat',mat2str(htlim(2))));
                end
            catch e
                throwAsCaller(e);
            end
        end

        function validateReceiverHeights(pm,rxHeights)


            try
                htlim=pm.antennaHeightLimits;
                if any(rxHeights<htlim(1))
                    error(message('shared_channel:rfprop:ReceiverHeightTooLow',mat2str(htlim(1))));
                elseif any(rxHeights>htlim(2))
                    error(message('shared_channel:rfprop:ReceiverHeightTooGreat',mat2str(htlim(2))));
                end
            catch e
                throwAsCaller(e);
            end
        end

        function validateTerrainPropagationDistance(~,dgc)


            try



                dgc=dgc(:);
                maxPropDistance=rfprop.Constants.MaxPropagationDistanceUsingTerrain;
                if any(isnan(dgc))||any(dgc>maxPropDistance)
                    error(message('shared_channel:rfprop:PathlossDistanceGreaterThanTerrainMax',round(maxPropDistance/1000)));
                end
            catch e
                throwAsCaller(e);
            end
        end

        function maxrange=validateRange(~,maxrange)


            try

                maxPropDistance=rfprop.Constants.MaxPropagationDistance;
                if maxrange>maxPropDistance
                    maxrange=maxPropDistance;
                    warning(message('shared_channel:rfprop:RangeGreaterThanMax'));
                end
            catch e
                throwAsCaller(e);
            end
        end
    end

    methods(Static,Hidden)
        function initializePropModels


            products={'Antenna_Toolbox','Communication_Toolbox'};
            rfprop.PropagationModel.checkoutLicense(products);
        end

        function checkoutLicense(products)



            if isdeployed
                return
            end

            if~checkoutFirstAvailableLicense(products)
                if isempty(setdiff(products,{'Antenna_Toolbox','Phased_Array_System_Toolbox'}))
                    id='shared_channel:rfprop:NoAntennaPhasedLicense';
                else
                    id='shared_channel:rfprop:NoAntennaCommsLicense';
                end
                throwAsCaller(MException(id,getString(message(id))));
            end
        end

        function pmName=validateName(pmName,fcnName,paramName)


            try

                if startsWith(pmName,"close")&&startsWith("closein",pmName)
                    pmName="close-in";
                end


                if startsWith(pmName,"longley")&&startsWith("longleyrice",pmName)
                    pmName="longley-rice";
                end


                raytraceMatches=["ray tracing","ray-tracing","raytracing-"];



                raytraceImageMatches=[...
"raytracing-image-method"...
                ,"raytracingimagemethod"...
                ,"raytracing-imagemethod"...
                ,"raytracingimage-method"];

                if startsWith(pmName,"ray")&&any(startsWith(raytraceMatches,pmName))
                    pmName="raytracing";
                elseif startsWith(pmName,"ray")&&any(startsWith(raytraceImageMatches,pmName))
                    pmName="raytracing-image-method";
                    return;
                end


                validNames=rfprop.PropagationModel.PropagationModelChoices;
                if nargin>2
                    pmName=validatestring(pmName,validNames,fcnName,paramName);
                else
                    pmName=validatestring(pmName,validNames,fcnName);
                end
            catch e
                throwAsCaller(e);
            end
        end

        function v=choices
            v=rfprop.PropagationModel.PropagationModelChoices;
        end

        function d=distanceToHorizon(h)



            d=sqrt(2*rfprop.Constants.SphericalEarthRadius*h+h^2);
        end
    end
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