function h=RegionInfo(varargin)




    h=Simulink.RegionInfo;

    startIdx=0;
    numElements=0;

    if(nargin==1)
        inArray=varargin{1};
        startIdx=inArray(1);
        numElements=inArray(2);
    end


    set(h,'StartIndex',startIdx);
    set(h,'NumElements',numElements);

