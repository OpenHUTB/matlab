function utilImplementValidationSystem(hvalidationSystem,hhdlSystem,simscapeSystem,stateSpaceOutputMap,validationTolerance,networkNum,sampleTime)





    validationSystem=getfullname(hvalidationSystem);


    fromBlkPos=[100,100,150,125];

    pssBlks=stateSpaceOutputMap(:,1);

    topModel=simscapeSystem;

    delayLength='1';







    hinitialConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(validationSystem,'/Constant'),...
    'MakeNameUnique','on',...
    'Value','0',...
    'SampleTime',compactButAccurateNum2Str(sampleTime),...
    'Position',fromBlkPos);

    hinitialDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(validationSystem,'/Delay'),...
    'MakeNameUnique','on',...
    'DelayLength',delayLength,...
    'InitialCondition','1',...
    'Position',[fromBlkPos(1)+100,fromBlkPos(2),fromBlkPos(3)+100,fromBlkPos(4)]);

    add_line(validationSystem,strcat(get_param(hinitialConstantBlk,'Name'),'/1'),strcat(get_param(hinitialDelayBlk,'Name'),'/1'),...
    'autorouting','on');

    fromBlkPos=fromBlkPos+[0,100,0,100];

    hdlSubsystemPorts=get_param(hhdlSystem,'PortHandles');
    numInports=numel(hdlSubsystemPorts.Inport);
    hdlSubsystemPortCon=get_param(hhdlSystem,'PortConnectivity');

    for ii=1:numel(pssBlks)



        pssBlkii=pssBlks{ii};

        [~,remain]=strtok(pssBlkii,'/');


        pssBlkii_1=[topModel,remain];


        pssBlkii_1Pos=get_param(pssBlkii_1,'Position');

        gotoBlkPos=[pssBlkii_1Pos(1),pssBlkii_1Pos(4),pssBlkii_1Pos(3),pssBlkii_1Pos(4)+20];


        mapVal=stateSpaceOutputMap{ii,2};
        outputIdx=num2str(mapVal{1});
        gotoBlkTag=strcat('gotoSSOut',outputIdx,'_rsvd','_',num2str(networkNum));
        hgotoBlk=add_block('hdlsllib/Signal Routing/Goto',strcat(pssBlkii_1,'_SSOut',outputIdx),...
        'MakeNameUnique','on',...
        'Position',gotoBlkPos,...
        'GotoTag',gotoBlkTag,...
        'ShowName','off',...
        'TagVisibility','global');


        hpssBlkii_1Line=get_param(pssBlkii_1,'LineHandles');
        hspsBlkii_1Outport=hpssBlkii_1Line.Outport;

        hpssBlkii_1SrcPort=get_param(hspsBlkii_1Outport,'SrcPortHandle');

        hgotoBlkInport=get_param(hgotoBlk,'PortHandles');
        hgotoBlkInport=hgotoBlkInport.Inport;


        add_line(get_param(hgotoBlk,'Parent'),...
        hpssBlkii_1SrcPort,hgotoBlkInport,...
        'autorouting','on');


        blkName=strrep(get_param(pssBlkii_1,'Name'),'/','//');


        hfromBlk=add_block('hdlsllib/Signal Routing/From',strcat(validationSystem,'/',blkName),...
        'MakeNameUnique','on',...
        'Position',fromBlkPos,...
        'GotoTag',gotoBlkTag,...
        'ShowName','off');








        hdelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(validationSystem,'/Delay',num2str(ii)),...
        'MakeNameUnique','on',...
        'DelayLength',delayLength,...
        'Position',[fromBlkPos(1)+100,fromBlkPos(2),fromBlkPos(3)+100,fromBlkPos(4)]);

        fromBlkName=strrep(get_param(hfromBlk,'Name'),'/','//');

        add_line(validationSystem,strcat(fromBlkName,'/1'),strcat(get_param(hdelayBlk,'Name'),'/1'),...
        'autorouting','on');


        hin=add_block('hdlsllib/Sources/In1',strcat(validationSystem,'/In',num2str(ii)),...
        'MakeNameUnique','on',...
        'Position',[fromBlkPos(1)+0,fromBlkPos(2)+50,fromBlkPos(1)+30,fromBlkPos(2)+64]);



        hsumBlk=add_block('hdlsllib/HDL Floating Point Operations/Add',strcat(validationSystem,'/Add',num2str(ii)),...
        'MakeNameUnique','on',...
        'Position',[fromBlkPos(1)+200,fromBlkPos(2),fromBlkPos(3)+200,fromBlkPos(4)+25],...
        'Inputs','+-',...
        'ShowName','off');


        add_line(validationSystem,strcat(get_param(hdelayBlk,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(validationSystem,strcat(get_param(hin,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/2'),...
        'autorouting','on');








        hswitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(validationSystem,'/Switch'),...
        'MakeNameUnique','on',...
        'Position',[fromBlkPos(1)+300,fromBlkPos(2),fromBlkPos(3)+300,fromBlkPos(4)+25],...
        'Criteria','u2 ~= 0');


        add_line(validationSystem,strcat(get_param(hsumBlk,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/3'),...
        'autorouting','on');

        add_line(validationSystem,strcat(get_param(hinitialConstantBlk,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(validationSystem,strcat(get_param(hinitialDelayBlk,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/2'),...
        'autorouting','on');

        hstaticRangeCheckBlk=add_block(sprintf('hdlsllib/Model Verification/Check \nStatic Range'),strcat(validationSystem,'/Check Static Range',num2str(ii)),...
        'MakeNameUnique','on',...
        'Position',[fromBlkPos(1)+400,fromBlkPos(2),fromBlkPos(3)+400,fromBlkPos(4)],...
        'ShowName','off',...
        'max',num2str(validationTolerance),...
        'min',num2str(-validationTolerance),...
        'stopWhenAssertionFail','off');


        add_line(validationSystem,strcat(get_param(hswitchBlk,'Name'),'/1'),strcat(get_param(hstaticRangeCheckBlk,'Name'),'/1'),...
        'autorouting','on');


        hdlSystemName=get_param(hhdlSystem,'Name');
        validationSystemName=get_param(hvalidationSystem,'Name');




        connectedBlock=hdlSubsystemPortCon(numInports+ii).DstBlock;
        assert(numel(connectedBlock)<=1)
        if~isempty(connectedBlock)&&strcmp(get_param(connectedBlock,'BlockType'),'Reshape')
            add_line(get_param(validationSystem,'Parent'),...
            strcat(get_param(connectedBlock,'name'),'/1'),...
            strcat(validationSystemName,'/',num2str(ii)),...
            'autorouting','on');
        else


            add_line(get_param(validationSystem,'Parent'),...
            strcat(hdlSystemName,'/',num2str(ii)),...
            strcat(validationSystemName,'/',num2str(ii)),...
            'autorouting','on');
        end


        fromBlkPos=fromBlkPos+[0,100,0,100];
    end
end


