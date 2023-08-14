function utilImplementPartitionEquationSystem(hIn1,hIn3State,hIn4Sel,hOut1,system,systemParameters,hInOld2)











    if nargin<7
        hInOld2=[];
    end


    set_param(hIn1,'Position',[175,108,205,122]);
    if~isempty(hInOld2)
        set_param(hInOld2,'Position',[175,108,205,122]);
    end
    set_param(hIn3State,'Position',[175,58,205,72]);
    set_param(hIn4Sel,'Position',[175,168,205,182]);

    set_param(hOut1,'Position',[310+110*size(systemParameters.StateParameter,2),108,340+110*size(systemParameters.StateParameter,2),122]);


    hSelDemux=add_block('hdlsllib/Signal Routing/Demux',strcat(system,'/Demux'),...
    'MakeNameUnique','on',...
    'Outputs',int2str(size(systemParameters.StateParameter,2)),...
    'Position',[245,156,250,156+20*size(systemParameters.StateParameter,2)]);

    add_line(system,strcat(get_param(hIn4Sel,'Name'),'/1'),strcat(get_param(hSelDemux,'Name'),'/1'),...
    'autorouting','on');


    if strcmpi(systemParameters.AlgorithmDataType,'MixedDoubleSingle')
        mixedDataType='double';
    else
        mixedDataType=systemParameters.AlgorithmDataType;
    end


    for i=1:size(systemParameters.StateParameter,2)


        hpartitionSubsystem=utilAddSubsystem(system,strcat('Partition ',num2str(i)),[320+110*(i-1),105-23*(i-1),380+110*(i-1),165-23*(i-1)],'white');
        partitionSubsystem=getfullname(hpartitionSubsystem);
        hpartitionSubsystemIn1Input=add_block('hdlsllib/Sources/In1',strcat(partitionSubsystem,'/Input'),...
        'MakeNameUnique','on',...
        'Position',[70,298,100,312]);
        hpartitionSubsystemIn2State=add_block('hdlsllib/Sources/In1',strcat(partitionSubsystem,'/State'),...
        'MakeNameUnique','on',...
        'Position',[70,63,100,77]);
        hpartitionSubsystemIn3Sel=add_block('hdlsllib/Sources/In1',strcat(partitionSubsystem,'/Sel'),...
        'MakeNameUnique','on',...
        'Position',[70,238,100,252]);
        if i>1
            hpartitionSubsystemIn4UpstreamState=add_block('hdlsllib/Sources/In1',strcat(partitionSubsystem,'/Upstream State'),...
            'MakeNameUnique','on',...
            'Position',[70,23,100,37]);
        end
        hpartitionSubsystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(partitionSubsystem,'/Out1'),...
        'MakeNameUnique','on',...
        'Position',[560,163,590,177]);






        add_line(system,strcat(get_param(hIn3State,'Name'),'/1'),strcat(get_param(hpartitionSubsystem,'Name'),'/2'),...
        'autorouting','on');
        add_line(system,strcat(get_param(hSelDemux,'Name'),'/',int2str(i)),strcat(get_param(hpartitionSubsystem,'Name'),'/3'),...
        'autorouting','on');
        if i==1&&systemParameters.SolverMethod(1)==0


            add_line(system,strcat(get_param(hInOld2,'Name'),'/1'),strcat(get_param(hpartitionSubsystem,'Name'),'/1'),...
            'autorouting','on');

        else

            add_line(system,strcat(get_param(hIn1,'Name'),'/1'),strcat(get_param(hpartitionSubsystem,'Name'),'/1'),...
            'autorouting','on');

        end
        if i~=1
            add_line(system,strcat(get_param(hlastParitionSubsystem,'Name'),'/1'),strcat(get_param(hpartitionSubsystem,'Name'),'/4'),...
            'autorouting','on');
        end




        hmultiplyStateBlk=[];
        if nnz(systemParameters.StateParameter{2,i})>0

            hmultiplyStateBlk=add_block('hdlssclib/NFPSparseConstMultiply',strcat(partitionSubsystem,'/Multiply State'),...
            'MakeNameUnique','on',...
            'Position',[205,50,285,130],...
            'constMatrix',strcat(mixedDataType,'(',systemParameters.StateParameter{1,i},')'));

            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn2State,'Name'),'/1'),strcat(get_param(hmultiplyStateBlk,'Name'),'/1'),...
            'autorouting','on');
        else

            hterminatorMultiplyStateBlk=add_block('hdlsllib/Sinks/Terminator',strcat(partitionSubsystem,'/Multiply State'),...
            'MakeNameUnique','on',...
            'Position',[935,130,955,150]);

            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn2State,'Name'),'/1'),strcat(get_param(hterminatorMultiplyStateBlk,'Name'),'/1'),...
            'autorouting','on');
        end


        hmultiplyInputBlk=[];
        if nnz(systemParameters.InputParameter{2,i})>0


            hmultiplyInputBlk=add_block('hdlssclib/NFPSparseConstMultiply',strcat(partitionSubsystem,'/Multiply Input'),...
            'MakeNameUnique','on',...
            'Position',[205,285,285,365],...
            'constMatrix',strcat(mixedDataType,'(',systemParameters.InputParameter{1,i},')'));

            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn1Input,'Name'),'/1'),strcat(get_param(hmultiplyInputBlk,'Name'),'/1'),...
            'autorouting','on');
        else

            hterminatorMultiplyInputBlk=add_block('hdlsllib/Sinks/Terminator',strcat(partitionSubsystem,'/Multiply Input'),...
            'MakeNameUnique','on',...
            'Position',[205,295,225,315]);

            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn1Input,'Name'),'/1'),strcat(get_param(hterminatorMultiplyInputBlk,'Name'),'/1'),...
            'autorouting','on');
        end



        hbiasSystem=[];
        if nnz(systemParameters.BiasParameter{2,i})>0

            hbiasSystem=utilAddSubsystem(partitionSubsystem,'Bias',[205,236,260,284],'white');
            biasSystem=getfullname(hbiasSystem);


            hbiasSystemIn1=add_block('hdlsllib/Sources/In1',strcat(biasSystem,'/Sel'),...
            'MakeNameUnique','on');

            hbiasSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(biasSystem,'/Out1'),...
            'MakeNameUnique','on');

            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn3Sel,'Name'),'/1'),strcat(get_param(hbiasSystem,'Name'),'/1'),...
            'autorouting','on');


            set_param(hbiasSystemIn1,'Position',[20,213,50,227]);
            set_param(hbiasSystemOut1,'Position',[375,373,405,387]);

            numconstantBlks=size(systemParameters.BiasParameter{2},3);

            hmultiportSwitchBlk=add_block('hdlsllib/Signal Routing/Multiport Switch',strcat(biasSystem,'/Multiport Switch'),...
            'MakeNameUnique','on',...
            'Position',[255,200,285,200+20*numconstantBlks],...
            'DataPortOrder','Zero-based contiguous',...
            'Inputs',num2str(numconstantBlks));


            add_line(biasSystem,strcat(get_param(hbiasSystemIn1,'Name'),'/1'),strcat(get_param(hmultiportSwitchBlk,'Name'),'/1'),...
            'autorouting','on');


            initialPos=[100,245,130,275];
            for ii=1:numconstantBlks
                hconstantBlk=add_block('hdlsllib/Sources/Constant',strcat(biasSystem,'/Constant',num2str(ii)),...
                'MakeNameUnique','on',...
                'Value',strcat(mixedDataType,'(',systemParameters.BiasParameter{1,i},'(:,:,',num2str(ii),'))'),...
                'SampleTime','-1',...
                'Position',initialPos);
                initialPos=initialPos+[0,40,0,40];
                add_line(biasSystem,strcat(get_param(hconstantBlk,'Name'),'/1'),strcat(get_param(hmultiportSwitchBlk,'Name'),'/',num2str(ii+1)),...
                'autorouting','on');
            end


            add_line(biasSystem,strcat(get_param(hmultiportSwitchBlk,'Name'),'/1'),strcat(get_param(hbiasSystemOut1,'Name'),'/1'),...
            'autorouting','on')
        else

            hterminatorBiasBlk=add_block('hdlsllib/Sinks/Terminator',strcat(partitionSubsystem,'/Bias'),...
            'MakeNameUnique','on',...
            'Position',[205,235,225,255]);

            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn3Sel,'Name'),'/1'),strcat(get_param(hterminatorBiasBlk,'Name'),'/1'),...
            'autorouting','on');
        end

        hmatlabFunctionBlk=[];
        if~isempty(systemParameters.nonlinearity{i})
            hmatlabFunctionBlk=add_block('hdlsllib/User-Defined Functions/MATLAB Function',strcat(partitionSubsystem,'/Nonlinearity'),...
            'MakeNameUnique','on',...
            'Position',[205,160,275,210]);
            hmatlabCodeBlk=find(slroot,'-isa','Stateflow.EMChart','Path',getfullname(hmatlabFunctionBlk));

            hmatlabCodeBlk.Script=systemParameters.nonlinearity{i};
            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn4UpstreamState,'Name'),'/1'),strcat(get_param(hmatlabFunctionBlk,'Name'),'/1'),...
            'autorouting','on');
            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn1Input,'Name'),'/1'),strcat(get_param(hmatlabFunctionBlk,'Name'),'/2'),...
            'autorouting','on');
            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn3Sel,'Name'),'/1'),strcat(get_param(hmatlabFunctionBlk,'Name'),'/3'),...
            'autorouting','on');
        end




        numsumInputs=numel([hmultiplyStateBlk,hmultiplyInputBlk,hbiasSystem,hmatlabFunctionBlk]);

        if numsumInputs==0

            hsumBlk=add_block('hdlsllib/Sources/Constant',strcat(partitionSubsystem,'/Output Sum'),...
            'MakeNameUnique','on',...
            'Value',strcat(mixedDataType,'(','0',')'),...
            'SampleTime','-1',...
            'Position',[325,161,355,194]);
        elseif numsumInputs==1

            hsumBlk=hOut1;
        elseif numsumInputs==2

            hsumBlk=add_block('hdlsllib/HDL Floating Point Operations/Add',strcat(partitionSubsystem,'/Output Sum'),...
            'MakeNameUnique','on',...
            'Position',[325,161,355,194],...
            'Inputs','++');
        elseif numsumInputs==3

            hsumBlk=add_block('hdlsllib/HDL Floating Point Operations/Add',strcat(partitionSubsystem,'/Output Sum'),...
            'MakeNameUnique','on',...
            'Position',[325,161,355,204],...
            'Inputs','+++');
        else

            hsumBlk=add_block('hdlsllib/HDL Floating Point Operations/Add',strcat(partitionSubsystem,'/Output Sum'),...
            'MakeNameUnique','on',...
            'Position',[325,161,355,214],...
            'Inputs','++++');


        end
        if i>1

            hconcatBlk=add_block('hdlsllib/Signal Routing/Vector Concatenate',strcat(partitionSubsystem,'/Vector Concatenate'),...
            'MakeNameUnique','on',...
            'Position',[425,151,430,189]);
            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn4UpstreamState,'Name'),'/1'),strcat(get_param(hconcatBlk,'Name'),'/1'),...
            'autorouting','on');
            add_line(partitionSubsystem,strcat(get_param(hsumBlk,'Name'),'/1'),strcat(get_param(hconcatBlk,'Name'),'/2'),...
            'autorouting','on');
            add_line(partitionSubsystem,strcat(get_param(hconcatBlk,'Name'),'/1'),strcat(get_param(hpartitionSubsystemOut1,'Name'),'/1'),...
            'autorouting','on');

        else
            if hsumBlk~=hOut1


                add_line(partitionSubsystem,strcat(get_param(hsumBlk,'Name'),'/1'),strcat(get_param(hpartitionSubsystemOut1,'Name'),'/1'),...
                'autorouting','on');
            end
        end





        k=1;
        if~isempty(hmultiplyInputBlk)
            add_line(partitionSubsystem,strcat(get_param(hmultiplyInputBlk,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
            'autorouting','on');
            k=k+1;
        end
        if~isempty(hmultiplyStateBlk)
            add_line(partitionSubsystem,strcat(get_param(hmultiplyStateBlk,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
            'autorouting','on');
            k=k+1;
        end
        if~isempty(hbiasSystem)
            add_line(partitionSubsystem,strcat(get_param(hbiasSystem,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
            'autorouting','on');
            k=k+1;
        end
        if~isempty(hmatlabFunctionBlk)
            add_line(partitionSubsystem,strcat(get_param(hmatlabFunctionBlk,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
            'autorouting','on');
        end


        if~isempty(hmultiplyStateBlk)
            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn3Sel,'Name'),'/1'),strcat(get_param(hmultiplyStateBlk,'Name'),'/2'),...
            'autorouting','on');
        end
        if~isempty(hmultiplyInputBlk)
            add_line(partitionSubsystem,strcat(get_param(hpartitionSubsystemIn3Sel,'Name'),'/1'),strcat(get_param(hmultiplyInputBlk,'Name'),'/2'),...
            'autorouting','on');
        end

        hlastParitionSubsystem=hpartitionSubsystem;
    end
    add_line(system,strcat(get_param(hpartitionSubsystem,'Name'),'/1'),strcat(get_param(hOut1,'Name'),'/1'),...
    'autorouting','on');


end
