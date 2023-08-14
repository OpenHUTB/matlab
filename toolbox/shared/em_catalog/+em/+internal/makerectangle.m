function p=makerectangle(length,width)















    nameOfFunction='makerectangle';
    validateattributes(length,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Length',1);
    validateattributes(width,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Width',2);

    px=[-length/2,length/2,length/2,-length/2];
    py=[-width/2,-width/2,width/2,width/2];
    pz=[0,0,0,0];

    p=[px;py;pz];
