function hModeVec2Ind=utilLogicFunction(parent,refModeVecs,position,~,globalInfo)





    hModeVec2Ind=utilAddSubsystem(parent,'Mode Vector To Index',position);
    modeVectorToIndexSystem=getfullname(hModeVec2Ind);

    hmodeVectorToIndexSystemIn1=add_block('hdlsllib/Sources/In1',strcat(modeVectorToIndexSystem,'/In1'),...
    'MakeNameUnique','on');

    hmodeVectorToIndexSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(modeVectorToIndexSystem,'/Out1'),...
    'MakeNameUnique','on');





    numModes=size(refModeVecs,2);


    set_param(hmodeVectorToIndexSystemIn1,'Position',[125,78,155,92]);
    set_param(hmodeVectorToIndexSystemOut1,'Position',[445,88,475,102]);
    numIndexBits=max(ceil(log2(numModes)));

    if numModes==1


        hconst=add_block('hdlsllib/Sources/Constant',strcat(modeVectorToIndexSystem,'/Index'),...
        'MakeNameUnique','on',...
        'Value','fi(0,0,1,0)',...
        'SampleTime',compactButAccurateNum2Str(globalInfo.sampleTime),...
        'Position',[315,75,360,115]);

        hterm=add_block('hdlsllib/Sinks/Terminator',strcat(modeVectorToIndexSystem,'/Term'),...
        'MakeNameUnique','on',...
        'Position',[315,75,360,115]);

        add_line(modeVectorToIndexSystem,strcat(get_param(hmodeVectorToIndexSystemIn1,'Name'),'/1'),strcat(get_param(hterm,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeVectorToIndexSystem,strcat(get_param(hconst,'Name'),'/1'),strcat(get_param(hmodeVectorToIndexSystemOut1,'Name'),'/1'),...
        'autorouting','on');





    else


        outStrs=cell(numIndexBits+1,1);

        modes=squeeze(refModeVecs);
        indexes=(1:numModes)-1;

        for i=1:numIndexBits

            var=strcat('out(',num2str(numIndexBits-i+1),')');
            logicTableForBit=ssccodegenworkflow.logicMinimizationTable(modes(:,mod(floor(indexes/2^(i-1)),2)==1),[],var);
            logicTableForBit.minimizeLogic();
            if strcmp(hdlfeature('SSCHDLLogicTableMinCover'),'on')
                logicTableForBit.computeMinimalCover();
            end
            outStrs(i)=logicTableForBit.print;

        end

        var='found';
        logicTableForBit=ssccodegenworkflow.logicMinimizationTable(modes,[],var);
        logicTableForBit.minimizeLogic();
        if strcmp(hdlfeature('SSCHDLLogicTableMinCover'),'on')
            logicTableForBit.computeMinimalCover();
        end
        outStrs(numIndexBits+1)=logicTableForBit.print;

        functionStr=join(['function [out,found] = logicFunction(m)',newline,...
        'out = false(',num2str(numIndexBits),',1);',...
        join(outStrs,newline),newline,'end']);


        hmatlabFunctionBlk=add_block('hdlsllib/User-Defined Functions/MATLAB Function',strcat(modeVectorToIndexSystem,'/Process Mode Vector'),...
        'MakeNameUnique','on',...
        'Position',[275,31,345,79]);
        hmatlabCodeBlk=find(slroot,'-isa','Stateflow.EMChart','Path',getfullname(hmatlabFunctionBlk));


        hdlset_param(getfullname(hmatlabFunctionBlk),'Architecture','MATLAB Datapath');

        hmatlabCodeBlk.Script=functionStr{1};



        hBitConcat=add_block('hdlsllib/Logic and Bit Operations/Bit Concat',strcat(modeVectorToIndexSystem,'/Bit Concat'),...
        'numInputs','1',...
        'MakeNameUnique','on',...
        'Position',[275,31,345,79]);



        hAssert=add_block('simulink/Model Verification/Assertion',strcat(modeVectorToIndexSystem,'/Uncatalogued Mode'),...
        'MakeNameUnique','on',...
        'StopWhenAssertionFail','off',...
        'Position',[600,200,630,230]);


        add_line(modeVectorToIndexSystem,strcat(get_param(hmodeVectorToIndexSystemIn1,'Name'),'/1'),strcat(get_param(hmatlabFunctionBlk,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeVectorToIndexSystem,strcat(get_param(hmatlabFunctionBlk,'Name'),'/1'),strcat(get_param(hBitConcat,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeVectorToIndexSystem,strcat(get_param(hBitConcat,'Name'),'/1'),strcat(get_param(hmodeVectorToIndexSystemOut1,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeVectorToIndexSystem,strcat(get_param(hmatlabFunctionBlk,'Name'),'/2'),strcat(get_param(hAssert,'Name'),'/1'),...
        'autorouting','on');


    end
    Simulink.BlockDiagram.arrangeSystem(modeVectorToIndexSystem,'FullLayout','True','Animation','False');


end
