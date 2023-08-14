function[state,options,optchanged]=gaminlpplotscores(options,state,flag)











    optchanged=false;


    state=gaplotscores(options,state,flag);


    switch flag
    case 'init'


        title('Penalty Value of Each Individual','Interpreter','none');

    case 'iter'



    case 'interrupt'



    case 'done'


    end