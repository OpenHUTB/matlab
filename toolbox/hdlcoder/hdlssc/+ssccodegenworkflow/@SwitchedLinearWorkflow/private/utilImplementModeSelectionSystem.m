function utilImplementModeSelectionSystem(hmodeSelectionSystemIn1,hmodeSelectionSystemIn2State,...
    hmodeSelectionSystemOut1,hmodeSelectionSystemOut2,modeSelectionSystem,...
    stateSpaceParametersVarName,stateSpaceParameters,numSolverIters,partitionNum)

    if nargin<9
        partitionNum=0;
    end
    numSolverIters=double(numSolverIters);





    set_param(hmodeSelectionSystemIn1,'Position',[165,33,195,47]);
    set_param(hmodeSelectionSystemIn2State,'Position',[165,78,195,92]);
    set_param(hmodeSelectionSystemOut1,'Position',[650,53,680,67]);
    set_param(hmodeSelectionSystemOut2,'Position',[650,153,680,167]);




    hmatlabFunctionBlk=add_block('hdlsllib/User-Defined Functions/MATLAB Function',strcat(modeSelectionSystem,'/Generate Mode Vector'),...
    'MakeNameUnique','on',...
    'Position',[275,31,345,79]);
    hmatlabCodeBlk=find(slroot,'-isa','Stateflow.EMChart','Path',getfullname(hmatlabFunctionBlk));


    hdlset_param(getfullname(hmatlabFunctionBlk),'Architecture','MATLAB Datapath');

    if partitionNum>0
        hmatlabCodeBlk.Script=stateSpaceParameters.ComputeSwitchingMode{partitionNum};
    else
        hmatlabCodeBlk.Script=stateSpaceParameters.ComputeSwitchingMode;
    end

    add_line(modeSelectionSystem,strcat(get_param(hmodeSelectionSystemIn1,'Name'),'/1'),strcat(get_param(hmatlabFunctionBlk,'Name'),'/2'),...
    'autorouting','on');
    add_line(modeSelectionSystem,strcat(get_param(hmodeSelectionSystemIn2State,'Name'),'/1'),strcat(get_param(hmatlabFunctionBlk,'Name'),'/1'),...
    'autorouting','on');

    sampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime/double(numSolverIters));

    hmatlabFunctionConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(modeSelectionSystem,'/Constant'),...
    'MakeNameUnique','on',...
    'Value','boolean(0)',...
    'SampleTime',sampleTime,...
    'Position',[165,125,195,155]);

    add_line(modeSelectionSystem,strcat(get_param(hmatlabFunctionConstantBlk,'Name'),'/1'),strcat(get_param(hmatlabFunctionBlk,'Name'),'/3'),...
    'autorouting','on');


    hreshapeBlk=add_block('hdlsllib/Math Operations/Reshape',strcat(modeSelectionSystem,'/Reshape'),...
    'MakeNameUnique','on',...
    'Position',[390,48,420,72],...
    'OutputDimensionality','1-D array');

    add_line(modeSelectionSystem,strcat(get_param(hmatlabFunctionBlk,'Name'),'/1'),strcat(get_param(hreshapeBlk,'Name'),'/1'),...
    'autorouting','on');



    hdtcBlk=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(modeSelectionSystem,'/Data Type Conversion'),...
    'MakeNameUnique','on',...
    'Position',[450,45,490,75],...
    'OutDataTypeStr','boolean');

    add_line(modeSelectionSystem,strcat(get_param(hreshapeBlk,'Name'),'/1'),strcat(get_param(hdtcBlk,'Name'),'/1'),...
    'autorouting','on');



    start=0;

    if strcmp(hdlfeature('SSCHDLLogicTableMinimization'),'on')



        logicTableBLK=add_block('hdlssclib/HDL Logic Table',strcat(modeSelectionSystem,'/State Mode Vector To Index'),...
        'MakeNameUnique','on',...
        'Position',[450,45,490,75]);
        logicTableObj=get_param(logicTableBLK,'object');


        logicTableObj.InputTable=strcat(stateSpaceParametersVarName,'.','logicTableInput');
        logicTableObj.OutputTable=strcat(stateSpaceParametersVarName,'.','logicTableOutput');


        add_line(modeSelectionSystem,strcat(get_param(hdtcBlk,'Name'),'/1'),strcat(get_param(logicTableBLK,'Name'),'/1'),...
        'autorouting','on');


        modeValidation=add_block('hdlssclib/HDL Logic Table',strcat(modeSelectionSystem,'/uncatalogued mode identifier'),...
        'MakeNameUnique','on',...
        'Position',[450,45,490,75]);
        modeValObj=get_param(modeValidation,'object');


        modeValObj.InputTable=strcat(stateSpaceParametersVarName,'.','logicTableInput');
        modeValObj.OutputTable=strcat('ones(size(',stateSpaceParametersVarName,'.','logicTableOutput,1),1)');

        add_line(modeSelectionSystem,strcat(get_param(hdtcBlk,'Name'),'/1'),strcat(get_param(modeValidation,'Name'),'/1'),...
        'autorouting','on');


        hSDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(modeSelectionSystem,'/S Delay'),...
        'MakeNameUnique','on',...
        'DelayLength','1',...
        'InitialCondition',strcat(stateSpaceParametersVarName,'.','mode(1)'));



        hswitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(modeSelectionSystem,'/Switch3'),...
        'MakeNameUnique','on',...
        'Position',[1210,100,1260,140],...
        'Criteria','u2 ~= 0');


        hswitchBlk2=add_block('hdlsllib/Signal Routing/Switch',strcat(modeSelectionSystem,'/Switch3'),...
        'MakeNameUnique','on',...
        'Position',[1210,100,1260,140],...
        'Criteria','u2 ~= 0');


        concatBlock=add_block('hdlsllib/Logic and Bit Operations/Bit Concat',strcat(modeSelectionSystem,'/concat'),...
        'MakeNameUnique','on',...
        'numInputs','1',...
        'Position',[450,45,490,75]);


        hassertionBlk=add_block('hdlsllib/Model Verification/Assertion',strcat(modeSelectionSystem,'/assertion'),...
        'MakeNameUnique','on',...
        'Position',[1210,100,1260,140],...
        'stopWhenAssertionFail','off');


        add_line(modeSelectionSystem,strcat(get_param(logicTableBLK,'Name'),'/1'),strcat(get_param(concatBlock,'Name'),'/1'),...
        'autorouting','on');

        add_line(modeSelectionSystem,strcat(get_param(hswitchBlk2,'Name'),'/1'),strcat(get_param(hSDelayBlk,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(modeValidation,'Name'),'/1'),strcat(get_param(hassertionBlk,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(concatBlock,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(concatBlock,'Name'),'/1'),strcat(get_param(hswitchBlk2,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(modeValidation,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/2'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(modeValidation,'Name'),'/1'),strcat(get_param(hswitchBlk2,'Name'),'/2'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(hSDelayBlk,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/3'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(hSDelayBlk,'Name'),'/1'),strcat(get_param(hswitchBlk2,'Name'),'/3'),...
        'autorouting','on');
        add_line(modeSelectionSystem,strcat(get_param(hswitchBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystemOut1,'Name'),'/1'),...
        'autorouting','on');
        start=1;
    end




    for i=start:1


        if i
            name='Output Mode Vector To Index';
            coeffIndex=stateSpaceParameters.ModeVec2OutputConfig;
        else
            name='State Mode Vector To Index';
            coeffIndex=stateSpaceParameters.ModeVec2StateConfig;
        end

        hmodeVectorToIndexSystem=utilAddSubsystem(modeSelectionSystem,name,[525,36+100*i,575,84+100*i],'white');
        modeVectorToIndexSystem=getfullname(hmodeVectorToIndexSystem);

        hmodeVectorToIndexSystemIn1=add_block('hdlsllib/Sources/In1',strcat(modeVectorToIndexSystem,'/In1'),...
        'MakeNameUnique','on');

        hmodeVectorToIndexSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(modeVectorToIndexSystem,'/Out1'),...
        'MakeNameUnique','on');


        add_line(modeSelectionSystem,strcat(get_param(hdtcBlk,'Name'),'/1'),strcat(get_param(hmodeVectorToIndexSystem,'Name'),'/1'),...
        'autorouting','on');

        if i
            add_line(modeSelectionSystem,strcat(get_param(hmodeVectorToIndexSystem,'Name'),'/1'),strcat(get_param(hmodeSelectionSystemOut2,'Name'),'/1'),...
            'autorouting','on');
        else

            add_line(modeSelectionSystem,strcat(get_param(hmodeVectorToIndexSystem,'Name'),'/1'),strcat(get_param(hmodeSelectionSystemOut1,'Name'),'/1'),...
            'autorouting','on');
        end



        if strcmp(hdlfeature('SSCHDLLogicTable'),'on')
            utilLogicFunction(hmodeVectorToIndexSystemIn1,...
            hmodeVectorToIndexSystemOut1,modeVectorToIndexSystem,...
            stateSpaceParametersVarName,stateSpaceParameters.mode,coeffIndex,sampleTime);
        else
            utilImplementModeVectorToIndexSystem(hmodeVectorToIndexSystemIn1,...
            hmodeVectorToIndexSystemOut1,modeVectorToIndexSystem,...
            stateSpaceParametersVarName,stateSpaceParameters.mode,coeffIndex,sampleTime,partitionNum);
        end
    end

    Simulink.BlockDiagram.arrangeSystem(modeSelectionSystem,'FullLayout','True','Animation','False');

end

function utilLogicFunction(hmodeVectorToIndexSystemIn1,...
    hmodeVectorToIndexSystemOut1,modeVectorToIndexSystem,...
    ~,modeVector,modeVec2UniqueConfig,sampleTime)

    numIndexBits=max(ceil(log2(modeVec2UniqueConfig)));

    if max(modeVec2UniqueConfig)==1


        hconst=add_block('hdlsllib/Sources/Constant',strcat(modeVectorToIndexSystem,'/Index'),...
        'MakeNameUnique','on',...
        'Value','fi(0,0,1,0)',...
        'SampleTime',sampleTime,...
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

        modes=reshape(modeVector,[size(modeVector,1),size(modeVector,3)]);
        indexes=modeVec2UniqueConfig-1;

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



function utilImplementModeVectorToIndexSystem(hmodeVectorToIndexSystemIn1,...
    hmodeVectorToIndexSystemOut1,modeVectorToIndexSystem,...
    stateSpaceParametersVarName,modeVector,modeVec2UniqueConfig,sampleTime,partitionNum)


    numIndexBits=max(ceil(log2(modeVec2UniqueConfig)));

    if max(modeVec2UniqueConfig)==1


        hconst=add_block('hdlsllib/Sources/Constant',strcat(modeVectorToIndexSystem,'/Index'),...
        'MakeNameUnique','on',...
        'Value','fi(0,0,1,0)',...
        'SampleTime',sampleTime,...
        'Position',[315,75,360,115]);

        hterm=add_block('hdlsllib/Sinks/Terminator',strcat(modeVectorToIndexSystem,'/Term'),...
        'MakeNameUnique','on',...
        'Position',[315,75,360,115]);

        add_line(modeVectorToIndexSystem,strcat(get_param(hmodeVectorToIndexSystemIn1,'Name'),'/1'),strcat(get_param(hterm,'Name'),'/1'),...
        'autorouting','on');
        add_line(modeVectorToIndexSystem,strcat(get_param(hconst,'Name'),'/1'),strcat(get_param(hmodeVectorToIndexSystemOut1,'Name'),'/1'),...
        'autorouting','on');





    else


        if partitionNum>0
            cellApendString=strcat('{',int2str(partitionNum),'}');
        else
            cellApendString=[];
        end

        numModes=size(modeVector,3);


        set_param(hmodeVectorToIndexSystemIn1,'Position',[125,78,155,92]);
        set_param(hmodeVectorToIndexSystemOut1,'Position',[445,88,475,102]);



        hcomparatorChain={};
        slDrawLimit=32767;

        ssPosIncr=floor(double(slDrawLimit)/(numModes+1));
        if ssPosIncr>50
            ssPosIncr=50;
        end
        initialPos=[315,75,360,115];
        for ii=1:numModes
            hcomparatorSystem=utilAddSubsystem(modeVectorToIndexSystem,strcat('Subsystem',num2str(ii)),initialPos,'white');

            set_param(hcomparatorSystem,'TreatAsAtomicUnit','on');

            maskObj=Simulink.Mask.create(hcomparatorSystem);
            maskObj.addParameter('Type','edit','Prompt','Index',...
            'Name','Index');
            maskObj.Parameters.Tunable='on';
            set_param(hcomparatorSystem,'Index',strcat('fi(',num2str(modeVec2UniqueConfig(ii)-1),',0,',num2str(numIndexBits),',0)'));

            comparatorSystem=getfullname(hcomparatorSystem);

            hcomparatorSystemIn1=add_block('hdlsllib/Sources/In1',strcat(comparatorSystem,'/In1'),...
            'MakeNameUnique','on',...
            'Position',[270,88,300,102]);
            hcomparatorSystemIn2=add_block('hdlsllib/Sources/In1',strcat(comparatorSystem,'/In2'),...
            'MakeNameUnique','on',...
            'Position',[270,28,300,42]);
            hcomparatorSystemIn3=add_block('hdlsllib/Sources/In1',strcat(comparatorSystem,'/In2'),...
            'MakeNameUnique','on',...
            'Position',[270,108,300,122]);

            hcomparatorSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(comparatorSystem,'/Out1'),...
            'MakeNameUnique','on',...
            'Position',[745,98,775,112]);


            hmodeVectorConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(modeVectorToIndexSystem,'/Mode Vector',num2str(ii)),...
            'MakeNameUnique','on',...
            'Value',strcat(stateSpaceParametersVarName,'.mode',cellApendString,'(:,:,',num2str(ii),')'),...
            'SampleTime',sampleTime,...
            'OutDataTypeStr','boolean',...
            'Position',get_param(hcomparatorSystem,'Position')+[-75,ceil(ssPosIncr/2.3),-95,ceil(ssPosIncr/6.5)]);

            add_line(modeVectorToIndexSystem,strcat(get_param(hmodeVectorConstantBlk,'Name'),'/1'),strcat(get_param(hcomparatorSystem,'Name'),'/3'),...
            'autorouting','on');


            hxorBlk=add_block('hdlsllib/Logic and Bit Operations/Bitwise Operator',strcat(comparatorSystem,'/Bitwise Operator'),...
            'MakeNameUnique','on',...
            'Position',[340,86,380,124],...
            'logicop','XOR',...
            'UseBitMask','off',...
            'NumInputPorts','2');

            add_line(comparatorSystem,strcat(get_param(hcomparatorSystemIn1,'Name'),'/1'),strcat(get_param(hxorBlk,'Name'),'/1'),...
            'autorouting','on');
            add_line(comparatorSystem,strcat(get_param(hcomparatorSystemIn3,'Name'),'/1'),strcat(get_param(hxorBlk,'Name'),'/2'),...
            'autorouting','on');


            modeVectorSize=numel(modeVector(:,:,ii));


            hdemuxBlk=add_block('hdlsllib/Signal Routing/Demux',strcat(comparatorSystem,'/Demux'),...
            'MakeNameUnique','on',...
            'Position',[425,86,430,124],...
            'Outputs',num2str(modeVectorSize));

            add_line(comparatorSystem,strcat(get_param(hxorBlk,'Name'),'/1'),strcat(get_param(hdemuxBlk,'Name'),'/1'),...
            'autorouting','on');


            hnorBlk=add_block('hdlsllib/Logic and Bit Operations/Bitwise Operator',strcat(comparatorSystem,'/Bitwise Operator'),...
            'MakeNameUnique','on',...
            'Position',[490,86,530,124],...
            'logicop','NOR',...
            'UseBitMask','off',...
            'NumInputPorts',num2str(modeVectorSize));

            for jj=1:modeVectorSize
                add_line(comparatorSystem,strcat(get_param(hdemuxBlk,'Name'),'/',num2str(jj)),strcat(get_param(hnorBlk,'Name'),'/',num2str(jj)),...
                'autorouting','on');
            end


            hswitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(comparatorSystem,'/Switch'),...
            'MakeNameUnique','on',...
            'Position',[655,85,705,125],...
            'criteria','u2 ~= 0');

            add_line(comparatorSystem,strcat(get_param(hcomparatorSystemIn2,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/3'),...
            'autorouting','on');

            add_line(comparatorSystem,strcat(get_param(hnorBlk,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/2'),...
            'autorouting','on');

            add_line(comparatorSystem,strcat(get_param(hswitchBlk,'Name'),'/1'),strcat(get_param(hcomparatorSystemOut1,'Name'),'/1'),...
            'autorouting','on');


            hindexConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(comparatorSystem,'/Index'),...
            'MakeNameUnique','on',...
            'Value','Index',...
            'SampleTime',sampleTime,...
            'Position',[585,55,615,85]);

            add_line(comparatorSystem,strcat(get_param(hindexConstantBlk,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/1'),...
            'autorouting','on');

            initialPos=initialPos+[0,ssPosIncr,0,ssPosIncr];
            hcomparatorChain{end+1}=hcomparatorSystem;%#ok<AGROW>
        end
        numberOfSwitchingModes=size(modeVector,3);
        for ii=1:numberOfSwitchingModes
            add_line(modeVectorToIndexSystem,strcat(get_param(hmodeVectorToIndexSystemIn1,'Name'),'/1'),strcat(get_param(hcomparatorChain{ii},'Name'),'/1'),...
            'autorouting','on');
        end
        for ii=1:numberOfSwitchingModes-1
            add_line(modeVectorToIndexSystem,strcat(get_param(hcomparatorChain{ii+1},'Name'),'/1'),strcat(get_param(hcomparatorChain{ii},'Name'),'/2'),...
            'autorouting','on');
        end


        add_line(modeVectorToIndexSystem,strcat(get_param(hcomparatorChain{1},'Name'),'/1'),strcat(get_param(hmodeVectorToIndexSystemOut1,'Name'),'/1'),...
        'autorouting','on');


        hdefaultIndexConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(modeVectorToIndexSystem,'/Default Index'),...
        'MakeNameUnique','on',...
        'Value',strcat('fi(','0,0,',num2str(numIndexBits),',0)'),...
        'SampleTime',sampleTime,...
        'Position',[125,120,155,150]);

        add_line(modeVectorToIndexSystem,strcat(get_param(hdefaultIndexConstantBlk,'Name'),'/1'),strcat(get_param(hcomparatorChain{end},'Name'),'/2'),...
        'autorouting','on');
    end
end

