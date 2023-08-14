function hModeVec2Ind=utilAddModeVec2Ind(parent,refModeVecs,position,sampleTime,~)





    hModeVec2Ind=utilAddSubsystem(parent,'Mode Vector To Index',position);
    modeVectorToIndexSystem=getfullname(hModeVec2Ind);

    hmodeVectorToIndexSystemIn1=add_block('hdlsllib/Sources/In1',strcat(modeVectorToIndexSystem,'/In1'),...
    'MakeNameUnique','on');

    hmodeVectorToIndexSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(modeVectorToIndexSystem,'/Out1'),...
    'MakeNameUnique','on');





    numModes=size(refModeVecs,2);


    set_param(hmodeVectorToIndexSystemIn1,'Position',[125,78,155,92]);
    set_param(hmodeVectorToIndexSystemOut1,'Position',[445,88,475,102]);

    if numModes==1


        hconst=add_block('hdlsllib/Sources/Constant',strcat(modeVectorToIndexSystem,'/Index'),...
        'MakeNameUnique','on',...
        'Value','fi(0,0,1,0)',...
        'SampleTime',compactButAccurateNum2Str(sampleTime),...
        'Position',[315,75,360,115]);

        hterm=add_block('hdlsllib/Sinks/Terminator',strcat(modeVectorToIndexSystem,'/Term'),...
        'MakeNameUnique','on',...
        'Position',[315,75,360,115]);

        add_line(modeVectorToIndexSystem,strcat(get_param(hmodeVectorToIndexSystemIn1,'Name'),'/1'),strcat(get_param(hterm,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeVectorToIndexSystem,strcat(get_param(hconst,'Name'),'/1'),strcat(get_param(hmodeVectorToIndexSystemOut1,'Name'),'/1'),...
        'autorouting','on');
    else

        logicTableBLK=add_block('hdlssclib/HDL Logic Table',strcat(modeVectorToIndexSystem,'/State Mode Vector To Index'),...
        'MakeNameUnique','on');
        logicTableObj=get_param(logicTableBLK,'object');


        logicTableObj.InputTable=mat2str(refModeVecs');
        logicTableObj.OutputTable=mat2str(utilLogicTableOutput((1:numModes)'));


        add_line(modeVectorToIndexSystem,strcat(get_param(hmodeVectorToIndexSystemIn1,'Name'),'/1'),strcat(get_param(logicTableBLK,'Name'),'/1'),...
        'autorouting','on');



        concatBlock=add_block('hdlsllib/Logic and Bit Operations/Bit Concat',strcat(modeVectorToIndexSystem,'/concat'),...
        'MakeNameUnique','on',...
        'numInputs','1');




        add_line(modeVectorToIndexSystem,strcat(get_param(logicTableBLK,'Name'),'/1'),strcat(get_param(concatBlock,'Name'),'/1'),...
        'autorouting','on');


        add_line(modeVectorToIndexSystem,strcat(get_param(concatBlock,'Name'),'/1'),strcat(get_param(hmodeVectorToIndexSystemOut1,'Name'),'/1'),...
        'autorouting','on');





        Simulink.BlockDiagram.arrangeSystem(hModeVec2Ind);
    end
end

function outputTable=utilLogicTableOutput(indexVector)


    if(max(indexVector)==1)
        columnSize=1;
    else


        columnSize=ceil(log2(max(indexVector)));
    end
    outputTable=false(size(indexVector,1),columnSize);
    indexVector=indexVector-1;
    for i=1:size(indexVector,1)
        outputTable(i,:)=logical(bitget(indexVector(i),columnSize:-1:1));
    end
end


