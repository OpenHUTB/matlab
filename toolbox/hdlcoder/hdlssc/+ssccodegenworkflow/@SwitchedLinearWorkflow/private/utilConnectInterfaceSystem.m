function[halgorithmSystemIn,halgorithmSystemOut,hhdlSystem,hhdlAlgorithmSystemEnableOut2,hAlgorithmSystem]=utilConnectInterfaceSystem(hinterfaceSystem,...
    interfaceSystemInMap,interfaceSystemOutMap,sampleTime,algorithmDataType,...
    numSolverIter,singleRateModel,replaceFlag,stateSpaceInputMap,filterInfo,solverType)






    interfaceSystemInBlks=keys(interfaceSystemInMap);

    numinterfaceSystemIns=numel(interfaceSystemInBlks);
    concatBlkPos=[];

    halgorithmSystemIn=[];
    halgorithmSystemOut=[];

    houtBlk=[];
    hhdlAlgorithmSystemEnableOut2=[];

    interfaceSystem=getfullname(hinterfaceSystem);

    algorithmSystemPos=[700,100,800,175];
    if numinterfaceSystemIns>0


        interfaceSystemInBlkPos1st=get_param(interfaceSystemInBlks{1},'Position');

        concatBlkPos=[600,interfaceSystemInBlkPos1st(2),620,interfaceSystemInBlkPos1st(2)+numinterfaceSystemIns*40];



        hconcatBlk=add_block('hdlsllib/Signal Routing/Vector Concatenate',strcat(interfaceSystem,'/Input Concat'),...
        'MakeNameUnique','on',...
        'Position',concatBlkPos,...
        'NumInputs',num2str(numinterfaceSystemIns),...
        'Mode','Vector',...
        'ShowName','off');



        concatOutport=getPortPos(hconcatBlk,'Outport',1);
        algorithmSystemPos=[700,floor(concatOutport-37.5),800,floor(concatOutport+37.5)];

    end

    hAlgorithmSystem=utilAddSubsystem(interfaceSystem,'HDL Algorithm',algorithmSystemPos,'red');


    algorithmSystem=getfullname(hAlgorithmSystem);

    initialPos=[100,100,150,125];


    if isempty(concatBlkPos)
        hdlSystemBlks=hAlgorithmSystem;
    else

        hdlSystemBlks=[hAlgorithmSystem;hconcatBlk];
    end



    hdlSystemBlks=[hdlSystemBlks;filterInfo.hdlSubSystemBlocks];


    interfaceSystemBlks=zeros(numinterfaceSystemIns,3);



    if numinterfaceSystemIns>0


        halgorithmSystemIn=add_block('hdlsllib/Sources/In1',strcat(algorithmSystem,'/In1'),...
        'MakeNameUnique','on');

        add_line(interfaceSystem,strcat(get_param(hconcatBlk,'Name'),'/1'),strcat(get_param(algorithmSystem,'Name'),'/1'),...
        'autorouting','on');




        for ii=1:numinterfaceSystemIns
            interfaceSystemBlks(ii,1)=get_param(interfaceSystemInBlks{ii},'Handle');

            inputNum=str2double(interfaceSystemInMap(interfaceSystemInBlks{ii}));



            ydiff=getPortPos(hconcatBlk,'Inport',inputNum)-getPortPos(interfaceSystemBlks(ii,1),'Outport',1);
            currentBlkPos=get_param(interfaceSystemBlks(ii,1),'Position');
            interfaceSystemInBlkPos=[currentBlkPos(1),currentBlkPos(2)+ydiff,currentBlkPos(3),currentBlkPos(4)+ydiff];
            set_param(interfaceSystemBlks(ii,1),'Position',interfaceSystemInBlkPos);






            hrateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(interfaceSystem,'/Rate Transition',num2str(ii)),...
            'MakeNameUnique','on',...
            'Position',interfaceSystemInBlkPos+[120,-2,125,3],...
            'OutPortSampleTime',compactButAccurateNum2Str(sampleTime));

            interfaceSystemBlks(ii,2)=hrateTransitionBlk;




            add_line(interfaceSystem,strcat(get_param(interfaceSystemInBlks{ii},'Name'),'/1'),strcat(get_param(hrateTransitionBlk,'Name'),'/1'),...
            'autorouting','on');


            if strcmpi(algorithmDataType,'MixedDoubleSingle')
                mixedDataType='double';
            else
                mixedDataType=algorithmDataType;
            end


            hdataTypeConversionBlk=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(interfaceSystem,'/Data Type Conversion',num2str(ii)),...
            'MakeNameUnique','on',...
            'Position',interfaceSystemInBlkPos+[220,-2,225,3],...
            'OutDataTypeStr',mixedDataType,...
            'RndMeth','Nearest');
            interfaceSystemBlks(ii,3)=hdataTypeConversionBlk;


            if singleRateModel
                hrateTransitionModeIterBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(interfaceSystem,'/Rate Transition',num2str(ii+numinterfaceSystemIns)),...
                'MakeNameUnique','on',...
                'Position',interfaceSystemInBlkPos+[300,-2,305,3],...
                'OutPortSampleTimeOpt','Multiple of input port sample time',...
                'OutPortSampleTimeMultiple',strcat('1/',num2str(numSolverIter)),...
                'Integrity','off');
                hdlSystemBlks=[hdlSystemBlks;hrateTransitionModeIterBlk];



                add_line(interfaceSystem,strcat(get_param(hrateTransitionBlk,'Name'),'/1'),strcat(get_param(hdataTypeConversionBlk,'Name'),'/1'),...
                'autorouting','on');



                if(~solverType&&~isempty(filterInfo.hdlSubSystemBlocks)&&filterInfo.block(inputNum).hasInputFilter==1)
                    add_line(interfaceSystem,strcat(get_param(hdataTypeConversionBlk,'Name'),'/1'),strcat(get_param(filterInfo.block(inputNum).inputHandle,'Name'),'/1'),...
                    'autorouting','on');
                    add_line(interfaceSystem,strcat(get_param(filterInfo.block(inputNum).outputHandle,'Name'),'/1'),strcat(get_param(hrateTransitionModeIterBlk,'Name'),'/1'),...
                    'autorouting','on');
                else


                    add_line(interfaceSystem,strcat(get_param(hdataTypeConversionBlk,'Name'),'/1'),strcat(get_param(hrateTransitionModeIterBlk,'Name'),'/1'),...
                    'autorouting','on');
                end


                add_line(interfaceSystem,strcat(get_param(hrateTransitionModeIterBlk,'Name'),'/1'),strcat(get_param(hconcatBlk,'Name'),'/',num2str(inputNum)),...
                'autorouting','on');
            else


                add_line(interfaceSystem,strcat(get_param(hrateTransitionBlk,'Name'),'/1'),strcat(get_param(hdataTypeConversionBlk,'Name'),'/1'),...
                'autorouting','on');
                if min(stateSpaceInputMap{inputNum,2}{3})>1

                    hReshape=add_block('hdlsllib/Math Operations/Reshape',strcat(interfaceSystem,'/Reshape',num2str(ii)),...
                    'MakeNameUnique','on',...
                    'Position',interfaceSystemInBlkPos+[250,-2,260,3]);

                    add_line(interfaceSystem,strcat(get_param(hdataTypeConversionBlk,'Name'),'/1'),strcat(get_param(hReshape,'Name'),'/1'),...
                    'autorouting','on');

                    add_line(interfaceSystem,strcat(get_param(hReshape,'Name'),'/1'),strcat(get_param(hconcatBlk,'Name'),'/',num2str(inputNum)),...
                    'autorouting','on');



                elseif(~solverType&&~isempty(filterInfo.hdlSubSystemBlocks)&&filterInfo.block(inputNum).hasInputFilter==1)
                    add_line(interfaceSystem,strcat(get_param(hdataTypeConversionBlk,'Name'),'/1'),strcat(get_param(filterInfo.block(inputNum).inputHandle,'Name'),'/1'),...
                    'autorouting','on');
                    add_line(interfaceSystem,strcat(get_param(filterInfo.block(inputNum).outputHandle,'Name'),'/1'),strcat(get_param(hconcatBlk,'Name'),'/',num2str(inputNum)),...
                    'autorouting','on');
                else

                    add_line(interfaceSystem,strcat(get_param(hdataTypeConversionBlk,'Name'),'/1'),strcat(get_param(hconcatBlk,'Name'),'/',num2str(inputNum)),...
                    'autorouting','on');
                end
            end




            hline=get_param(interfaceSystemInBlks{ii},'LineHandles');
            set_param(hline.Outport,'Name',get_param(interfaceSystemInBlks{ii},'Name'));



            hline=get_param(hdataTypeConversionBlk,'LineHandles');
            set_param(hline.Outport,'Name',get_param(interfaceSystemInBlks{ii},'Name'));
        end
    end












    interfaceSystemOutBlks=[];
    if size(interfaceSystemOutMap,2)==3
        interfaceSystemOutBlks=interfaceSystemOutMap(:,3);
    end

    numinterfaceSystemOuts=size(interfaceSystemOutMap,1);

    if numinterfaceSystemOuts>0



        halgorithmSystemOut=add_block('hdlsllib/Sinks/Out1',strcat(algorithmSystem,'/Out1'),...
        'MakeNameUnique','on');


        if singleRateModel
            hhdlAlgorithmSystemEnableOut2=add_block('hdlsllib/Sinks/Out1',strcat(algorithmSystem,'/Valid Out'),...
            'MakeNameUnique','on',...
            'Position',[1995,1388,2025,1402]);
        else
            hhdlAlgorithmSystemEnableOut2=[];
        end




        interfaceSystemOutSize=cell(numinterfaceSystemOuts,1);

        for ii=1:numinterfaceSystemOuts
            mapVal=interfaceSystemOutMap{ii,2};
            interfaceSystemOutSize{ii}=mapVal{3};
        end

        numalgorithmSystemOuts=sum(cellfun(@(dims)prod(dims),interfaceSystemOutSize));
        hdlAlgorithmPorts=get_param(hAlgorithmSystem,'PortHandles');
        hdlAlgorithmPortPos=get_param(hdlAlgorithmPorts.Outport(1),'Position');

        hdemuxBlk=add_block('hdlsllib/Signal Routing/Demux',strcat(interfaceSystem,'/Output Demux'),...
        'MakeNameUnique','on',...
        'Position',[850,hdlAlgorithmPortPos(2)-20*numalgorithmSystemOuts,870,20*numalgorithmSystemOuts+hdlAlgorithmPortPos(2)],...
        'Outputs',num2str(numalgorithmSystemOuts),...
        'ShowName','off');

        hdlSystemBlks=[hdlSystemBlks;hdemuxBlk];



        add_line(interfaceSystem,strcat(get_param(algorithmSystem,'Name'),'/1'),strcat(get_param(hdemuxBlk,'Name'),'/1'),...
        'autorouting','on');


        if replaceFlag



            orderOfOutputs=getOutportOrder(interfaceSystemOutBlks);
            houtBlk=zeros(numinterfaceSystemOuts,1);
            if numinterfaceSystemOuts==1
                outportYs=hdlAlgorithmPortPos(2);
            else
                outportYs=linspace(hdlAlgorithmPortPos(2)-20*numalgorithmSystemOuts,hdlAlgorithmPortPos(2)+20*numalgorithmSystemOuts,numinterfaceSystemOuts+1);
                outportYs=(outportYs(1:numinterfaceSystemOuts)+outportYs(2:numinterfaceSystemOuts+1))/2;
            end
            for i=orderOfOutputs
                outName=get_param(interfaceSystemOutBlks{i},'Name');
                outName=strrep(outName,'/','//');
                houtBlk(i)=add_block('simulink/Sinks/Out1',strcat(getfullname(hinterfaceSystem),'/',outName),...
                'MakeNameUnique','on',...
                'Position',[1200,outportYs(i)-6,1230,outportYs(i)+6]);
            end

        else





            houtBlk=add_block('hdlsllib/Sinks/Scope',strcat(interfaceSystem,'/Scope'),...
            'MakeNameUnique','on',...
            'NumInputPorts',num2str(numinterfaceSystemOuts),...
            'Position',[1200,hdlAlgorithmPortPos(2)-20*numalgorithmSystemOuts,1270,hdlAlgorithmPortPos(2)+20*numalgorithmSystemOuts],...
            'DataLoggingLimitDataPoints','off');
        end

        muxBlkPos=[initialPos(1)+900,hdlAlgorithmPortPos(2)-20*numalgorithmSystemOuts...
        ,initialPos(3)+870,hdlAlgorithmPortPos(2)-20*numalgorithmSystemOuts];
        kk=1;
        for ii=1:numinterfaceSystemOuts
            outputDim=prod(interfaceSystemOutSize{ii});
            muxBlkPos=muxBlkPos+([0,0,0,40*outputDim-5]);


            if(outputDim>1)
                hmuxBlk=add_block('hdlsllib/Signal Routing/Mux',strcat(interfaceSystem,'/Mux',num2str(ii)),...
                'MakeNameUnique','on',...
                'Inputs',num2str(outputDim),...
                'Position',muxBlkPos,...
                'ShowName','off');

                hdlSystemBlks=[hdlSystemBlks;hmuxBlk];


                for jj=1:outputDim
                    add_line(interfaceSystem,strcat(get_param(hdemuxBlk,'Name'),'/',num2str(kk)),strcat(get_param(hmuxBlk,'Name'),'/',num2str(jj)),...
                    'autorouting','on');
                    kk=kk+1;
                end




                if min(interfaceSystemOutSize{ii})>1

                    hReshape=add_block('hdlsllib/Math Operations/Reshape',strcat(interfaceSystem,'/Reshape',num2str(ii)),...
                    'MakeNameUnique','on',...
                    'OutputDimensionality','Customize',...
                    'OutputDimensions',['[',num2str(interfaceSystemOutSize{ii}),']'],...
                    'Position',muxBlkPos+[250,-2,260,3]);
                    add_line(interfaceSystem,strcat(get_param(hmuxBlk,'Name'),'/1'),strcat(get_param(hReshape,'Name'),'/1'),...
                    'autorouting','on');
                    outputPortName=strcat(get_param(hReshape,'Name'),'/1');
                    outputPortPos=getPortPos(hReshape,'Outport',1);


                else

                    outputPortName=strcat(get_param(hmuxBlk,'Name'),'/1');
                    outputPortPos=getPortPos(hmuxBlk,'Outport',1);
                end
            else
                outputPortName=strcat(get_param(hdemuxBlk,'Name'),'/',int2str(kk));
                outputPortPos=getPortPos(hdemuxBlk,'Outport',kk);
                kk=kk+1;
            end



            if replaceFlag
                outportName=strcat(strrep(get_param(houtBlk(ii),'Name'),'/','//'),'/1');
            else
                outportName=strcat(get_param(houtBlk,'Name'),'/',num2str(ii));
            end
            if singleRateModel

                rateTransitionPos=[muxBlkPos(1)+50,outputPortPos-15,muxBlkPos(3)+70,outputPortPos+15];
                hrateTransitionModeIterBlk2=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(interfaceSystem,'/Rate Transition',num2str(ii+numinterfaceSystemIns)),...
                'MakeNameUnique','on',...
                'Position',rateTransitionPos,...
                'OutPortSampleTimeOpt','Multiple of input port sample time',...
                'OutPortSampleTimeMultiple',int2str(numSolverIter));
                hdlSystemBlks=[hdlSystemBlks;hrateTransitionModeIterBlk2];
                add_line(interfaceSystem,outputPortName,strcat(get_param(hrateTransitionModeIterBlk2,'Name'),'/1'),...
                'autorouting','on');
                hline=add_line(interfaceSystem,strcat(get_param(hrateTransitionModeIterBlk2,'Name'),'/1'),outportName,...
                'autorouting','on');
            else

                hline=add_line(interfaceSystem,outputPortName,outportName,...
                'autorouting','on');

            end






            set_param(hline,'Name',get_param(interfaceSystemOutBlks{ii},'Name'));


            muxBlkPos=[muxBlkPos(1),muxBlkPos(4)+5,muxBlkPos(3),muxBlkPos(4)+5];
        end
    else

        hhdlAlgorithmSystemEnableOut2=add_block('hdlsllib/Sinks/Terminator',strcat(algorithmSystem,'/Valid Out'),...
        'MakeNameUnique','on',...
        'Position',[1995,1388,2025,1402]);
    end


    if singleRateModel
        if numinterfaceSystemOuts>0

            muxBlkPos=muxBlkPos+[0,0,0,40*outputDim-5];
            htermBlk=add_block('hdlsllib/Sinks/Terminator',strcat(interfaceSystem,'/Valid Out'),...
            'MakeNameUnique','on',...
            'Position',+[1220,muxBlkPos(2),1250,muxBlkPos(4)]);
            hdlSystemBlks=[hdlSystemBlks;htermBlk];


            add_line(interfaceSystem,strcat(get_param(algorithmSystem,'Name'),'/2'),strcat(get_param(htermBlk,'Name'),'/1'),...
            'autorouting','on');

        end

    end



    Simulink.BlockDiagram.createSubsystem(hdlSystemBlks);
    hdlSystem=get_param(hdlSystemBlks(1),'Parent');
    hhdlSystem=get_param(hdlSystem,'Handle');



    set_param(hhdlSystem,'Position',initialPos+[600,-10,800,90+20*max(numinterfaceSystemIns,numinterfaceSystemOuts)]);

    set_param(hhdlSystem,'Name','HDL Subsystem');

    if~isempty(houtBlk)&&~replaceFlag
        set_param(houtBlk,'Position',initialPos+[1100,-10,1120,90+20*max(numinterfaceSystemIns,numinterfaceSystemOuts)]);
    end


    for ii=1:numinterfaceSystemIns
        for jj=1:3

            ydiff=getPortPos(hhdlSystem,'Inport',str2double(interfaceSystemInMap(interfaceSystemInBlks{ii})))-getPortPos(interfaceSystemBlks(ii,jj),'Outport',1);
            currentBlkPos=get_param(interfaceSystemBlks(ii,jj),'Position');
            set_param(interfaceSystemBlks(ii,jj),'Position',[currentBlkPos(1),currentBlkPos(2)+ydiff,currentBlkPos(3),currentBlkPos(4)+ydiff]);
        end

    end


    if numinterfaceSystemOuts>0
        if replaceFlag
            for ii=1:numinterfaceSystemOuts
                hscopeBlkLines(ii)=get_param(houtBlk(ii),'LineHandles');%#ok<*AGROW>
            end
        else
            hscopeBlkLines=get_param(houtBlk,'LineHandles');
        end

        hscopeBlkLines=[hscopeBlkLines.Inport];

        for ii=1:numinterfaceSystemOuts
            set_param(hscopeBlkLines(ii),'Name',get_param(interfaceSystemOutBlks{ii},'Name'));
        end
    end
    Simulink.BlockDiagram.arrangeSystem(interfaceSystem,'FullLayout','True','Animation','False')

end

function y=getPortPos(hblk,inOut,portNum)
    portHandles=get_param(hblk,'PortHandles');
    if strcmp(inOut,'Inport')
        portPos=get_param(portHandles.Inport(portNum),'Position');
    elseif strcmp(inOut,'Outport')
        portPos=get_param(portHandles.Outport(portNum),'Position');
    else
        portPos=nan(2,1);
    end
    y=portPos(2);
end

function addOrder=getOutportOrder(interfaceSystemOutBlks)

    orderOfOutputs=zeros(1,numel(interfaceSystemOutBlks));
    for i=1:numel(interfaceSystemOutBlks)

        hpssLine=get_param(interfaceSystemOutBlks{i},'LineHandles');
        hpssBlkOutport=hpssLine.Outport;


        assert(numel(hpssBlkOutport)==1);

        houtport=get_param(hpssBlkOutport,'DstBlockHandle');

        orderOfOutputs(i)=str2double(get_param(houtport,'Port'));
    end
    addOrder(orderOfOutputs)=1:numel(interfaceSystemOutBlks);

end



