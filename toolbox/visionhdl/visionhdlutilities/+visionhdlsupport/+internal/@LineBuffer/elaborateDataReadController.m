function dataReadNet=elaborateDataReadController(this,topNet,blockInfo,sigInfo,dataRate)









    booleanT=sigInfo.booleanT;
    aveType=sigInfo.aveType;
    lineStartT=sigInfo.lineStartT;

    inPortNames={'hStartIn','hEndIn','vStartIn','vEndIn','validIn','lineStartV',...
    'lineAverage','AllEndOfLine','BlankCount','frameStart'};

    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];

    inPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT,lineStartT,aveType,booleanT,aveType,booleanT];

    outPortNames={'hStartR','hEndR','vStartR','vEndR','validR','outputData','Unloading','blankCountEn','Running'};

    outPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];

    dataReadNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DataReadController',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    if blockInfo.KernelHeight>1
        compName='DataReadController';
    else
        compName='DataReadControllerRow';
    end

    desc='Data Read Controller';

    fid=fopen(fullfile(matlabroot,'toolbox','visionhdl','visionhdlutilities',...
    '+visionhdlsupport','+internal','@LineBuffer','cgireml',[compName,'.m']));
    fcnBody=fread(fid,Inf,'char=>char');

    if blockInfo.KernelHeight<=3
        fcnBody=(strrep(fcnBody','LineStartF',num2str(1)))';
    elseif~blockInfo.BiasUp&&mod(blockInfo.KernelHeight,2)==0
        if blockInfo.KernelHeight>4
            fcnBody=(strrep(fcnBody','LineStartF',num2str(floor(blockInfo.KernelHeight/2)-2)))';
        else
            fcnBody=(strrep(fcnBody','LineStartF',num2str(1)))';
        end
    else
        fcnBody=(strrep(fcnBody','LineStartF',num2str(floor(blockInfo.KernelHeight/2)-1)))';
    end

    if blockInfo.KernelHeight<=3
        fcnBody=(strrep(fcnBody','LineStartC',num2str(2)))';
    elseif~blockInfo.BiasUp&&mod(blockInfo.KernelHeight,2)==0
        if blockInfo.KernelHeight<=4
            fcnBody=(strrep(fcnBody','LineStartC',num2str(floor(2))))';
        else
            fcnBody=(strrep(fcnBody','LineStartC',num2str(floor(blockInfo.KernelHeight/2)-1)))';
        end
    else
        fcnBody=(strrep(fcnBody','LineStartC',num2str(floor(blockInfo.KernelHeight/2))))';
    end

    fclose(fid);

    FSMInput=dataReadNet.PirInputSignals;
    FSMOutput=dataReadNet.PirOutputSignals;

    if blockInfo.KernelHeight>1
        dataRead=dataReadNet.addComponent2(...
        'kind','cgireml',...
        'Name','DataReadController',...
        'InputSignals',FSMInput,...
        'OutputSignals',FSMOutput,...
        'EMLFileName','DataReadController',...
        'EMLFileBody',fcnBody,...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'BlockComment',desc);

    else
        dataRead=dataReadNet.addComponent2(...
        'kind','cgireml',...
        'Name','DataReadController',...
        'InputSignals',FSMInput,...
        'OutputSignals',FSMOutput,...
        'EMLFileName','DataReadControllerRow',...
        'EMLFileBody',fcnBody,...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'BlockComment',desc);



    end
    dataRead.runConcurrencyMaximizer(0);
