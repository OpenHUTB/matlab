function startDatatypes()

    if~isempty(which('dataset'))
        [~]=dataset();
    end


    if~isempty(which('patients.dat'))
        [~]=readtable('patients.dat','Format','auto');
    end


    [~]=struct('name','John Doe','billing',127.00,...
    'test',[79,75,73;180,178,177.5;220,210,205]);


    [~]=@plot;


    [~]=containers.Map();


    [~]=categorical({'r','b','g';'g','r','b';'b','r','g'});


    x=[-0.2,-0.3,13;-0.1,-0.4,15;NaN,2.8,17;0.5,0.3,NaN;-0.3,-0.1,15];
    [~]=timeseries(x(:,1:2),1:5,'name','Position');


    [~]=rand(1000);


    [~]={1,2,'3','4',5};


    [~]=sparse(100,100,pi);


    x=1;
    save([tempdir,'workspaceWarmup.mat']);
    clear;
    [~]=load([tempdir,'workspaceWarmup.mat']);
    delete([tempdir,'workspaceWarmup.mat']);
end
