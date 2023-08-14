function[obj1,obj2,cal,ind]=ephSelect(planet,de)


















    switch planet
    case 'mercury'
        ind=1;
        cal='Planet';
        obj1=matfile(['ephMercury',de,'.mat']);
        obj2=[];
    case 'venus'
        ind=2;
        cal='Planet';
        obj1=matfile(['ephVenus',de,'.mat']);
        obj2=[];
    case 'earth'
        ind=3;
        cal='Earth';
        obj1=matfile(['ephEarthMoonBarycenter',de,'.mat']);
        obj2=matfile(['ephMoon',de,'.mat']);
    case 'mars'
        ind=4;
        cal='Planet';
        obj1=matfile(['ephMars',de,'.mat']);
        obj2=[];
    case 'jupiter'
        ind=5;
        cal='Planet';
        obj1=matfile(['ephJupiter',de,'.mat']);
        obj2=[];
    case 'saturn'
        ind=6;
        cal='Planet';
        obj1=matfile(['ephSaturn',de,'.mat']);
        obj2=[];
    case 'uranus'
        ind=7;
        cal='Planet';
        obj1=matfile(['ephUranus',de,'.mat']);
        obj2=[];
    case 'neptune'
        ind=8;
        cal='Planet';
        obj1=matfile(['ephNeptune',de,'.mat']);
        obj2=[];
    case 'pluto'
        ind=9;
        cal='Planet';
        obj1=matfile(['ephPluto',de,'.mat']);
        obj2=[];
    case 'moon'
        ind=10;
        cal='Moon';
        obj1=matfile(['ephMoon',de,'.mat']);
        obj2=matfile(['ephEarthMoonBarycenter',de,'.mat']);
    case 'sun'
        ind=11;
        cal='Planet';
        obj1=matfile(['ephSun',de,'.mat']);
        obj2=[];
    case 'earthmoon'
        ind=3;
        cal='Planet';
        obj1=matfile(['ephEarthMoonBarycenter',de,'.mat']);
        obj2=[];
    case 'solarsystem'
        ind=0;
        cal='Solar';
        obj1=[];
        obj2=[];
    end

