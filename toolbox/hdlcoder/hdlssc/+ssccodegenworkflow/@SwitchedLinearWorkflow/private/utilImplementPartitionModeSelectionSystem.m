function utilImplementPartitionModeSelectionSystem(hmodeSelectionSystemTopIn1,hmodeSelectionSystemTopIn2State,...
    hmodeSelectionSystemTopOut1Mode,modeSelectionSystemTop,stateSpaceParametersVarName,stateSpaceParameters,numsolverIters,outputModeFlag)





    set_param(hmodeSelectionSystemTopIn1,'Position',[70,120,100,135]);
    set_param(hmodeSelectionSystemTopIn2State,'Position',[70,150,100,165]);
    set_param(hmodeSelectionSystemTopOut1Mode,'Position',[325,135,355,150]);



    if outputModeFlag
        numPartitions=size(stateSpaceParameters.Cd,2);
        startNum=size(stateSpaceParameters.Ad,2);
        sampleTime=stateSpaceParameters.DiscreteSampleTime;
    else
        numPartitions=size(stateSpaceParameters.Ad,2);
        sampleTime=stateSpaceParameters.DiscreteSampleTime/numsolverIters;
        startNum=0;
    end


    hmux=add_block('hdlsllib/Signal Routing/Mux',strcat(modeSelectionSystemTop,'/Mux'),...
    'MakeNameUnique','on',...
    'Inputs',int2str(numPartitions),...
    'Position',[275,95,280,95+70*numPartitions]);

    numIndexBits=max(ceil(log2(stateSpaceParameters.NumberOfSwitchingModes)));
    for ii=1:numPartitions


        if stateSpaceParameters.NumberOfSwitchingModes(ii+startNum)==1

            hmodeSelectionSystem=add_block('hdlsllib/Sources/Constant',strcat(modeSelectionSystemTop,'/Sel'),...
            'MakeNameUnique','on',...
            'Value',strcat('fi(','0,0,',num2str(numIndexBits),',0)'),...
            'SampleTime',compactButAccurateNum2Str(sampleTime),...
            'Position',[155,115+70*(ii-1),215,145+70*(ii-1)]);
        else

            hmodeSelectionSystem=utilAddSubsystem(modeSelectionSystemTop,'Mode Selection',[155,115+70*(ii-1),215,175+70*(ii-1)],'white');
            modeSelectionSystem=getfullname(hmodeSelectionSystem);

            hmodeSelectionSystemIn1=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystem,'/In1'),...
            'MakeNameUnique','on');
            hmodeSelectionSystemIn2State=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystem,'/In2'),...
            'MakeNameUnique','on');

            hmodeSelectionSystemOut1Mode=add_block('hdlsllib/Sinks/Out1',strcat(modeSelectionSystem,'/Out1'),...
            'MakeNameUnique','on');
            utilImplementModeSelectionSystem(hmodeSelectionSystemIn1,hmodeSelectionSystemIn2State,...
            hmodeSelectionSystemOut1Mode,modeSelectionSystem,stateSpaceParametersVarName,stateSpaceParameters,ii+startNum);


            add_line(modeSelectionSystemTop,strcat(get_param(hmodeSelectionSystemTopIn1,'name'),'/1'),...
            strcat(get_param(hmodeSelectionSystem,'Name'),'/1'),...
            'autorouting','on');
            add_line(modeSelectionSystemTop,strcat(get_param(hmodeSelectionSystemTopIn2State,'name'),'/1'),...
            strcat(get_param(hmodeSelectionSystem,'Name'),'/2'),...
            'autorouting','on');
        end


        add_line(modeSelectionSystemTop,strcat(get_param(hmodeSelectionSystem,'name'),'/1'),...
        strcat(get_param(hmux,'Name'),'/',int2str(ii)),...
        'autorouting','on');


    end
    add_line(modeSelectionSystemTop,strcat(get_param(hmux,'name'),'/1'),...
    strcat(get_param(hmodeSelectionSystemTopOut1Mode,'Name'),'/1'),...
    'autorouting','on');



end

