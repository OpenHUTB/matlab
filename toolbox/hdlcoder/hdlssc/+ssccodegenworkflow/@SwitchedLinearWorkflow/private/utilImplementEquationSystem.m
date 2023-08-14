function utilImplementEquationSystem(hIn1,hIn2State,hIn3Sel,hOut1,...
    system,systemParameters,sschdlProductSumCustomLatency,hInJ)




    if~isempty(hInJ)
        set_param(hInJ,'Position',[795,318,825,332]);
    end


    set_param(hIn1,'Position',[795,33,825,47]);
    set_param(hIn2State,'Position',[795,133,825,147]);
    set_param(hIn3Sel,'Position',[795,253,825,267]);
    set_param(hOut1,'Position',[1185,63,1215,77]);


    if strcmpi(systemParameters.AlgorithmDataType,'MixedDoubleSingle')
        coeffDataType='single';
        stateDataType='double';

    else
        coeffDataType=systemParameters.AlgorithmDataType;
        stateDataType=systemParameters.AlgorithmDataType;
    end




    hmultiplyStateBlk=[];
    if nnz(systemParameters.StateParameter{2})>0

        hmultiplyStateBlk=add_block('hdlssclib/NFPSparseConstMultiply',strcat(system,'/Multiply State'),...
        'MakeNameUnique','on',...
        'Position',[905,120,985,200],...
        'constMatrix',strcat(coeffDataType,'(',systemParameters.StateParameter{1},')'));

        add_line(system,strcat(get_param(hIn2State,'Name'),'/1'),strcat(get_param(hmultiplyStateBlk,'Name'),'/1'),...
        'autorouting','on');
        sschdlSetNFPCustomLatency(hmultiplyStateBlk,sschdlProductSumCustomLatency);
    else

        hterminatorMultiplyStateBlk=add_block('hdlsllib/Sinks/Terminator',strcat(system,'/Multiply State'),...
        'MakeNameUnique','on',...
        'Position',[935,130,955,150]);

        add_line(system,strcat(get_param(hIn2State,'Name'),'/1'),strcat(get_param(hterminatorMultiplyStateBlk,'Name'),'/1'),...
        'autorouting','on');
    end


    hmultiplyInputBlk=[];
    if nnz(systemParameters.InputParameter{2})>0

        hmultiplyInputBlk=add_block('hdlssclib/NFPSparseConstMultiply',strcat(system,'/Multiply Input'),...
        'MakeNameUnique','on',...
        'Position',[905,20,985,100],...
        'constMatrix',strcat(coeffDataType,'(',systemParameters.InputParameter{1},')'));

        add_line(system,strcat(get_param(hIn1,'Name'),'/1'),strcat(get_param(hmultiplyInputBlk,'Name'),'/1'),...
        'autorouting','on');
        sschdlSetNFPCustomLatency(hmultiplyInputBlk,sschdlProductSumCustomLatency);
    else

        hterminatorMultiplyInputBlk=add_block('hdlsllib/Sinks/Terminator',strcat(system,'/Multiply Input'),...
        'MakeNameUnique','on',...
        'Position',[935,30,955,50]);

        add_line(system,strcat(get_param(hIn1,'Name'),'/1'),strcat(get_param(hterminatorMultiplyInputBlk,'Name'),'/1'),...
        'autorouting','on');
    end


    hmultiplyJBlk=[];
    if isfield(systemParameters,'CurrentSourceParameter')
        if nnz(systemParameters.CurrentSourceParameter{2})>0

            hmultiplyJBlk=add_block('hdlssclib/NFPSparseConstMultiply',strcat(system,'/Multiply Current Sources'),...
            'MakeNameUnique','on',...
            'Position',[905,305,985,385],...
            'constMatrix',strcat(systemParameters.AlgorithmDataType,'(',systemParameters.CurrentSourceParameter{1},')'));

            add_line(system,strcat(get_param(hInJ,'Name'),'/1'),strcat(get_param(hmultiplyJBlk,'Name'),'/1'),...
            'autorouting','on');
            sschdlSetNFPCustomLatency(hmultiplyJBlk,sschdlProductSumCustomLatency);

        else


            hterminatorJBlk=add_block('hdlsllib/Sinks/Terminator',strcat(system,'/Jin'),...
            'MakeNameUnique','on',...
            'Position',[935,335,955,355]);

            add_line(system,strcat(get_param(hInJ,'Name'),'/1'),strcat(get_param(hterminatorJBlk,'Name'),'/1'),...
            'autorouting','on');


        end
    end





    hbiasSystem=[];
    if nnz(systemParameters.BiasParameter{2})>0

        hbiasSystem=utilAddSubsystem(system,'Bias',[920,236,975,284],'white');
        biasSystem=getfullname(hbiasSystem);


        hbiasSystemIn1=add_block('hdlsllib/Sources/In1',strcat(biasSystem,'/Sel'),...
        'MakeNameUnique','on');

        hbiasSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(biasSystem,'/Out1'),...
        'MakeNameUnique','on');

        add_line(system,strcat(get_param(hIn3Sel,'Name'),'/1'),strcat(get_param(hbiasSystem,'Name'),'/1'),...
        'autorouting','on');


        set_param(hbiasSystemIn1,'Position',[20,148,50,162]);
        set_param(hbiasSystemOut1,'Position',[475,130,505,144]);

        biasSize=size(systemParameters.BiasParameter{2});





        if size(biasSize,2)==2


            hconstantBlk=add_block('hdlsllib/Sources/Constant',strcat(biasSystem,'/Bias'),...
            'MakeNameUnique','on',...
            'Value',strcat(coeffDataType,'(',systemParameters.BiasParameter{1},')'),...
            'SampleTime',systemParameters.SampleTime,...
            'Position',[100,95,130,125]);

            hterminator=add_block('hdlsllib/Sinks/Terminator',strcat(biasSystem,'/Terminator'),...
            'MakeNameUnique','on');
            add_line(biasSystem,strcat(get_param(hbiasSystemIn1,'Name'),'/1'),strcat(get_param(hterminator,'Name'),'/1'),...
            'autorouting','on')
            if strcmpi(systemParameters.AlgorithmDataType,'MixedDoubleSingle')
                singleConvertBlk=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(biasSystem,'/Data Type Conversion'),...
                'MakeNameUnique','on',...
                'OutDataTypeStr','double',...
                'RndMeth','Nearest',...
                'Position',[345,124,395,166]);


                add_line(biasSystem,strcat(get_param(hconstantBlk,'Name'),'/1'),strcat(get_param(singleConvertBlk,'Name'),'/1'),...
                'autorouting','on')


                add_line(biasSystem,strcat(get_param(singleConvertBlk,'Name'),'/1'),strcat(get_param(hbiasSystemOut1,'Name'),'/1'),...
                'autorouting','on')
            else
                add_line(biasSystem,strcat(get_param(hconstantBlk,'Name'),'/1'),strcat(get_param(hbiasSystemOut1,'Name'),'/1'),...
                'autorouting','on')
            end

        else





            hconstantBlk=add_block('hdlsllib/Sources/Constant',strcat(biasSystem,'/Bias'),...
            'MakeNameUnique','on',...
            'Value',strcat(coeffDataType,'(reshape(',systemParameters.BiasParameter{1},',',num2str(biasSize(1)),',',num2str(biasSize(3)),'))'),...
            'SampleTime',systemParameters.SampleTime,...
            'Position',[100,95,130,125]);


            hdataConvert=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(biasSystem,'/Data Type Conversion'),...
            'MakeNameUnique','on',...
            'OutDataTypeStr','uint32',...
            'Position',[100,140,160,170]);



            hselectorBlk=add_block('hdlsllib/Signal Routing/Selector',strcat(biasSystem,'/Selector'),...
            'MakeNameUnique','on',...
            'NumberOfDimensions','2',...
            'IndexMode','Zero-based',...
            'IndexOptionArray',{'Select All','Index vector (port)'},...
            'Position',[230,124,280,166]);


            add_line(biasSystem,strcat(get_param(hconstantBlk,'Name'),'/1'),strcat(get_param(hselectorBlk,'Name'),'/1'),...
            'autorouting','on')

            add_line(biasSystem,strcat(get_param(hbiasSystemIn1,'Name'),'/1'),strcat(get_param(hdataConvert,'Name'),'/1'),...
            'autorouting','on')


            add_line(biasSystem,strcat(get_param(hdataConvert,'Name'),'/1'),strcat(get_param(hselectorBlk,'Name'),'/2'),...
            'autorouting','on')


            if strcmpi(systemParameters.AlgorithmDataType,'MixedDoubleSingle')
                singleConvertBlk=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(biasSystem,'/Data Type Conversion'),...
                'MakeNameUnique','on',...
                'OutDataTypeStr','double',...
                'RndMeth','Nearest',...
                'Position',[345,124,395,166]);


                add_line(biasSystem,strcat(get_param(hselectorBlk,'Name'),'/1'),strcat(get_param(singleConvertBlk,'Name'),'/1'),...
                'autorouting','on')


                add_line(biasSystem,strcat(get_param(singleConvertBlk,'Name'),'/1'),strcat(get_param(hbiasSystemOut1,'Name'),'/1'),...
                'autorouting','on')
            else

                add_line(biasSystem,strcat(get_param(hselectorBlk,'Name'),'/1'),strcat(get_param(hbiasSystemOut1,'Name'),'/1'),...
                'autorouting','on')
            end
        end

    else

        hterminatorBiasBlk=add_block('hdlsllib/Sinks/Terminator',strcat(system,'/Bias'),...
        'MakeNameUnique','on',...
        'Position',[935,250,955,270]);

        add_line(system,strcat(get_param(hIn3Sel,'Name'),'/1'),strcat(get_param(hterminatorBiasBlk,'Name'),'/1'),...
        'autorouting','on');
    end




    numsumInputs=numel([hmultiplyStateBlk,hmultiplyInputBlk,hbiasSystem,hmultiplyJBlk]);

    if numsumInputs==0

        hsumBlk=add_block('hdlsllib/Sources/Constant',strcat(system,'/Output Sum'),...
        'MakeNameUnique','on',...
        'Value',strcat(stateDataType,'(','0',')'),...
        'SampleTime',systemParameters.SampleTime,...
        'Position',[1100,51,1130,84]);
    elseif numsumInputs==1

        hsumBlk=hOut1;
    else
        plusStr=repmat('+',1,numsumInputs);


        hsumBlk=add_block('hdlsllib/HDL Floating Point Operations/Add',strcat(system,'/Output Sum'),...
        'MakeNameUnique','on',...
        'Position',[1100,51,1130,84],...
        'Inputs',plusStr);
    end

    if hsumBlk~=hOut1
        add_line(system,strcat(get_param(hsumBlk,'Name'),'/1'),strcat(get_param(hOut1,'Name'),'/1'),...
        'autorouting','on');
    end





    k=1;
    if~isempty(hmultiplyInputBlk)
        add_line(system,strcat(get_param(hmultiplyInputBlk,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
        'autorouting','on');
        k=k+1;
    end
    if~isempty(hmultiplyStateBlk)
        add_line(system,strcat(get_param(hmultiplyStateBlk,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
        'autorouting','on');
        k=k+1;
    end
    if~isempty(hbiasSystem)
        add_line(system,strcat(get_param(hbiasSystem,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
        'autorouting','on');
        k=k+1;
    end
    if~isempty(hmultiplyJBlk)
        add_line(system,strcat(get_param(hmultiplyJBlk,'Name'),'/1'),strcat(get_param(hsumBlk,'Name'),'/',num2str(k)),...
        'autorouting','on');
    end


    if~isempty(hmultiplyStateBlk)
        add_line(system,strcat(get_param(hIn3Sel,'Name'),'/1'),strcat(get_param(hmultiplyStateBlk,'Name'),'/2'),...
        'autorouting','on');
    end
    if~isempty(hmultiplyInputBlk)
        add_line(system,strcat(get_param(hIn3Sel,'Name'),'/1'),strcat(get_param(hmultiplyInputBlk,'Name'),'/2'),...
        'autorouting','on');
    end
    if~isempty(hmultiplyJBlk)
        add_line(system,strcat(get_param(hIn3Sel,'Name'),'/1'),strcat(get_param(hmultiplyJBlk,'Name'),'/2'),...
        'autorouting','on');
    end
end


function sschdlSetNFPCustomLatency(sparseMultBlk,nfpCustomLatency)
    if~isempty(nfpCustomLatency)&&(nfpCustomLatency>=0)
        sparseMultObj=get_param(sparseMultBlk,'Object');
        hdlBlkPath=[sparseMultObj.Path,'/',sparseMultObj.Name];
        hdlset_param(hdlBlkPath,'LatencyStrategy','Custom');
        hdlset_param(hdlBlkPath,'NFPCustomLatency',nfpCustomLatency);
    end
end


