function[state,options,optchanged]=gaminlpplotbestfun(options,state,flag)











    optchanged=false;


    state=gaplotbestfun(options,state,flag);


    switch flag
    case 'init'


        ylabel('Penalty value','Interpreter','none');

    case 'iter'



    case 'interrupt'



    case 'done'


    end