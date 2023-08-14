classdef PolarHelper





%#codegen
    methods
        function obj=PolarHelper(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
        end
    end

    methods(Static)
        function paramsOut=setupEncoder(blk,paramsIn)
            paramsOut=struct(...
            'nMax',9,...
            'sequence',[],...
            'itlvPat',[],...
            'rowWeights',[],...
            'nProp',9,...
            'NSub1Prop',511,...
            'FProp',[],...
            'itlvMapProp',[],...
            'parityEnProp',0,...
            'qPCProp',zeros(3,1),...
            'maskLatency',0...
            );

            sequence1024=nrhdl.internal.PolarHelper.getSequence;
            itlvPat=nrhdl.internal.PolarHelper.getItlvPattern;

            sequence512=sequence1024(sequence1024<512);
            sequence256=sequence512(sequence512<256);
            sequence128=sequence256(sequence256<128);
            sequence64=sequence128(sequence128<64);
            sequence32=sequence64(sequence64<32);
            sequence=[sequence32;sequence64;sequence128;sequence256;sequence512;sequence1024];

            configurationSourceOpts={'Property','Input port'};
            configurationSource=configurationSourceOpts{paramsIn.configurationSource};

            linkDirectionOpts={'Uplink','Downlink'};
            linkDirection=linkDirectionOpts{paramsIn.linkDirection};
            if linkDirection=="Uplink"
                nMax=10;

                rowWeights=nrhdl.internal.PolarHelper.getRowWeights(1024);

                (set_param([blk,'/frameMap/addrTranslate'],'LabelModeActiveChoice','uplink'));
                (set_param([blk,'/encode/Stage 9'],'LabelModeActiveChoice','uplink'));

                paramsOut.nMax=nMax;
                paramsOut.sequence=sequence;
                paramsOut.itlvPat=itlvPat;
                paramsOut.rowWeights=rowWeights;

                if get_param(blk,'ConfigurationSource')=="Input port"
                    (set_param([blk,'/configure/configurePort/itlvMap'],'LabelModeActiveChoice','uplink'));
                    (set_param([blk,'/configure/configurePort/validateConfig'],'LabelModeActiveChoice','uplink'));
                    (set_param([blk,'/configure/configurePort/parityConfig'],'LabelModeActiveChoice','uplink'));
                    (set_param([blk,'/configure/configurePort/sequence/parityConfig'],'LabelModeActiveChoice','uplink'));
                end
            else
                nMax=9;

                (set_param([blk,'/frameMap/addrTranslate'],'LabelModeActiveChoice','downlink'));
                (set_param([blk,'/encode/Stage 9'],'LabelModeActiveChoice','downlink'));

                paramsOut.nMax=nMax;
                paramsOut.sequence=sequence;
                paramsOut.itlvPat=itlvPat;

                if configurationSource=="Input port"
                    (set_param([blk,'/configure/configurePort/itlvMap'],'LabelModeActiveChoice','downlink'));
                    (set_param([blk,'/configure/configurePort/validateConfig'],'LabelModeActiveChoice','downlink'));
                    (set_param([blk,'/configure/configurePort/parityConfig'],'LabelModeActiveChoice','downlink'));
                    (set_param([blk,'/configure/configurePort/sequence/parityConfig'],'LabelModeActiveChoice','downlink'));
                end
            end

            if configurationSource=="Input port"
                replace_block([blk,'/K'],'Constant','Inport','noprompt');
                replace_block([blk,'/E'],'Constant','Inport','noprompt');

                set_param([blk,'/configure'],'LabelModeActiveChoice','Port');

                if linkDirection=="Downlink"
                    set_param([blk,'/frameMap/addrTranslate/itlv'],'LabelModeActiveChoice','Port');
                end
            else
                replace_block([blk,'/K'],'Inport','Constant','noprompt');
                set_param([blk,'/K'],'Value','MessageLength','SampleTime','-1','OutDataTypeStr','fixdt(0,10,0)');
                replace_block([blk,'/E'],'Inport','Constant','noprompt');
                set_param([blk,'/E'],'Value','Rate','SampleTime','-1','OutDataTypeStr','fixdt(0,14,0)');

                K=paramsIn.K;
                E=paramsIn.E;

                nrhdl.internal.PolarHelper.validateProps(linkDirection,K,E);

                [n,N]=nrhdl.internal.PolarHelper.getN(K,E,nMax);
                [F,qPC]=nrhdl.internal.PolarHelper.construct(K,E,N);



                F(qPC+1)=0;

                itlvMap=[nrhdl.internal.PolarHelper.interleaveMap(K);zeros(1024-K,1)];

                parityEn=(K>=18&&K<=25);

                paramsOut.nProp=n;
                paramsOut.NSub1Prop=N-1;
                paramsOut.FProp=double(F);
                paramsOut.itlvMapProp=itlvMap;
                paramsOut.parityEnProp=parityEn;
                paramsOut.qPCProp=qPC;

                latency=nrhdl.internal.PolarHelper.encoderLatency(n,K);

                paramsOut.maskLatency=latency;

                set_param([blk,'/configure'],'LabelModeActiveChoice','Property');
                if linkDirection=="Downlink"
                    set_param([blk,'/frameMap/addrTranslate/itlv'],'LabelModeActiveChoice','Property');
                end
            end
        end

        function validateProps(linkDirection,K,E)
            validateattributes(K,{'double','single'},{'scalar','integer'},'PolarEncoder','K');
            validateattributes(E,{'double','single'},{'scalar','integer'},'PolarEncoder','E');

            if linkDirection=="Uplink"
                if~(K>=31&&K<=1023||K>=18&&K<=25)
                    coder.internal.error('whdl:PolarCode:KRangeUplink',string(K));
                end
            else
                if K<36||K>164
                    coder.internal.error('whdl:PolarCode:KRangeDownlink',string(K));
                end
            end

            if E>8192
                coder.internal.error('whdl:PolarCode:EGreaterThanMax',string(E));
            end

            if E<=K
                coder.internal.error('whdl:PolarCode:KGreaterThanE',string(K),string(E));
            end
        end

        function latency=encoderLatency(n,K)
            pipeline=15+n;

            procDelay=sum(2.^(1:n-1));

            latency=K+procDelay+pipeline;
        end

        function[n,N]=getN(K,E,nMax)

            cl2e=ceil(log2(E));
            if(E<=(9/8)*2^(cl2e-1))&&(K/E<9/16)
                n1=cl2e-1;
            else
                n1=cl2e;
            end

            rmin=1/8;
            n2=ceil(log2(K/rmin));

            nMin=5;
            n=max(min([n1,n2,nMax]),nMin);
            N=2^n;
        end

        function[F,qPC]=construct(K,E,N)


            if(K>=18&&K<=25)
                nPC=3;
                if(E-K>189)
                    nPCwm=1;
                else
                    nPCwm=0;
                end
            else
                nPC=0;
                nPCwm=0;
            end

            s10=nrhdl.internal.PolarHelper.getSequence;
            idx=(s10<N);
            qSeq=s10(idx);

            jn=nrhdl.internal.PolarHelper.subblockInterleaveMap(N);
            qF=[];
            if E<N
                if K/E<=7/16
                    for i=0:(N-E-1)
                        qF=[qF;jn(i+1)];%#ok
                    end
                    if E>=3*N/4
                        puncLim=ceil(3*N/4-E/2);
                        qF=[qF;(0:puncLim-1).'];
                    else
                        puncLim=ceil(9*N/16-E/4);
                        qF=[qF;(0:puncLim-1).'];
                    end
                    qF=unique(qF);
                else
                    for i=E:N-1
                        qF=[qF;jn(i+1)];%#ok
                    end
                end
            end

            qI=zeros(K+nPC,1);
            F=false(N,1);

            j=1;
            for i=1:N
                if any(qSeq(i)==qF)
                    continue;
                end

                qI(j)=qSeq(i);
                F(qSeq(i)+1)=1;

                if j==K+nPC
                    break;
                end

                j=j+1;
            end
            qPC=zeros(3,1);
            if nPC>0
                qPC(1:(nPC-nPCwm),1)=qI(end-(nPC-nPCwm)+1:end);

                if nPCwm>0
                    rowWeights=nrhdl.internal.PolarHelper.getRowWeights(N);

                    qtildeI=qI(1:end-nPC,1);
                    wt_qtildeI=rowWeights(qtildeI+1);
                    minwt=min(wt_qtildeI);
                    allminwtIdx=find(wt_qtildeI==minwt);


                    qPC(nPC,1)=qtildeI(allminwtIdx(1));
                end
            end
        end

        function sequence=getSequence




            sequence=[0,518,94,214,364,414,819,966
            1,54,204,309,654,223,814,755
            2,83,298,188,659,663,439,859
            4,57,400,449,335,692,929,940
            8,521,608,217,480,835,490,830
            16,112,352,408,315,619,623,911
            32,135,325,609,221,472,671,871
            3,78,533,596,370,455,739,639
            5,289,155,551,613,796,916,888
            64,194,210,650,422,809,463,479
            9,85,305,229,425,714,843,946
            6,276,547,159,451,721,381,750
            17,522,300,420,614,837,497,969
            10,58,109,310,543,716,930,508
            18,168,184,541,235,864,821,861
            128,139,534,773,412,810,726,757
            12,99,537,610,343,606,961,970
            33,86,115,657,372,912,872,919
            65,60,167,333,775,722,492,875
            20,280,225,119,317,696,631,862
            256,89,326,600,222,377,729,758
            34,290,306,339,426,435,700,948
            24,529,772,218,453,817,443,977
            36,524,157,368,237,319,741,923
            7,196,656,652,559,621,845,972
            129,141,329,230,833,812,920,761
            66,101,110,391,804,484,382,877
            512,147,117,313,712,430,822,952
            11,176,212,450,834,838,851,495
            40,142,171,542,661,667,730,703
            68,530,776,334,808,488,498,935
            130,321,330,233,779,239,880,978
            19,31,226,555,617,378,742,883
            13,200,549,774,604,459,445,762
            48,90,538,175,433,622,471,503
            14,545,387,123,720,627,635,925
            72,292,308,658,816,437,932,878
            257,322,216,612,836,380,687,735
            21,532,416,341,347,818,903,993
            132,263,271,777,897,461,825,885
            35,149,279,220,243,496,500,939
            258,102,158,314,662,669,846,994
            26,105,337,424,454,679,745,980
            513,304,550,395,318,724,826,926
            80,296,672,673,675,841,732,764
            37,163,118,583,618,629,446,941
            25,92,332,355,898,351,962,967
            22,47,579,287,781,467,936,886
            136,267,540,183,376,438,475,831
            260,385,389,234,428,737,853,947
            264,546,173,125,665,251,867,507
            38,324,121,557,736,462,637,889
            514,208,553,660,567,442,907,984
            96,386,199,616,840,441,487,751
            67,150,784,342,625,469,695,942
            41,153,179,316,238,247,746,996
            144,165,228,241,359,683,828,971
            28,106,338,778,457,842,753,890
            69,55,312,563,399,738,854,509
            42,328,704,345,787,899,857,949
            516,536,390,452,591,670,504,973
            49,577,174,397,678,783,799,1000
            74,548,554,403,434,849,255,892
            272,113,581,207,677,820,964,950
            160,154,393,674,349,728,909,863
            520,79,283,558,245,928,719,759
            288,269,122,785,458,791,477,1008
            528,108,448,432,666,367,915,510
            192,578,353,357,620,901,638,979
            544,224,561,187,363,630,748,953
            70,166,203,236,127,685,944,763
            44,519,63,664,191,844,869,974
            131,552,340,624,782,633,491,954
            81,195,394,587,407,711,699,879
            50,270,527,780,436,253,754,981
            73,641,582,705,626,691,858,982
            15,523,556,126,571,824,478,927
            320,275,181,242,465,902,968,995
            133,580,295,565,681,686,383,765
            52,291,285,398,246,740,910,956
            23,59,232,346,707,850,815,887
            134,169,124,456,350,375,976,985
            384,560,205,358,599,444,870,997
            76,114,182,405,668,470,917,986
            137,277,643,303,790,483,727,943
            82,156,562,569,460,415,493,891
            56,87,286,244,249,485,873,998
            27,197,585,595,682,905,701,766
            97,116,299,189,573,795,931,511
            39,170,354,566,411,473,756,988
            259,61,211,676,803,634,860,1001
            84,531,401,361,789,744,499,951
            138,525,185,706,709,852,731,1002
            145,642,396,589,365,960,823,893
            261,281,344,215,440,865,922,975
            29,278,586,786,628,693,874,894
            43,526,645,647,689,797,918,1009
            98,177,593,348,374,906,502,955
            515,293,535,419,423,715,933,1004
            88,388,240,406,466,807,743,1010
            140,91,206,464,793,474,760,957
            30,584,95,680,250,636,881,983
            146,769,327,801,371,694,494,958
            71,198,564,362,481,254,702,987
            262,172,800,590,574,717,921,1012
            265,120,402,409,413,575,501,999
            161,201,356,570,603,913,876,1016
            576,336,307,788,366,798,847,767
            45,62,301,597,468,811,992,989
            100,282,417,572,655,379,447,1003
            640,143,213,219,900,697,733,990
            51,103,568,311,805,431,827,1005
            148,178,832,708,615,607,934,959
            46,294,588,598,684,489,882,1011
            75,93,186,601,710,866,937,1013
            266,644,646,651,429,723,963,895
            273,202,404,421,794,486,747,1006
            517,592,227,792,252,908,505,1014
            104,323,896,802,373,718,855,1017
            162,392,594,611,605,813,924,1018
            53,297,418,602,848,476,734,991
            193,770,302,410,690,856,829,1020
            152,107,649,231,713,839,965,1007
            77,180,771,688,632,725,938,1015
            164,151,360,653,482,698,884,1019
            768,209,539,248,806,914,506,1021
            268,284,111,369,427,752,749,1022
            274,648,331,190,904,868,945,1023];

            sequence=flipud(sequence(:));
        end

        function pi=interleaveMap(K)
            Kilmax=164;
            pat=nrhdl.internal.PolarHelper.getItlvPattern();
            pi=zeros(K,1);

            KThresh=Kilmax-K;

            k=0;
            for m=0:Kilmax-1
                if pat(m+1)>=KThresh
                    pi(k+1)=pat(m+1)-KThresh;
                    k=k+1;
                end
            end
        end

        function itlvPat=getItlvPattern



            itlvPat=[0;2;4;7;9;14;19;20;24;25;26;28;31;34;42;45;49;...
            50;51;53;54;56;58;59;61;62;65;66;67;69;70;71;72;...
            76;77;81;82;83;87;88;89;91;93;95;98;101;104;106;...
            108;110;111;113;115;118;119;120;122;123;126;127;129;...
            132;134;138;139;140;1;3;5;8;10;15;21;27;29;32;35;...
            43;46;52;55;57;60;63;68;73;78;84;90;92;94;96;99;...
            102;105;107;109;112;114;116;121;124;128;130;133;135;...
            141;6;11;16;22;30;33;36;44;47;64;74;79;85;97;100;...
            103;117;125;131;136;142;12;17;23;37;48;75;80;86;...
            137;143;13;18;38;144;39;145;40;146;41;147;148;149;...
            150;151;152;153;154;155;156;157;158;159;160;161;162;...
            163];
        end

        function jn=subblockInterleaveMap(N)
            pi=nrhdl.internal.PolarHelper.getSubblockItlvPattern;

            jn=zeros(N,1);
            for n=0:N-1
                i=floor(32*n/N);
                jn(n+1)=pi(i+1)*(N/32)+mod(n,N/32);
            end
        end

        function subBlockItlvPat=getSubblockItlvPattern

            subBlockItlvPat=[0;1;2;4;3;5;6;7;8;16;9;17;10;18;11;19;
            12;20;13;21;14;22;15;23;24;25;26;28;27;29;30;31];
        end

        function rowWeights=getRowWeights(N)


            n=log2(N);
            ak0=[1,0;1,1];
            allG=cell(n,1);
            for i=1:n
                allG{i}=zeros(2^i,2^i);
            end
            allG{1}=ak0;
            for i=1:n-1
                allG{i+1}=kron(allG{i},ak0);
            end
            G=allG{n};
            wg=sum(G,2);


            rowWeights=log2(wg);
        end
    end
end

