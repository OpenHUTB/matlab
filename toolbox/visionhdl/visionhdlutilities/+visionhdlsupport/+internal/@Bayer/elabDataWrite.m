function dataWriteNet=elabDataWrite(~,coreNet,blockInfo,sigInfo,dataRate)




    booleanT=pir_boolean_t();
    selT=sigInfo.selT;

    inPortNames={'hStart','hEnd','vStart','vEnd','validIn'};
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate];
    inPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT];

    outPortNames={'SELR','SELG','SELB'};
    outPortTypes=[selT,selT,selT];

    dataWriteNet=pirelab.createNewNetwork(...
    'Network',coreNet,...
    'Name','dataWriteFSM',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    if strcmpi(blockInfo.Algorithm,'Gradient-corrected linear')
        compName='dataWrite';
    else
        compName='dataWriteBilinear';
    end
    desc='dataWriteFSM';

    fid=fopen(fullfile(matlabroot,'toolbox','visionhdl','visionhdlutilities',...
    '+visionhdlsupport','+internal','@Bayer','cgireml',[compName,'.m']));
    fcnBody=fread(fid,Inf,'char=>char');




    if strcmpi(blockInfo.Algorithm,'Gradient-corrected linear')
        if blockInfo.NumPixels==1
            if strcmpi(blockInfo.SensorAlignment,'GBRG')
                fcnBody=(strrep(fcnBody','RL1P1','1'))';
                fcnBody=(strrep(fcnBody','GL1P1','1'))';
                fcnBody=(strrep(fcnBody','BL1P1','0'))';
                fcnBody=(strrep(fcnBody','RL1P2','2'))';
                fcnBody=(strrep(fcnBody','GL1P2','0'))';
                fcnBody=(strrep(fcnBody','BL1P2','3'))';
                fcnBody=(strrep(fcnBody','RL2P1','3'))';
                fcnBody=(strrep(fcnBody','GL2P1','0'))';
                fcnBody=(strrep(fcnBody','BL2P1','2'))';
                fcnBody=(strrep(fcnBody','RL2P2','0'))';
                fcnBody=(strrep(fcnBody','GL2P2','1'))';
                fcnBody=(strrep(fcnBody','BL2P2','1'))';
            elseif strcmpi(blockInfo.SensorAlignment,'GRBG')
                fcnBody=(strrep(fcnBody','RL1P1','0'))';
                fcnBody=(strrep(fcnBody','GL1P1','1'))';
                fcnBody=(strrep(fcnBody','BL1P1','1'))';
                fcnBody=(strrep(fcnBody','RL1P2','3'))';
                fcnBody=(strrep(fcnBody','GL1P2','0'))';
                fcnBody=(strrep(fcnBody','BL1P2','2'))';
                fcnBody=(strrep(fcnBody','RL2P1','2'))';
                fcnBody=(strrep(fcnBody','GL2P1','0'))';
                fcnBody=(strrep(fcnBody','BL2P1','3'))';
                fcnBody=(strrep(fcnBody','RL2P2','1'))';
                fcnBody=(strrep(fcnBody','GL2P2','1'))';
                fcnBody=(strrep(fcnBody','BL2P2','0'))';
            elseif strcmpi(blockInfo.SensorAlignment,'BGGR')
                fcnBody=(strrep(fcnBody','RL1P1','2'))';
                fcnBody=(strrep(fcnBody','GL1P1','0'))';
                fcnBody=(strrep(fcnBody','BL1P1','3'))';
                fcnBody=(strrep(fcnBody','RL1P2','1'))';
                fcnBody=(strrep(fcnBody','GL1P2','1'))';
                fcnBody=(strrep(fcnBody','BL1P2','0'))';
                fcnBody=(strrep(fcnBody','RL2P1','0'))';
                fcnBody=(strrep(fcnBody','GL2P1','1'))';
                fcnBody=(strrep(fcnBody','BL2P1','1'))';
                fcnBody=(strrep(fcnBody','RL2P2','3'))';
                fcnBody=(strrep(fcnBody','GL2P2','0'))';
                fcnBody=(strrep(fcnBody','BL2P2','2'))';
            elseif strcmpi(blockInfo.SensorAlignment,'RGGB')
                fcnBody=(strrep(fcnBody','RL1P1','3'))';
                fcnBody=(strrep(fcnBody','GL1P1','0'))';
                fcnBody=(strrep(fcnBody','BL1P1','2'))';
                fcnBody=(strrep(fcnBody','RL1P2','0'))';
                fcnBody=(strrep(fcnBody','GL1P2','1'))';
                fcnBody=(strrep(fcnBody','BL1P2','1'))';
                fcnBody=(strrep(fcnBody','RL2P1','1'))';
                fcnBody=(strrep(fcnBody','GL2P1','1'))';
                fcnBody=(strrep(fcnBody','BL2P1','0'))';
                fcnBody=(strrep(fcnBody','RL2P2','2'))';
                fcnBody=(strrep(fcnBody','GL2P2','0'))';
                fcnBody=(strrep(fcnBody','BL2P2','3'))';
            else

            end
        else

            fcnBody=(strrep(fcnBody','fi(0,0,2,0)','fi(zeros(1,2),0,2,0)'))';

            if strcmpi(blockInfo.SensorAlignment,'GBRG')
                fcnBody=(strrep(fcnBody','RL1P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[0 3]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[0 3]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[3 0]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[3 0]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[2 1]'))';
            elseif strcmpi(blockInfo.SensorAlignment,'GRBG')
                fcnBody=(strrep(fcnBody','RL1P1','[0 3]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[0 3]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[1 2]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[3 0]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[3 0]'))';
            elseif strcmpi(blockInfo.SensorAlignment,'BGGR')
                fcnBody=(strrep(fcnBody','RL1P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[3 0]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[3 0]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[0 3]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[0 3]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[1 2]'))';
            elseif strcmpi(blockInfo.SensorAlignment,'RGGB')
                fcnBody=(strrep(fcnBody','RL1P1','[3 0]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[3 0]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[0 1]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[2 1]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[0 3]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[1 0]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[0 3]'))';
            else

            end
        end
    else
        if blockInfo.NumPixels==1
            if strcmpi(blockInfo.SensorAlignment,'GBRG')
                fcnBody=(strrep(fcnBody','RL1P1','2'))';
                fcnBody=(strrep(fcnBody','GL1P1','4'))';
                fcnBody=(strrep(fcnBody','BL1P1','3'))';
                fcnBody=(strrep(fcnBody','RL1P2','1'))';
                fcnBody=(strrep(fcnBody','GL1P2','0'))';
                fcnBody=(strrep(fcnBody','BL1P2','4'))';
                fcnBody=(strrep(fcnBody','RL2P1','4'))';
                fcnBody=(strrep(fcnBody','GL2P1','0'))';
                fcnBody=(strrep(fcnBody','BL2P1','1'))';
                fcnBody=(strrep(fcnBody','RL2P2','3'))';
                fcnBody=(strrep(fcnBody','GL2P2','4'))';
                fcnBody=(strrep(fcnBody','BL2P2','2'))';
            elseif strcmpi(blockInfo.SensorAlignment,'GRBG')
                fcnBody=(strrep(fcnBody','RL1P1','3'))';
                fcnBody=(strrep(fcnBody','GL1P1','4'))';
                fcnBody=(strrep(fcnBody','BL1P1','2'))';
                fcnBody=(strrep(fcnBody','RL1P2','4'))';
                fcnBody=(strrep(fcnBody','GL1P2','0'))';
                fcnBody=(strrep(fcnBody','BL1P2','1'))';
                fcnBody=(strrep(fcnBody','RL2P1','1'))';
                fcnBody=(strrep(fcnBody','GL2P1','0'))';
                fcnBody=(strrep(fcnBody','BL2P1','4'))';
                fcnBody=(strrep(fcnBody','RL2P2','2'))';
                fcnBody=(strrep(fcnBody','GL2P2','4'))';
                fcnBody=(strrep(fcnBody','BL2P2','3'))';
            elseif strcmpi(blockInfo.SensorAlignment,'BGGR')
                fcnBody=(strrep(fcnBody','RL1P1','1'))';
                fcnBody=(strrep(fcnBody','GL1P1','0'))';
                fcnBody=(strrep(fcnBody','BL1P1','4'))';
                fcnBody=(strrep(fcnBody','RL1P2','2'))';
                fcnBody=(strrep(fcnBody','GL1P2','4'))';
                fcnBody=(strrep(fcnBody','BL1P2','3'))';
                fcnBody=(strrep(fcnBody','RL2P1','3'))';
                fcnBody=(strrep(fcnBody','GL2P1','4'))';
                fcnBody=(strrep(fcnBody','BL2P1','2'))';
                fcnBody=(strrep(fcnBody','RL2P2','4'))';
                fcnBody=(strrep(fcnBody','GL2P2','0'))';
                fcnBody=(strrep(fcnBody','BL2P2','1'))';
            elseif strcmpi(blockInfo.SensorAlignment,'RGGB')
                fcnBody=(strrep(fcnBody','RL1P1','4'))';
                fcnBody=(strrep(fcnBody','GL1P1','0'))';
                fcnBody=(strrep(fcnBody','BL1P1','1'))';
                fcnBody=(strrep(fcnBody','RL1P2','3'))';
                fcnBody=(strrep(fcnBody','GL1P2','4'))';
                fcnBody=(strrep(fcnBody','BL1P2','2'))';
                fcnBody=(strrep(fcnBody','RL2P1','2'))';
                fcnBody=(strrep(fcnBody','GL2P1','4'))';
                fcnBody=(strrep(fcnBody','BL2P1','3'))';
                fcnBody=(strrep(fcnBody','RL2P2','1'))';
                fcnBody=(strrep(fcnBody','GL2P2','0'))';
                fcnBody=(strrep(fcnBody','BL2P2','4'))';
            else

            end
        else

            fcnBody=(strrep(fcnBody','fi(0,0,3,0)','fi(zeros(1,2),0,3,0)'))';

            if strcmpi(blockInfo.SensorAlignment,'GBRG')
                fcnBody=(strrep(fcnBody','RL1P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[3 4]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[3 4]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[4 3]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[4 3]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[1 2]'))';
            elseif strcmpi(blockInfo.SensorAlignment,'GRBG')
                fcnBody=(strrep(fcnBody','RL1P1','[3 4]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[3 4]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[2 1]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[4 3]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[4 3]'))';
            elseif strcmpi(blockInfo.SensorAlignment,'BGGR')
                fcnBody=(strrep(fcnBody','RL1P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[4 3]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[1 2]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[4 3]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[3 4]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[3 4]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[2 1]'))';
            elseif strcmpi(blockInfo.SensorAlignment,'RGGB')
                fcnBody=(strrep(fcnBody','RL1P1','[4 3]'))';
                fcnBody=(strrep(fcnBody','GL1P1','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL1P1','[1 2]'))';
                fcnBody=(strrep(fcnBody','RL1P2','[4 3]'))';
                fcnBody=(strrep(fcnBody','GL1P2','[0 4]'))';
                fcnBody=(strrep(fcnBody','BL1P2','[1 2]'))';
                fcnBody=(strrep(fcnBody','RL2P1','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL2P1','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL2P1','[3 4]'))';
                fcnBody=(strrep(fcnBody','RL2P2','[2 1]'))';
                fcnBody=(strrep(fcnBody','GL2P2','[4 0]'))';
                fcnBody=(strrep(fcnBody','BL2P2','[3 4]'))';
            else

            end
        end
    end

    fclose(fid);

    FSMInput=dataWriteNet.PirInputSignals;
    FSMOutput=dataWriteNet.PirOutputSignals;

    dataWrite=dataWriteNet.addComponent2(...
    'kind','cgireml',...
    'Name','dataWrite',...
    'InputSignals',FSMInput,...
    'OutputSignals',FSMOutput,...
    'EMLFileName','dataWrite',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);%#ok<NASGU>
