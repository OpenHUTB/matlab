function blockInfo=getBlockInfo(this,hC)


    bfp=hC.SimulinkHandle;

    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    if strcmpi(blockInfo.synthesisTool,'')
        blockInfo.ramAttr_dist='';
        blockInfo.ramAttr_block='';
    else
        blockInfo.ramAttr_dist='distributed';
        blockInfo.ramAttr_block='block';
    end

    blockInfo.FECFrameSource=get_param(bfp,'FECFrameSource');
    blockInfo.FECFrame=get_param(bfp,'FECFrame');
    blockInfo.CodeRateSource=get_param(bfp,'CodeRateSource');
    blockInfo.CodeRateNormal=get_param(bfp,'CodeRateNormal');
    blockInfo.CodeRateShort=get_param(bfp,'CodeRateShort');

    blockInfo.Termination=get_param(bfp,'Termination');
    blockInfo.ParityCheckStatus=strcmpi(get_param(bfp,'ParityCheckStatus'),'on');
    blockInfo.SpecifyInputs=get_param(bfp,'SpecifyInputs');

    blockInfo.Algorithm=get_param(bfp,'Algorithm');
    if strcmpi(blockInfo.Algorithm,'Min-sum')
        blockInfo.ScalingFactor=1;
    else
        blockInfo.ScalingFactor=this.hdlslResolve('ScalingFactor',bfp);
    end


    if(strcmpi(blockInfo.FECFrameSource,'Property'))
        if(strcmpi(blockInfo.FECFrame,'Normal'))
            blockInfo.parIdx=[0,1080,2040,2904,3624,4200,4680,5040,5328,5568,5728,0,0,0,0,0];
            blockInfo.addrWL=13;
        else
            blockInfo.parIdx=[0,288,528,744,944,1088,1208,1304,1384,1448,0,0,0,0,0,0];
            blockInfo.addrWL=11;
        end
    else
        blockInfo.parIdx=[0,1080,2040,2904,3624,4200,4680,5040,5328,5568,5728,0,0,0,0,0,...
        5872,6160,6400,6616,6816,6960,7080,7176,7256,7320,0,0,0,0,0,0];
        blockInfo.addrWL=13;
    end

    blockInfo.colIdx=blockInfo.parIdx/8;

    if strcmpi(blockInfo.FECFrameSource,'Property')
        if strcmpi(blockInfo.CodeRateSource,'Property')&&strcmpi(blockInfo.FECFrame,'Normal')
            if(strcmpi(blockInfo.CodeRateNormal,'1/4'))
                blockInfo.nLayersLUT=1080;
                blockInfo.outLenLUT=16200;
                blockInfo.LUTIndex1=1:135;
                blockInfo.LUTIndex2=1:1080;
                blockInfo.degreeLUT=4;
            elseif(strcmpi(blockInfo.CodeRateNormal,'1/3'))
                blockInfo.nLayersLUT=960;
                blockInfo.outLenLUT=21600;
                blockInfo.LUTIndex1=136:255;
                blockInfo.LUTIndex2=1081:2040;
                blockInfo.degreeLUT=5;
            elseif(strcmpi(blockInfo.CodeRateNormal,'2/5'))
                blockInfo.nLayersLUT=864;
                blockInfo.outLenLUT=25920;
                blockInfo.LUTIndex1=256:363;
                blockInfo.LUTIndex2=2041:2904;
                blockInfo.degreeLUT=6;
            elseif(strcmpi(blockInfo.CodeRateNormal,'1/2'))
                blockInfo.nLayersLUT=720;
                blockInfo.outLenLUT=32400;
                blockInfo.LUTIndex1=364:453;
                blockInfo.LUTIndex2=2905:3624;
                blockInfo.degreeLUT=7;
            elseif(strcmpi(blockInfo.CodeRateNormal,'3/5'))
                blockInfo.nLayersLUT=576;
                blockInfo.outLenLUT=38880;
                blockInfo.LUTIndex1=454:525;
                blockInfo.LUTIndex2=3625:4200;
                blockInfo.degreeLUT=11;
            elseif(strcmpi(blockInfo.CodeRateNormal,'2/3'))
                blockInfo.nLayersLUT=480;
                blockInfo.outLenLUT=43200;
                blockInfo.LUTIndex1=526:585;
                blockInfo.LUTIndex2=4201:4680;
                blockInfo.degreeLUT=10;
            elseif(strcmpi(blockInfo.CodeRateNormal,'3/4'))
                blockInfo.nLayersLUT=360;
                blockInfo.outLenLUT=48600;
                blockInfo.LUTIndex1=586:630;
                blockInfo.LUTIndex2=4681:5040;
                blockInfo.degreeLUT=14;
            elseif(strcmpi(blockInfo.CodeRateNormal,'4/5'))
                blockInfo.nLayersLUT=288;
                blockInfo.outLenLUT=51840;
                blockInfo.LUTIndex1=631:666;
                blockInfo.LUTIndex2=5041:5328;
                blockInfo.degreeLUT=18;
            elseif(strcmpi(blockInfo.CodeRateNormal,'5/6'))
                blockInfo.nLayersLUT=240;
                blockInfo.outLenLUT=54000;
                blockInfo.LUTIndex1=667:696;
                blockInfo.LUTIndex2=5329:5568;
                blockInfo.degreeLUT=22;
            elseif(strcmpi(blockInfo.CodeRateNormal,'8/9'))
                blockInfo.nLayersLUT=160;
                blockInfo.outLenLUT=57600;
                blockInfo.LUTIndex1=697:716;
                blockInfo.LUTIndex2=5569:5728;
                blockInfo.degreeLUT=27;
            else
                blockInfo.nLayersLUT=144;
                blockInfo.outLenLUT=58320;
                blockInfo.LUTIndex1=717:734;
                blockInfo.LUTIndex2=5729:5872;
                blockInfo.degreeLUT=30;
            end
            blockInfo.maxColumns=1440-blockInfo.nLayersLUT;
            blockInfo.layWL=ceil(log2(blockInfo.nLayersLUT))+1;
            blockInfo.ivnWL=ceil(log2(blockInfo.maxColumns))+1;
            blockInfo.parWL=ceil(log2(blockInfo.nLayersLUT))+1;
        elseif strcmpi(blockInfo.CodeRateSource,'Property')&&strcmpi(blockInfo.FECFrame,'Short')
            if(strcmpi(blockInfo.CodeRateShort,'1/4'))%#ok<*IFBDUP>
                blockInfo.nLayersLUT=288;
                blockInfo.outLenLUT=3240;
                blockInfo.LUTIndex1=735:770;
                blockInfo.LUTIndex2=5873:6160;
                blockInfo.degreeLUT=[4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;...
                4;4;4;4;4;4;3;3;3;3;3;3;3;3;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;...
                4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;...
                3;3;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;...
                4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;...
                3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;4;4;4;4;...
                4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4];
            elseif(strcmpi(blockInfo.CodeRateShort,'1/3'))
                blockInfo.nLayersLUT=240;
                blockInfo.outLenLUT=5400;
                blockInfo.LUTIndex1=771:800;
                blockInfo.LUTIndex2=6161:6400;
                blockInfo.degreeLUT=5;
            elseif(strcmpi(blockInfo.CodeRateShort,'2/5'))
                blockInfo.nLayersLUT=216;
                blockInfo.outLenLUT=6480;
                blockInfo.LUTIndex1=801:827;
                blockInfo.LUTIndex2=6401:6616;
                blockInfo.degreeLUT=6;
            elseif(strcmpi(blockInfo.CodeRateShort,'1/2'))
                blockInfo.nLayersLUT=200;
                blockInfo.outLenLUT=7200;
                blockInfo.LUTIndex1=828:852;
                blockInfo.LUTIndex2=6617:6816;
                blockInfo.degreeLUT=[5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;7;7;7;7;7;7;7;7;6;6;6;6;6;6;6;6;4;4;4;4;4;4;4;4;5;5;...
                5;5;5;5;5;5;4;4;4;4;4;4;4;4;5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;5;5;5;5;...
                5;5;5;5;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;5;5;5;5;5;5;...
                5;5;4;4;4;4;4;4;4;4;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;4;4;4;4;4;4;4;4;6;6;6;6;6;6;6;6;...
                5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;7;7;7;7;7;7;7;7;7];
            elseif(strcmpi(blockInfo.CodeRateShort,'3/5'))
                blockInfo.nLayersLUT=144;
                blockInfo.outLenLUT=9720;
                blockInfo.LUTIndex1=853:870;
                blockInfo.LUTIndex2=6817:6960;
                blockInfo.degreeLUT=11;
            elseif(strcmpi(blockInfo.CodeRateShort,'2/3'))
                blockInfo.nLayersLUT=120;
                blockInfo.outLenLUT=10800;
                blockInfo.LUTIndex1=871:885;
                blockInfo.LUTIndex2=6961:7080;
                blockInfo.degreeLUT=10;
            elseif(strcmpi(blockInfo.CodeRateShort,'3/4'))
                blockInfo.nLayersLUT=96;
                blockInfo.outLenLUT=11880;
                blockInfo.LUTIndex1=886:897;
                blockInfo.LUTIndex2=7081:7176;
                blockInfo.degreeLUT=[10;10;10;10;10;10;10;10;12;12;12;12;12;12;12;12;11;11;11;11;11;...
                11;11;11;9;9;9;9;9;9;9;9;10;10;10;10;10;10;10;10;13;13;...
                13;13;13;13;13;13;11;11;11;11;11;11;11;11;12;12;12;12;12;12;12;...
                12;11;11;11;11;11;11;11;11;10;10;10;10;10;10;10;10;11;11;11;11;...
                11;11;11;11;12;12;12;12;12;12;12;12;13];
            elseif(strcmpi(blockInfo.CodeRateShort,'4/5'))
                blockInfo.nLayersLUT=80;
                blockInfo.outLenLUT=12600;
                blockInfo.LUTIndex1=898:907;
                blockInfo.LUTIndex2=7177:7256;
                blockInfo.degreeLUT=[12;12;12;12;12;12;12;12;11;11;11;11;11;11;11;11;13;13;13;13;13;...
                13;13;13;12;12;12;12;12;12;12;12;12;12;12;12;12;12;12;12;13;13;...
                13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;...
                13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13];
            elseif(strcmpi(blockInfo.CodeRateShort,'5/6'))
                blockInfo.nLayersLUT=64;
                blockInfo.outLenLUT=13320;
                blockInfo.LUTIndex1=908:915;
                blockInfo.LUTIndex2=7257:7320;
                blockInfo.degreeLUT=[16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;...
                16;16;16;16;16;16;16;16;16;16;16;19;19;19;19;19;19;19;19;18;18;...
                18;18;18;18;18;18;19;19;19;19;19;19;19;19;17;17;17;17;17;17;17;17;17];
            else
                blockInfo.nLayersLUT=40;
                blockInfo.outLenLUT=14400;
                blockInfo.LUTIndex1=916:920;
                blockInfo.LUTIndex2=7321:7360;
                blockInfo.degreeLUT=27;
            end
            blockInfo.maxColumns=360-blockInfo.nLayersLUT;
            blockInfo.ivnWL=ceil(log2(blockInfo.maxColumns))+1;
            blockInfo.layWL=ceil(log2(blockInfo.nLayersLUT))+1;
            blockInfo.parWL=ceil(log2(blockInfo.nLayersLUT))+1;
            if(strcmpi(blockInfo.CodeRateShort,'5/6')||strcmpi(blockInfo.CodeRateShort,'8/9'))
                blockInfo.layWL=blockInfo.layWL+1;
                blockInfo.parWL=blockInfo.parWL+1;
            end

        elseif strcmpi(blockInfo.FECFrame,'Normal')
            blockInfo.nLayersLUT=[1080,960,864,720,576,480,360,288,240,160,144,144,144,144,144,144];
            blockInfo.outLenLUT=[16200,21600,25920,32400,38880,43200,48600,51840,54000,57600,58320,58320,58320,58320,58320,58320];
            blockInfo.LUTIndex1=1:734;
            blockInfo.LUTIndex2=1:5872;
            blockInfo.degreeLUT=[4;5;6;7;11;10;14;18;22;27;30;30;30;30;30;30];
            blockInfo.maxColumns=1296;
            blockInfo.layWL=11;
            blockInfo.ivnWL=11;
            blockInfo.parWL=11;
        else
            blockInfo.nLayersLUT=[288,240,216,200,144,120,96,80,64,40,40,40,40,40,40,40];
            blockInfo.outLenLUT=[3240,5400,6480,7200,9720,10800,11880,12600,13320,14400,14400,14400,14400,14400,14400,14400];
            blockInfo.LUTIndex1=735:920;
            blockInfo.LUTIndex2=5873:7360;
            blockInfo.degreeLUT=[4;5;6;7;11;10;13;13;19;27;27;27;27;27;27;27];
            blockInfo.maxColumns=320;
            blockInfo.layWL=9;
            blockInfo.ivnWL=9;
            blockInfo.parWL=9;
        end
    else
        blockInfo.nLayersLUT=[1080,960,864,720,576,480,360,288,240,160,144,144,144,144,144,144,288,240,216...
        ,200,144,120,96,80,64,40,40,40,40,40,40,40];
        blockInfo.outLenLUT=[16200,21600,25920,32400,38880,43200,48600,51840,54000,57600,58320,58320,58320,58320...
        ,58320,58320,3240,5400,6480,7200,9720,10800,11880,12600,13320,14400,14400,14400,14400,14400,14400,14400];
        blockInfo.LUTIndex1=1:920;
        blockInfo.LUTIndex2=1:7360;
        blockInfo.degreeLUT=[4;5;6;7;11;10;14;18;22;27;30;30;30;30;30;30];
        blockInfo.maxColumns=1296;
        blockInfo.layWL=11;
        blockInfo.ivnWL=11;
        blockInfo.parWL=11;
    end

    blockInfo.maxOutWL=ceil(log2(max(blockInfo.outLenLUT)));


    if strcmpi(blockInfo.Termination,'Early')
        m=this.hdlslResolve('MaxNumIterations',bfp);
        blockInfo.NumIterations=m;
    else
        if strcmpi(blockInfo.SpecifyInputs,'Property')
            m=this.hdlslResolve('NumIterations',bfp);
            blockInfo.NumIterations=m;
        else
            blockInfo.NumIterations=8;
        end
    end

    blockInfo.memDepth=45;
    tp1info=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tp1info=tp1info;
    blockInfo.InputWL=tp1info.wordsize;
    blockInfo.InputFL=tp1info.binarypoint;
    blockInfo.VectorSize=tp1info.dims;

    if blockInfo.ScalingFactor==1
        aFL=-blockInfo.InputFL;
    else
        aFL=-blockInfo.InputFL+4;
    end

    blockInfo.alphaWL=blockInfo.InputWL+blockInfo.InputFL+3+aFL;
    blockInfo.betaWL=blockInfo.alphaWL-2;
    blockInfo.minWL=blockInfo.betaWL-1;
    blockInfo.alphaFL=-aFL;
    blockInfo.betadecmpWL=36;

    blockInfo.realMax=double(fi(realmax,1,blockInfo.alphaWL,-blockInfo.alphaFL));


end