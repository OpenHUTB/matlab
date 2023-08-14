function[pass,requirements,badIndices,plotCommands]=sampleCustomGrader(block)






    userSignal=SignalMATLABCheck.getUserSignal(block);

    requirements={'x < 2 & x >= 0','Datatype: single','51 time steps'};

    pass=all(userSignal.Data>=0&userSignal.Data<2);
    pass(2)=isa(userSignal.Data,'single');
    pass(3)=numel(userSignal.Data)==51;



    badIndices=userSignal.Data<0|userSignal.Data>2;




    plotCommands(1).Time=[0,10];
    plotCommands(1).Signal=[0,0];
    plotCommands(1).Type='range';
    plotCommands(2).Time=[0,10];
    plotCommands(2).Signal=[2,2];
    plotCommands(2).Type='range';

end