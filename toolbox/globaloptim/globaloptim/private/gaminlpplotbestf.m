function[state,options,optchanged]=gaminlpplotbestf(options,state,flag)











    optchanged=false;


    state=gaplotbestf(options,state,flag);


    switch flag
    case 'init'


        ylabel('Penalty value','Interpreter','none');

    case 'iter'



    case 'interrupt'



    case 'done'


        LegnD=legend('Best penalty value','Mean penalty value');
        set(LegnD,'FontSize',8);

    end