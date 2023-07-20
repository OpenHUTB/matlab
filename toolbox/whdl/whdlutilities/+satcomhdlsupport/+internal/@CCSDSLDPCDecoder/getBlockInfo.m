function blockInfo=getBlockInfo(this,hC)








    bfp=hC.SimulinkHandle;

    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    blockInfo.LDPCConfiguration=get_param(bfp,'LDPCConfiguration');
    if strcmpi(blockInfo.synthesisTool,'')
        blockInfo.ramAttr_dist='';
        blockInfo.ramAttr_block='';
        blockInfo.vnuRAM='';
    else
        blockInfo.ramAttr_dist='distributed';
        blockInfo.ramAttr_block='block';
        if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
            blockInfo.vnuRAM='distributed';
        else
            blockInfo.vnuRAM='block';
        end

    end

    blockInfo.Termination=get_param(bfp,'Termination');
    blockInfo.ParityCheckStatus=strcmp(get_param(bfp,'ParityCheckStatus'),'on');
    blockInfo.SpecifyInputs=get_param(bfp,'SpecifyInputs');
    if strcmpi(blockInfo.SpecifyInputs,'Property')
        if strcmpi(blockInfo.Termination,'Early')
            m=this.hdlslResolve('MaxNumIterations',bfp);
            blockInfo.NumIterations=m;

        else
            m=this.hdlslResolve('NumIterations',bfp);
            blockInfo.NumIterations=m;
        end
    else
        blockInfo.NumIterations=8;
    end

    if strcmpi(blockInfo.Termination,'Early')
        blockInfo.earlyFlag=true;
    else
        blockInfo.earlyFlag=false;
    end

    tp1info=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tp1info=tp1info;
    blockInfo.InputWL=tp1info.wordsize;
    blockInfo.InputFL=tp1info.binarypoint;
    blockInfo.alphaWL=blockInfo.InputWL+blockInfo.InputFL+2-blockInfo.InputFL;
    blockInfo.betaWL=blockInfo.InputWL+blockInfo.InputFL-blockInfo.InputFL;
    blockInfo.minWL=blockInfo.InputWL+blockInfo.InputFL-1-blockInfo.InputFL;
    blockInfo.alphaFL=blockInfo.InputFL;

    if tp1info.dims==1
        blockInfo.scalarFlag=true;
        blockInfo.outWL=15;
        blockInfo.outLenLUT=[1024;4096;16384;16384];
        blockInfo.vectorSize=1;
    else
        blockInfo.scalarFlag=false;
        blockInfo.outWL=12;
        blockInfo.outLenLUT=[128;512;2048;2048];
        blockInfo.vectorSize=8;
    end

    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        blockInfo.layWL=5;
        blockInfo.vaddrWL=7;
        blockInfo.vWL=6;
        blockInfo.cWL=8;
        blockInfo.memDepth=64;
        blockInfo.betaCompWL=32;
        blockInfo.betaIdxWL=8;
        blockInfo.InputLength=8160/blockInfo.vectorSize;
    else
        blockInfo.layWL=8;
        blockInfo.vaddrWL=5;
        blockInfo.vWL=7;
        blockInfo.cWL=9;
        blockInfo.memDepth=128;
        blockInfo.betaCompWL=31;
        blockInfo.betaIdxWL=6;
        blockInfo.InputLength=[2048,1536,1280,1280,8192,6144,5120,5120...
        ,32768,24576,20480,20480,1280,5120,20480,20480]/blockInfo.vectorSize;
    end
    blockInfo.nRowLUT=[12,12,12,12,48,24,12,12,192,96,48,48,192,96,48,48]-1;

    blockInfo.sumLUT=[0;252;384;384;12;264;396;396;60;288;408;408;408;408;408;408];
    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        blockInfo.ncolLUT=[0;56;112;168;224;280;336;392;448;511;574;637;700;...
        764;827;890];
    else
        blockInfo.ncolLUT=[0;3;6;9;12;18;24;30;36;42;48;
        54;60;64;68;72;76;79;82;85;88;91;
        94;97;100;103;106;109;112;121;130;139;148;
        157;166;175;184;193;202;211;220;229;238;247;
        256;266;276;286;296;306;316;326;336;346;356;
        366;376;386;396;406;416;420;424;428;432;436;
        440;444;448;452;456;460;464;468;472;476;480;
        483;486;489;492;495;498;501;504;507;510;513;
        516;519;522;525;528;531;534;537;540;543;546;
        549;552;555;558;561;564;567;570;573;576;579;
        582;585;588;591;594;597;600;603;606;609;612;
        615;618;621;624;633;642;651;660;669;678;687;
        696;705;714;723;732;741;750;759;768;777;786;
        795;804;813;822;831;840;849;858;867;876;885;
        894;903;912;921;930;939;948;957;966;975;984;
        993;1002;1011;1020;1029;1038;1047;1056;1065;1074;1083;
        1092;1101;1110;1119;1128;1137;1146;1155;1164;1173;1182;
        1191;1200;1210;1220;1230;1240;1250;1260;1270;1280;1290;
        1300;1310;1320;1330;1340;1350;1360;1370;1380;1390;1400;
        1410;1420;1430;1440;1450;1460;1470;1480;1490;1500;1510;
        1520;1530;1540;1550;1560;1570;1580;1590;1600;1610;1620;
        1630;1640;1650;1660;1670;1680;1690;1700;1710;1720;1730;
        1740;1750;1760;1770;1780;1790;1800;1810;1820;1830;1840;
        1843;1846;1849;1852;1862;1872;1882;1892;1902;1912;1922;
        1932;1936;1940;1943;1946;1949;1952;1955;1958;1974;1990;
        2006;2022;2038;2054;2070;2086;2103;2120;2137;2154;2171;
        2188;2205;2222;2226;2230;2234;2238;2242;2246;2250;2254;
        2257;2260;2263;2266;2269;2272;2275;2278;2281;2284;2287;
        2290;2293;2296;2299;2302;2305;2308;2311;2314;2317;2320;
        2323;2326;2342;2358;2374;2390;2406;2422;2438;2454;2470;
        2486;2502;2518;2534;2550;2566;2582;2598;2614;2630;2646;
        2662;2678;2694;2710;2726;2742;2758;2774;2790;2806;2822;
        2838;2855;2872;2889;2906;2923;2940;2957;2974;2991;3008;
        3025;3042;3059;3076;3093;3110;3127;3144;3161;3178;3195;
        3212;3229;3246;3263;3280;3297;3314;3331;3348;3365;3382;
        3385;3388;3391;3394;3412;3430;3448;3466;3484;3502;3520;
        3538;3541;3544;3547;3550;3568;3586;3604;3622;3640;3658;
        3676;3694;3698;3702;3706;3710;3713;3716;3719;3722;3725;
        3728;3731;3734;3737;3740;3743;3746;3776;3806;3836;3866;
        3896;3926;3956;3986;4016;4046;4076;4106;4136;4166;4196;
        4226;4257;4288;4319;4350;4381;4412;4443;4474;4505;4536;
        4567;4598;4629;4660;4691;];
    end

end


