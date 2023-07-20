function tleSet=tledata(varargin)%#codegen

























































    coder.allowpcode('plain');

    tleSet=tle(varargin{:});
end

function tleSet=tle(varargin)

    if~((nargin==0)||(nargin==1)||(nargin==9))
        msg='shared_orbit:orbitPropagator:IncorrectTLEInputCount';
        if isempty(coder.target)
            error(message(msg));
        else
            coder.internal.error(msg);
        end
    end

    if nargin==0





        coder.internal.errorIf(~isempty(coder.target),'shared_orbit:orbitPropagator:TLEDataUnsupportedSyntaxCodegen');


        name="Default satellite";
        satelliteCatalogNumber=-1;
        epoch=datetime("now","TimeZone","UTC");
        bStar=0;
        inclination=0;
        rightAscensionOfAscendingNode=0;
        eccentricity=0;
        argumentOfPeriapsis=0;
        meanAnomaly=0;
        meanMotion=2*pi/(23*3600+56*60+4.0905);
    elseif nargin==1





        tleFile=varargin{1};
        validateattributes(tleFile,{'char','string'},...
        {'nonempty','scalartext'},'matlabshared.orbit.internal.tledata',...
        'tleFile',1);

        if coder.target('MATLAB')

            if~(exist(tleFile,'file')==2)
                msg=...
                message('shared_orbit:orbitPropagator:TLEFileNotFound',...
                tleFile);
                error(msg);
            end
        end


        fileID=fopen(tleFile,'r');
        if fileID==-1
            msgID='shared_orbit:orbitPropagator:TLEFileUnableOpen';
            if isempty(coder.target)
                msg=message(msgID,tleFile);
                error(msg);
            else
                coder.internal.error(msgID,tleFile);
            end
        end


        tleRawData=fscanf(fileID,'%c');


        tleRawData=erase(tleRawData,char(13));


        tleRawData=strtrim(tleRawData);


        newLineCount=0;
        for idx=1:length(tleRawData)
            if strcmp(tleRawData(idx),newline)
                newLineCount=newLineCount+1;
            end
        end
        newLineIdx=zeros(1,newLineCount);
        idx2=1;
        for idx=1:length(tleRawData)
            if strcmp(tleRawData(idx),newline)
                newLineIdx(idx2)=idx;
                idx2=idx2+1;
            end
        end


        if~strcmp(tleRawData(1),'1')

            numTLESets=((numel(newLineIdx)-2)/3)+1;
            twoLines=false;
        else
            numTLESets=((numel(newLineIdx)-1)/2)+1;
            twoLines=true;
        end


        if isempty(coder.target)
            try
                [name,satelliteCatalogNumber,epoch,bStar,inclination,...
                rightAscensionOfAscendingNode,eccentricity,...
                argumentOfPeriapsis,meanAnomaly,meanMotion]=...
                parseTLEFile(...
                numTLESets,twoLines,tleRawData,newLineIdx,tleFile);
            catch ME

                fclose(fileID);
                msg=message(...
                'shared_orbit:orbitPropagator:InvalidTLEFile',...
                tleFile);
                error(msg);
            end
        else

            [name,satelliteCatalogNumber,epoch,bStar,inclination,...
            rightAscensionOfAscendingNode,eccentricity,...
            argumentOfPeriapsis,meanAnomaly,meanMotion]=...
            parseTLEFile(numTLESets,twoLines,tleRawData,newLineIdx,...
            tleFile);
        end


        fclose(fileID);
    else






        name=string(varargin{1});
        satelliteCatalogNumber=-1;
        epoch=varargin{2};
        bStar=varargin{3};
        rightAscensionOfAscendingNode=mod(varargin{4},2*pi);
        eccentricity=varargin{5};
        inclination=mod(varargin{6},2*pi);
        argumentOfPeriapsis=mod(varargin{7},2*pi);
        meanAnomaly=mod(varargin{8},2*pi);
        meanMotion=varargin{9};


        if isempty(coder.target)
            epoch.TimeZone="UTC";
        end


        validateattributes(name,{'char','string'},...
        {'nonempty','scalartext'},...
        'matlabshared.orbit.internal.TLE','name',1);
        validateTLEData(epoch,bStar,rightAscensionOfAscendingNode,...
        eccentricity,inclination,argumentOfPeriapsis,meanAnomaly,...
        meanMotion)


        rightAscensionOfAscendingNode=...
        mod(rightAscensionOfAscendingNode,2*pi);
        inclination=mod(inclination,2*pi);
        argumentOfPeriapsis=mod(argumentOfPeriapsis,2*pi);
        meanAnomaly=mod(meanAnomaly,2*pi);



        if inclination>pi

            r3=sin(inclination)*sin(argumentOfPeriapsis);



            theta3=sin(inclination)*cos(argumentOfPeriapsis);

            argumentOfPeriapsis=atan2(r3,theta3);


            h1=sin(rightAscensionOfAscendingNode)*sin(inclination);


            h2=-cos(rightAscensionOfAscendingNode)*sin(inclination);
            rightAscensionOfAscendingNode=atan2(h1,-h2);


            h3=cos(inclination);
            inclination=acos(h3);
        end
    end


    tleSet=struct('Name',name,...
    'SatelliteCatalogNumber',satelliteCatalogNumber,...
    'Epoch',epoch,...
    'BStar',bStar,...
    'RightAscensionOfAscendingNode',rightAscensionOfAscendingNode,...
    'Eccentricity',eccentricity,...
    'Inclination',inclination,...
    'ArgumentOfPeriapsis',argumentOfPeriapsis,...
    'MeanAnomaly',meanAnomaly,...
    'MeanMotion',meanMotion);

    coder.varsize('tleSet');


    needToLoopBack=true;
    while needToLoopBack
        needToLoopBack=false;


        catalogNumbers=[tleSet.SatelliteCatalogNumber];


        for idx=1:numel(catalogNumbers)
            if~isnan(catalogNumbers(idx))&&catalogNumbers(idx)>0

                repeatCatalogNumberIndex=find(catalogNumbers(idx)==catalogNumbers');

                if numel(repeatCatalogNumberIndex)>1

                    repeatTLESet=tleSet(repeatCatalogNumberIndex);


                    epochs=NaT(1,numel(repeatTLESet));
                    if isempty(coder.target)
                        epochs.TimeZone="UTC";
                    end
                    for idx2=1:numel(repeatTLESet)
                        epochs(idx2)=repeatTLESet(idx2).Epoch;
                    end



                    [~,latestTLEIdx]=max(epochs);



                    repeatCatalogNumberIndex(latestTLEIdx)=[];




                    tleSet(repeatCatalogNumberIndex)=[];



                    needToLoopBack=true;
                    break
                end
            end
        end
    end
end

function[name,satelliteCatalogNumber,epoch,bStar,inclination,...
    rightAscensionOfAscendingNode,eccentricity,argumentOfPeriapsis,...
    meanAnomaly,meanMotion]=...
    parseTLEFile(numTLESets,twoLines,tleRawData,newLineIdx,tleFile)




    name=cell(numTLESets,1);
    satelliteCatalogNumber=cell(numTLESets,1);
    epoch=cell(numTLESets,1);
    bStar=cell(numTLESets,1);
    inclination=cell(numTLESets,1);
    rightAscensionOfAscendingNode=cell(numTLESets,1);
    eccentricity=cell(numTLESets,1);
    argumentOfPeriapsis=cell(numTLESets,1);
    meanAnomaly=cell(numTLESets,1);
    meanMotion=cell(numTLESets,1);







    rawDataIdx=0;
    msgID='shared_orbit:orbitPropagator:InvalidTLEFile';

    for idx=1:numTLESets

        if~twoLines
            titleLineEnd=newLineIdx(1+(idx-1)*3)-1;
            if idx==1
                titleLineStart=1;
            else
                titleLineStart=newLineIdx((idx-1)*3)+1;
            end
            rawDataIdx=rawDataIdx+titleLineEnd-titleLineStart+1;
            line1Start=newLineIdx(1+(idx-1)*3);
            rawDataIdx=rawDataIdx+71;
            line2Start=newLineIdx(2+(idx-1)*3);
            if rawDataIdx~=line2Start
                if isempty(coder.target)
                    msg=message(msgID,tleFile);
                    error(msg);
                else
                    coder.internal.error(msgID,tleFile);
                end
            end

            rawDataIdx=rawDataIdx+70;

            name{idx}=...
            string(strtrim(tleRawData(titleLineStart:titleLineEnd)));
        else
            line2Start=newLineIdx(1+(idx-1)*2);
            line1Start=line2Start-70;

            if(line1Start~=rawDataIdx)||(line2Start~=rawDataIdx+70)
                if isempty(coder.target)
                    msg=message(msgID,tleFile);
                    error(msg);
                else
                    coder.internal.error(msgID,tleFile);
                end
            end

            rawDataIdx=rawDataIdx+140;
            name{idx}="UNKNOWN";
        end


        satelliteCatalogNumber{idx}=...
        str2double(tleRawData(line1Start+3:line1Start+7));


        epochYear=...
        str2double(tleRawData(line1Start+19:line1Start+20));
        if epochYear>=57
            epochYear=1900+epochYear;
        else
            epochYear=2000+epochYear;
        end
        epochDay=str2double(tleRawData(line1Start+21:line1Start+32));
        secondsOfEpochDay=(epochDay-floor(epochDay))*24*3600;
        epoch{idx}=...
        datetime(epochYear,1,floor(epochDay),0,0,secondsOfEpochDay);


        if isempty(coder.target)
            epoch{idx}.TimeZone="UTC";
        end


        BStarCoeff=...
        real(str2double(tleRawData(line1Start+54)...
        +"0."+tleRawData(line1Start+55:line1Start+59)));
        BStarExp=real(str2double(tleRawData(line1Start+60:line1Start+61)));
        bStar{idx}=BStarCoeff*(10^BStarExp);


        inclination{idx}=real(str2double(tleRawData(line2Start+...
        9:line2Start+16))*pi/180);


        rightAscensionOfAscendingNode{idx}...
        =real(str2double(tleRawData(line2Start+18:line2Start+25))*pi/180);


        eccentricity{idx}=real(str2double("0."+tleRawData(line2Start...
        +27:line2Start+33)));


        argumentOfPeriapsis{idx}=real(str2double(tleRawData(line2Start+...
        35:line2Start+42))*pi/180);


        meanAnomaly{idx}=real(str2double(tleRawData(line2Start+...
        44:line2Start+51))*pi/180);


        meanMotion{idx}=real(str2double(tleRawData(line2Start+...
        53:line2Start+63))*2*pi/(24*60*60));
    end

    for idx=1:numTLESets

        validateTLEData(epoch{idx},bStar{idx},...
        rightAscensionOfAscendingNode{idx},eccentricity{idx},...
        inclination{idx},argumentOfPeriapsis{idx},meanAnomaly{idx},...
        meanMotion{idx})

        if coder.target('MATLAB')

            if isnat(epoch{idx})||...
                isnan(bStar{idx})||...
                isnan(inclination{idx})||...
                isnan(rightAscensionOfAscendingNode{idx})||...
                isnan(eccentricity{idx})||...
                isnan(argumentOfPeriapsis{idx})||...
                isnan(meanAnomaly{idx})||...
                isnan(meanMotion{idx})
                msg=message(...
                'shared_orbit:orbitPropagator:InvalidTLEFile',tleFile);
                error(msg);
            end
        end
    end
end

function validateTLEData(epoch,bStar,rightAscensionOfAscendingNode,...
    eccentricity,inclination,argumentOfPeriapsis,meanAnomaly,...
    meanMotion)
    validateattributes(epoch,{'datetime'},...
    {'finite','scalar'},...
    'matlabshared.orbit.internal.TLE','epoch');
    validateattributes(bStar,{'numeric'},...
    {'nonempty','scalar','real','finite'},...
    'matlabshared.orbit.internal.TLE','bStar');
    validateattributes(rightAscensionOfAscendingNode,...
    {'numeric'},...
    {'nonempty','scalar','real','finite'},...
    'matlabshared.orbit.internal.TLE',...
    'rightAscensionOfAscendingNode');
    validateattributes(eccentricity,{'numeric'},...
    {'nonempty','scalar','real','finite',...
    'nonnegative','<',1},...
    'matlabshared.orbit.internal.TLE','eccentricity');
    validateattributes(inclination,{'numeric'},...
    {'nonempty','scalar','real','finite'},...
    'matlabshared.orbit.internal.TLE','inclination');
    validateattributes(argumentOfPeriapsis,{'numeric'},...
    {'nonempty','scalar','real','finite'},...
    'matlabshared.orbit.internal.TLE','argumentOfPeriapsis');
    validateattributes(meanAnomaly,{'numeric'},...
    {'nonempty','scalar','real','finite'},...
    'matlabshared.orbit.internal.TLE','meanAnomaly');
    validateattributes(meanMotion,{'numeric'},...
    {'nonempty','scalar','real','finite',...
    'positive'},'matlabshared.orbit.internal.TLE','meanMotion');
end
