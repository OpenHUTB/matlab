function[xData,yData]=simrfV2iconplotlc(SLblock)

    capx=[0.2,0.46,0.46,0.46,NaN,0.55,0.55,0.55,0.8];
    capy=[0.5,0.5,0.6,0.4,NaN,0.4,0.6,0.5,0.5];
    indx=[0.2,0.292,0.292787,0.29513,0.298976,0.304224,0.310746,0.318381...
    ,0.326944,0.336224,0.34599,0.356,0.36601,0.375776,0.385056,0.393619...
    ,0.401254,0.407776,0.413024,0.41687,0.419213,0.42,0.419213,0.41687...
    ,0.413024,0.407776,0.404,0.404,0.400224,0.394976,0.39113,0.388787...
    ,0.388,0.388787,0.39113,0.394976,0.400224,0.406746,0.414381,0.422944...
    ,0.432224,0.44199,0.452,0.46201,0.471776,0.481056,0.489619,0.497254...
    ,0.503776,0.509024,0.51287,0.515213,0.516,0.515213,0.51287,0.509024...
    ,0.503776,0.5,0.496224,0.490976,0.48713,0.484787,0.484,0.484787...
    ,0.48713,0.490976,0.496224,0.502746,0.510381,0.518944,0.528224...
    ,0.53799,0.548,0.55801,0.567776,0.577056,0.585619,0.593254,0.599776...
    ,0.605024,0.60887,0.611213,0.612,0.611213,0.60887,0.605024,0.599776...
    ,0.596,0.592224,0.586976,0.58313,0.580787,0.58,0.580787,0.58313...
    ,0.586976,0.592224,0.598746,0.606381,0.614944,0.624224,0.63399,0.644...
    ,0.65401,0.663776,0.673056,0.681619,0.689254,0.695776,0.701024...
    ,0.70487,0.707213,0.708,0.8];
    indy=[0.5,0.5,0.51564,0.5309,0.5454,0.55878,0.57071,0.5809,0.5891...
    ,0.59511,0.59877,0.6,0.59877,0.59511,0.5891,0.5809,0.57071,0.55878...
    ,0.5454,0.5309,0.51564,0.5,0.47635,0.453274,0.431347,0.411114,0.4...
    ,0.4,0.411114,0.431347,0.453274,0.47635,0.5,0.51564,0.5309,0.5454...
    ,0.55878,0.57071,0.5809,0.5891,0.59511,0.59877,0.6,0.59877,0.59511...
    ,0.5891,0.5809,0.57071,0.55878,0.5454,0.5309,0.51564,0.5,0.47635...
    ,0.453274,0.431347,0.411114,0.4,0.411114,0.431347,0.453274,0.47635...
    ,0.5,0.51564,0.5309,0.5454,0.55878,0.57071,0.5809,0.5891,0.59511...
    ,0.59877,0.6,0.59877,0.59511,0.5891,0.5809,0.57071,0.55878,0.5454...
    ,0.5309,0.51564,0.5,0.47635,0.453274,0.431347,0.411114,0.4,0.411114...
    ,0.431347,0.453274,0.47635,0.5,0.51564,0.5309,0.5454,0.55878,0.57071...
    ,0.5809,0.5891,0.59511,0.59877,0.6,0.59877,0.59511,0.5891,0.5809...
    ,0.57071,0.55878,0.5454,0.5309,0.51564,0.5,0.5];

    switch get_param(SLblock,'LadderType')
    case 'LC Lowpass Tee'
        xstem1=[0.8,0.9,NaN];
        ystem1=[0.8,0.8,NaN];
        xstem2=[NaN,0.9,1];
        ystem2=[NaN,0.8,0.8];
        srcx=[indx,xstem1,capy+0.4,xstem2,indx+1]*0.5;
        srcy=[indy+0.3,ystem1,capx,ystem2,indy+0.3];
        gndx=[NaN,srcx];
        gndy=[NaN,0.2*ones(1,243)];

        xData=[srcx,gndx];
        yData=[srcy,gndy]*0.9;
    case 'LC Lowpass Pi'
        xstem1=[0.5,0.6,NaN];
        ystem1=[1.1,1.1,NaN];
        xstem2=[1.2,1.3,NaN];
        ystem2=[1.1,1.1,NaN];
        compx=[capy,xstem1,indx+0.4,xstem2,capy+0.8]*0.9-0.3;
        compy=[capx+0.3,ystem1,indy+0.6,ystem2,capx+0.3]*0.7;
        gndx=[NaN,compx];
        gndy=[NaN,0.35*ones(1,138)];
        srcx=[0.05,0.15,NaN,0.875,0.975,NaN];
        srcy=[0.77,0.77,NaN,0.77,0.77,NaN];

        xData=[srcx,compx,gndx]*0.9+0.05;
        yData=[srcy,compy,gndy]*1.2-0.2;
    case 'LC Highpass Tee'
        xstem1=[0.8,0.9,NaN];
        xstem2=[NaN,0.9,1];
        ystem1=[0.8,0.8,NaN];
        ystem2=[NaN,0.8,0.8];
        srcx=[capx,xstem1,indy+0.4,xstem2,capx+1]*0.5;
        srcy=[capy+0.3,ystem1,indx,ystem2,capy+0.3];
        gndx=[NaN,0.1:0.1:0.9];
        gndy=[NaN,0.2*ones(1,9)];

        xData=[srcx,gndx];
        yData=[srcy,gndy]*0.9;
    case 'LC Highpass Pi'
        xstem1=[0.5,0.6,NaN];
        ystem1=[1.1,1.1,NaN];
        xstem2=[1.2,1.3,NaN];
        ystem2=[1.1,1.1,NaN];
        compx=[indy,xstem1,capx+0.4,xstem2,indy+0.8]*0.55;
        compy=[indx+0.3,ystem1,capy+0.6,ystem2,indx+0.3]*0.7;
        gndx=[NaN,0.1:0.1:0.9];
        gndy=[NaN,0.35*ones(1,9)];
        srcx=[0.1,0.3,NaN,0.7,0.9,NaN];
        srcy=[0.77,0.77,NaN,0.77,0.77,NaN];

        xData=[srcx,compx,gndx];
        yData=[srcy,compy,gndy]*1.3-0.275;
    case 'LC Bandpass Tee'
        lstemx=[0.0,0.2];
        lstemy=[0.5,0.5];
        rstemx=[0.8,1.0];
        rstemy=[0.5,0.5];

        comp1x=indx;
        comp1y=indy;
        comp2x=capx;
        comp2y=capy;
        compx1=[lstemx,NaN,comp1x,NaN,comp2x+0.6,NaN,rstemx+0.6,NaN]/1.6;
        compy1=[lstemy,NaN,comp1y,NaN,comp2y,NaN,rstemy,NaN]-0.2;
        compxval1=0.5*compx1;
        compyval1=1.2*(compy1+0.3);

        l2stemx=[0.0,0.1,0.1,0.1,0.1];
        l2stemy=[0.5,0.5,0.3,0.7,0.5];
        r2stemx=[0.6,0.6,0.6,0.6,0.7];
        r2stemy=[0.5,0.7,0.3,0.5,0.5];

        comp1x=capx(2:end-1);
        comp1x=[0.3,comp1x,0.7]-0.1;
        comp1y=capy;
        comp2x=indx(1:43);
        comp2x=[comp2x,indx(104:end)];
        comp2x(44:end)=comp2x(44:end)-0.2;
        comp2y=indy(1:43);
        comp2y=[comp2y,indy(104:end)];
        compx2=[NaN,comp1x,NaN,comp2x,NaN];
        compy2=[NaN,comp1y+0.2,NaN,comp2y-0.2,NaN];
        compxval2=0.5*([l2stemy,compy2,r2stemy]+0.5);
        compyval2=1.2*([l2stemx,compx2-0.1,r2stemx-0.1]);

        comp1x=indx;comp1y=indy;
        comp2x=capx;comp2y=capy;
        compx3=[lstemx,NaN,comp1x,NaN,comp2x+0.6,NaN,rstemx+0.6]/1.6;
        compy3=[lstemy,NaN,comp1y,NaN,comp2y,NaN,rstemy]-0.2;
        compxval3=0.5*(compx3+1);
        compyval3=1.2*(compy3+0.3);

        gndx=[NaN,0:0.1:1];
        gndy=[NaN,zeros(1,11)];

        xData=[compxval1,compxval2,compxval3,gndx]*0.8+0.1;
        yData=[compyval1,compyval2,compyval3,gndy]*0.85+0.15;
    case 'LC Bandpass Pi'
        l2stemx=[0.0,0.1,0.1,0.1,0.1];
        l2stemy=[0.5,0.5,0.3,0.7,0.5];
        r2stemx=[0.6,0.6,0.6,0.6,0.7];
        r2stemy=[0.5,0.7,0.3,0.5,0.5];

        comp1x=capx(2:end-1);
        comp1x=[0.3,comp1x,0.7]-0.1;
        comp1y=capy;
        comp2x=indx(1:43);
        comp2x=[comp2x,indx(104:end)];
        comp2x(44:end)=comp2x(44:end)-0.2;
        comp2y=indy(1:43);
        comp2y=[comp2y,indy(104:end)];
        compx1=[NaN,comp1x,NaN,comp2x,NaN];
        compy1=[NaN,comp1y+0.2,NaN,comp2y-0.2,NaN];
        compxval1=0.5*[l2stemy,compy1,r2stemy];
        compyval1=1.2*[l2stemx,compx1-0.1,r2stemx-0.1];

        lstemx=[0.0,0.2];
        lstemy=[0.5,0.5];
        rstemx=[0.8,1.0];
        rstemy=[0.5,0.5];
        comp1x=indx;comp1y=indy;
        comp2x=capx;comp2y=capy;
        compx2=[lstemx,NaN,comp1x,NaN,comp2x+0.6,NaN,rstemx+0.6,NaN]/1.6;
        compy2=[lstemy,NaN,comp1y,NaN,comp2y,NaN,rstemy,NaN]-0.2;
        compxval2=0.5*(compx2+0.5);
        compyval2=1.2*(compy2+0.3);

        l2stemx=[0.0,0.1,0.1,0.1,0.1];
        l2stemy=[0.5,0.5,0.3,0.7,0.5];
        r2stemx=[0.6,0.6,0.6,0.6,0.7];
        r2stemy=[0.5,0.7,0.3,0.5,0.5];

        comp1x=capx(2:end-1);
        comp1x=[0.3,comp1x,0.7]-0.1;
        comp1y=capy;
        comp2x=indx(1:43);
        comp2x=[comp2x,indx(104:end)];
        comp2x(44:end)=comp2x(44:end)-0.2;
        comp2y=indy(1:43);
        comp2y=[comp2y,indy(104:end)];
        compx3=[NaN,comp1x,NaN,comp2x,NaN];
        compy3=[NaN,comp1y+0.2,NaN,comp2y-0.2,NaN];
        compxval3=0.5*([l2stemy,compy3,r2stemy]+1);
        compyval3=1.2*[l2stemx,compx3-0.1,r2stemx-0.1];

        gndx=[NaN,0.1:0.1:0.9];
        gndy=[NaN,zeros(1,9)];
        srcx=[0.1,0.3,NaN,0.7,0.9,NaN];
        srcy=[0.72,0.72,NaN,0.72,0.72,NaN];

        xData=[srcx,compxval1,compxval2,compxval3,gndx];
        yData=[srcy,compyval1,compyval2,compyval3,gndy]*0.9+0.15;
    case 'LC Bandstop Tee'
        l2stemx=[0.0,0.1,0.1,0.1,0.1];
        l2stemy=[0.5,0.5,0.4,0.6,0.5]-0.1;
        r2stemx=[0.5,0.5,0.5,0.5,0.6];
        r2stemy=[0.5,0.6,0.4,0.5,0.5]-0.1;

        comp1x=indx(1:43);
        comp1x=[comp1x,indx(104:end)]-0.1;
        comp1x(44:end)=comp1x(44:end)-0.2;
        comp1y=indy(1:43);
        comp1y=[comp1y,indy(104:end)]-0.2;
        comp2x=capx(2:end-1);
        comp2x=[0.2,comp2x-0.1,0.6]-0.1;
        comp2y=capy;
        compx1=[NaN,comp1x,NaN,comp2x,NaN];
        compy1=[NaN,comp1y+0.2,NaN,comp2y-0.2,NaN];
        compxval1=[l2stemx,compx1,r2stemx]/1.25;
        compyval1=[l2stemy,compy1,r2stemy]+0.35;

        comp1x=capx;
        comp1y=capy;
        comp2x=indx(1:43);
        comp2x=[comp2x,indx(104:end)];
        comp2x(44:end)=comp2x(44:end)-0.2;
        comp2y=indy(1:43);
        comp2y=[comp2y,indy(104:end)];
        compx2=[NaN,comp1x,NaN,comp2x+0.6,NaN]/1.6;
        compy2=[NaN,comp1y,NaN,comp2y,NaN];
        stemx1=[0.5,0.5];
        stemy1=[0.85,0.75];
        compx2=[compx2,stemy1];
        compy2=[compy2,stemx1];
        compxval2=(compy2+0.1)/1.25;
        compyval2=compx2-0.1;

        comp1x=indx(1:43);
        comp1x=[comp1x,indx(104:end)]-0.1;
        comp1x(44:end)=comp1x(44:end)-0.2;
        comp1y=indy(1:43);
        comp1y=[comp1y,indy(104:end)]-0.2;
        comp2x=capx(2:end-1);
        comp2x=[0.2,comp2x-0.1,0.6]-0.1;
        comp2y=capy;
        compx3=[NaN,comp1x,NaN,comp2x,NaN];
        compy3=[NaN,comp1y+0.2,NaN,comp2y-0.2,NaN];
        compxval3=([l2stemx,compx3,r2stemx]+0.6)/1.25;
        compyval3=[l2stemy,compy3,r2stemy]+0.35;

        gndx=[NaN,0:0.01:0.96];
        gndy=[NaN,0.025*ones(1,97)];
        xData=[compxval1,compxval2,compxval3,gndx]*0.9+0.05;
        yData=[compyval1,compyval2,compyval3,gndy]*0.85+0.1;
    case 'LC Bandstop Pi'
        comp1x=capx;
        comp1y=capy;
        comp2x=indx(1:43);
        comp2x=[comp2x,indx(104:end)];
        comp2x(44:end)=comp2x(44:end)-0.2;
        comp2y=indy(1:43);
        comp2y=[comp2y,indy(104:end)];
        compx2=[NaN,comp1x,NaN,comp2x+0.6,NaN]/1.6-0.2;
        compy2=[NaN,comp1y,NaN,comp2y,NaN];
        compxval1=(compy2-0.2)/1.25;
        compyval1=compx2+0.2;

        l2stemx=[0.0,0.2,0.2,0.2,0.2];
        l2stemy=[0.5,0.5,0.4,0.6,0.5]-0.1;
        r2stemx=[0.6,0.6,0.6,0.6,0.8];
        r2stemy=[0.5,0.6,0.4,0.5,0.5]-0.1;

        comp1x=indx(1:43);
        comp1x=[comp1x,indx(104:end)]-0.1;
        comp1x(44:end)=comp1x(44:end)-0.2;
        comp1y=indy(1:43);
        comp1y=[comp1y,indy(104:end)]-0.2;
        comp2x=capx(2:end-1);
        comp2x=[0.2,comp2x-0.1,0.6]-0.1;
        comp2y=capy;
        compx2=[NaN,comp1x,NaN,comp2x,NaN]+0.1;
        compy2=[NaN,comp1y+0.2,NaN,comp2y-0.2,NaN];
        compxval2=([l2stemx,compx2,r2stemx]+0.3)/1.25;
        compyval2=[l2stemy,compy2,r2stemy]+0.35;

        comp1x=capx;
        comp1y=capy;
        comp2x=indx(1:43);
        comp2x=[comp2x,indx(104:end)];
        comp2x(44:end)=comp2x(44:end)-0.2;
        comp2y=indy(1:43);
        comp2y=[comp2y,indy(104:end)];
        compx3=[NaN,comp1x,NaN,comp2x+0.6,NaN]/1.6;
        compy3=[NaN,comp1y,NaN,comp2y,NaN];
        compxval3=(compy3+0.6)/1.25;
        compyval3=compx3;

        gndx=[NaN,0.14:0.01:0.98];
        gndy=[NaN,0.125*ones(1,85)];
        srcx=[NaN,0.14:0.01:0.24,NaN,0.88:0.01:0.99,NaN];
        srcy=[NaN,0.75*ones(1,11),NaN,0.75*ones(1,12),NaN];

        xData=[srcx,compxval1,compxval2,compxval3,gndx]-0.05;
        yData=[srcy,compyval1,compyval2,compyval3,gndy];
    otherwise
        error('LCladder mask, invalid value for Parameter LadderType');
    end

end