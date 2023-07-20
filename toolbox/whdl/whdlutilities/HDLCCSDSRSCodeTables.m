function[genPolyBeta,betaPow8,genPoly,MultTable,PowerTable,AntiLogTable,LogTable,D2C,C2D]=HDLCCSDSRSCodeTables(k)





















    m=8;
    codeSize=2^m;



    prim_root=173;





    betaBasis=[1,77,140,243,42,241,176,110];
    betaIndex=int2bit(0:255,8,false)';
    alphaNum=zeros(256,1);
    for ii=1:256

        alphaNum(ii)=xorVec(betaBasis.*betaIndex(ii,:));
    end

    if(k==239)

        genPoly=[1,165,105,27,159,104,152,101,74,101,152,104,159,27,105,165,1]';


        genPolyBeta=uint8(zeros(17,1));
        for ii=1:17
            genPolyBeta(ii)=find(alphaNum==genPoly(ii))-1;
        end


        E=8;

        B=120;
    else

        genPoly=[1,91,127,86,16,30,13,235,97,165,8,42,54,86,171,32,113,32,171,86...
        ,54,42,8,165,97,235,13,30,16,86,127,91,1]';


        genPolyBeta=uint8(zeros(33,1));
        for ii=1:33
            genPolyBeta(ii)=find(alphaNum==genPoly(ii))-1;
        end


        E=16;

        B=112;
    end


    AntiLogTable=uint8([2,4,8,16,32,64,128,135,137,149,173,221,61,122,244,111,222,...
    59,118,236,95,190,251,113,226,67,134,139,145,165,205,29,58,116,232,...
    87,174,219,49,98,196,15,30,60,120,240,103,206,27,54,108,216,55,110,...
    220,63,126,252,127,254,123,246,107,214,43,86,172,223,57,114,228,79,...
    158,187,241,101,202,19,38,76,152,183,233,85,170,211,33,66,132,143,...
    153,181,237,93,186,243,97,194,3,6,12,24,48,96,192,7,14,28,56,112,...
    224,71,142,155,177,229,77,154,179,225,69,138,147,161,197,13,26,52,...
    104,208,39,78,156,191,249,117,234,83,166,203,17,34,68,136,151,169,...
    213,45,90,180,239,89,178,227,65,130,131,129,133,141,157,189,253,125,...
    250,115,230,75,150,171,209,37,74,148,175,217,53,106,212,47,94,188,...
    255,121,242,99,198,11,22,44,88,176,231,73,146,163,193,5,10,20,40,80,...
    160,199,9,18,36,72,144,167,201,21,42,84,168,215,41,82,164,207,25,50,...
    100,200,23,46,92,184,247,105,210,35,70,140,159,185,245,109,218,51,...
    102,204,31,62,124,248,119,238,91,182,235,81,162,195,1]');


    LogTable=uint8([0,1,99,2,198,100,106,3,205,199,188,101,126,107,42,4,141,...
    206,78,200,212,189,225,102,221,127,49,108,32,43,243,5,87,142,232,...
    207,172,79,131,201,217,213,65,190,148,226,180,103,39,222,240,128,...
    177,50,53,109,69,33,18,44,13,244,56,6,155,88,26,143,121,233,112,208,...
    194,173,168,80,117,132,72,202,252,218,138,214,84,66,36,191,152,149,...
    249,227,94,181,21,104,97,40,186,223,76,241,47,129,230,178,63,51,238,...
    54,16,110,24,70,166,34,136,19,247,45,184,14,61,245,164,57,59,7,158,...
    156,157,89,159,27,8,144,9,122,28,234,160,113,90,209,29,195,123,174,...
    10,169,145,81,91,118,114,133,161,73,235,203,124,253,196,219,30,139,...
    210,215,146,85,170,67,11,37,175,192,115,153,119,150,92,250,82,228,...
    236,95,74,182,162,22,134,105,197,98,254,41,125,187,204,224,211,77,...
    140,242,31,48,220,130,171,231,86,179,147,64,216,52,176,239,38,55,12,...
    17,68,111,120,25,154,71,116,167,193,35,83,137,251,20,93,248,151,46,...
    75,185,96,15,237,62,229,246,135,165,23,58,163,60,183]');


    GFMultTable=zeros(2*E,codeSize);
    GFGenPoly=genPoly(2:end);
    for ii=1:2*E
        for jj=0:codeSize-1
            GFMultTable(ii,jj+1)=multiply(jj,GFGenPoly(ii),LogTable,AntiLogTable);
        end
    end
    MultTable=uint8(GFMultTable);


    GFPowerTable=zeros((2*E)+B+1,codeSize);
    for powerExp=0:((2*E)+B)
        for jj=0:codeSize-1
            GFPowerTable(powerExp+1,jj+1)=multiply(jj,power(prim_root,powerExp,LogTable,AntiLogTable),LogTable,AntiLogTable);
        end
    end
    PowerTable=uint8(GFPowerTable);


    dualNum=0:255;
    dualNumBits=int2bit(dualNum,8,true)';
    d2cMap=[1,1,0,0,0,1,0,1;
    0,1,0,0,0,0,1,0;
    0,0,1,0,1,1,1,0;
    1,1,1,1,1,1,0,1;
    1,1,1,1,0,0,0,0;
    0,1,1,1,1,0,0,1;
    1,0,1,0,1,1,0,0;
    1,1,0,0,1,1,0,0];
    D2C=uint8(bit2int(mod(dualNumBits*d2cMap,2)',8,true)');


    alphaNumbers=0:255;
    alphaNumberBits=int2bit(alphaNumbers,8,true)';
    c2dMap=[1,0,0,0,1,1,0,1;
    1,1,1,0,1,1,1,1;
    1,1,1,0,1,1,0,0;
    1,0,0,0,0,1,1,0;
    1,1,1,1,1,0,1,0;
    1,0,0,1,1,0,0,1;
    1,0,1,0,1,1,1,1;
    0,1,1,1,1,0,1,1];
    C2D=uint8(bit2int(mod(alphaNumberBits*c2dMap,2)',8,true)');




    betaPow8=uint8(find(alphaNum==209)-1);


    function out=xorVec(vec)
        out=0;
        for kk=1:length(vec)
            out=bitxor(out,vec(kk));
        end
    end


    function product=multiply(a,b,logt,alogt)
        if(a==0)||(b==0)
            product=0;
        elseif(a==1)
            product=b;
        elseif(b==1)
            product=a;
        else
            loga=uint16(logt(a));
            logb=uint16(logt(b));
            tempSum=loga+logb;
            tempMod=mod(tempSum,255);
            if tempMod==0
                product=1;
            else
                product=alogt(tempMod);
            end
        end
    end


    function out=power(a,b,logt,alogt)
        if a==0
            out=0;
        elseif b==0
            out=1;
        else
            loga=uint16(logt(a));
            tempSum=loga*uint16(b);
            tempMod=mod(tempSum,255);
            if tempMod==0
                out=1;
            else
                out=alogt(tempMod);
            end
        end
    end

end