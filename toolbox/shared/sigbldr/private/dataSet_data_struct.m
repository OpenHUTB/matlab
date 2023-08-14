function dataSet=dataSet_data_struct(name,trange,activeDispIdx)





    if nargin<3
        activeDispIdx=[];
    end

    if nargin<2
        trange=[0,10];
    end

    if nargin<1
        name='Group 1';
    end

    dataSet=struct('activeDispIdx',activeDispIdx,...
    'timeRange',trange,...
    'name',name,...
    'displayRange',trange);