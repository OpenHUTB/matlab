function utilImplementBackwardEulerNonLinearEquationSystem(hIn1,hIn2State,hIn3Sel,hOut1,system,systemParameters)






    set_param(hIn1,'Position',[795,33,825,47]);
    set_param(hIn2State,'Position',[795,133,825,147]);
    set_param(hIn3Sel,'Position',[795,253,825,267]);
    set_param(hOut1,'Position',[1185,63,1215,77]);






    numNewtonIterations=4;
    hnewtwonIterationSystem=cell(1,numNewtonIterations);
    hnewtonInterationSystemIn1x_n=cell(1,numNewtonIterations);
    hnewtonInterationSystemIn2x_guess=cell(1,numNewtonIterations);
    hnewtonInterationSystemIn3Input=cell(1,numNewtonIterations);
    hnewtonInterationSystemOut1x_guess_next=cell(1,numNewtonIterations);
    for i=1:numNewtonIterations

        hnewtwonIterationSystem{i}=utilAddSubsystem(system,['Newton Iteration ',num2str(i)],[1810,1370,1870,1430],'white');
        newtwonIterationSystem=getfullname(hnewtwonIterationSystem{i});

        hnewtonInterationSystemIn1x_n{i}=add_block('hdlsllib/Sources/In1',strcat(newtwonIterationSystem,'/x_n'),...
        'MakeNameUnique','on');
        hnewtonInterationSystemIn2x_guess{i}=add_block('hdlsllib/Sources/In1',strcat(newtwonIterationSystem,'/x_guess'),...
        'MakeNameUnique','on');
        hnewtonInterationSystemIn3Input{i}=add_block('hdlsllib/Sources/In1',strcat(newtwonIterationSystem,'/x_input'),...
        'MakeNameUnique','on');

        hnewtonInterationSystemOut1x_guess_next{i}=add_block('hdlsllib/Sinks/Out1',strcat(newtwonIterationSystem,'/x_guess_next'),...
        'MakeNameUnique','on');


        utilNewtonsIterationSystem(hnewtonInterationSystemIn1x_n{i},hnewtonInterationSystemIn2x_guess{i},hnewtonInterationSystemIn3Input{i},...
        hIn3Sel,hnewtonInterationSystemOut1x_guess_next{i},newtwonIterationSystem,systemParameters)






        if i==1
            add_line(system,strcat(get_param(hIn2State,'Name'),'/1'),strcat(get_param(hnewtwonIterationSystem{i},'Name'),'/2'),...
            'autorouting','on');
        else
            add_line(system,strcat(get_param(hnewtwonIterationSystem{i-1},'Name'),'/1'),strcat(get_param(hnewtwonIterationSystem{i},'Name'),'/2'),...
            'autorouting','on');
        end


        add_line(system,strcat(get_param(hIn2State,'Name'),'/1'),strcat(get_param(hnewtwonIterationSystem{i},'Name'),'/1'),...
        'autorouting','on');
        add_line(system,strcat(get_param(hIn1,'Name'),'/1'),strcat(get_param(hnewtwonIterationSystem{i},'Name'),'/3'),...
        'autorouting','on');

    end
    add_line(system,strcat(get_param(hnewtwonIterationSystem{i},'Name'),'/1'),strcat(get_param(hOut1,'Name'),'/1'),...
    'autorouting','on');

