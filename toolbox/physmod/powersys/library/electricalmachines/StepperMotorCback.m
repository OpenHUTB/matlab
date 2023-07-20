function StepperMotorCback(block,option)





    if~exist('option','var')
        option=0;
    end






    MaskVisibilities=get_param(block,'MaskVisibilities');

    MotorType=get_param(block,'MotorType');

    switch MotorType

    case 'Permanent-magnet / Hybrid'

        MaskVisibilities{2}='on';
        MaskVisibilities{3}='off';
        MaskVisibilities{4}='on';
        MaskVisibilities{5}='off';
        MaskVisibilities{6}='on';
        MaskVisibilities{7}='off';
        MaskVisibilities{8}='off';
        MaskVisibilities{11}='on';
        MaskVisibilities{12}='on';

    case 'Variable reluctance'

        MaskVisibilities{2}='off';
        MaskVisibilities{3}='on';
        MaskVisibilities{4}='off';
        MaskVisibilities{5}='on';
        MaskVisibilities{6}='off';
        MaskVisibilities{7}='on';
        MaskVisibilities{8}='on';
        MaskVisibilities{11}='off';
        MaskVisibilities{12}='off';

    end


    MaskVisibilities{4}='off';
    MaskVisibilities{5}='off';

    set_param(block,'MaskVisibilities',MaskVisibilities);

    if option==0
        return
    end


    switch MotorType

    case 'Permanent-magnet / Hybrid'

        switch get_param(block,'NumberOfPhases_1')
        case '2'
            NumberOfPhases=2;
            WantTwoHybPhases=1;
            WantFourHybPhases=0;
        case '4'
            NumberOfPhases=4;
            WantFourHybPhases=1;
            WantTwoHybPhases=0;
        end

        WantThreeVarPhases=0;
        WantFourVarPhases=0;
        WantFiveVarPhases=0;

    case 'Variable reluctance'




        switch get_param(block,'NumberOfPhases_2')
        case '3'
            NumberOfPhases=3;
            WantThreeVarPhases=1;
            WantFourVarPhases=0;
            WantFiveVarPhases=0;
        case '4'
            NumberOfPhases=4;
            WantThreeVarPhases=0;
            WantFourVarPhases=1;
            WantFiveVarPhases=0;
        case '5'
            NumberOfPhases=5;
            WantThreeVarPhases=0;
            WantFourVarPhases=0;
            WantFiveVarPhases=1;
        end

        WantTwoHybPhases=0;
        WantFourHybPhases=0;

    end



    StepperPorts=get_param(block,'ports');
    LConnTags=get_param([block,'/StepperMotor'],'LConnTags');

    HaveTwoHybPhases=StepperPorts(6)==4;
    HaveFourHybPhases=isequal('CA',LConnTags{2})&&StepperPorts(6)==6;
    HaveThreeVarPhases=isequal('A-',LConnTags{2})&&StepperPorts(6)==6;
    HaveFourVarPhases=StepperPorts(6)==8;
    HaveFiveVarPhases=StepperPorts(6)==10;




    switch MotorType

    case 'Permanent-magnet / Hybrid'

        if NumberOfPhases==2

            PortLabels={'A+','A-','B+','B-'};

        else

            PortLabels={'A+','CA','A-','B+','CB','B-'};

        end

    case 'Variable reluctance'

        if NumberOfPhases==3

            PortLabels={'A+','A-','B+','B-','C+','C-'};

        elseif NumberOfPhases==4

            PortLabels={'A+','A-','B+','B-','C+','C-','D+','D-'};

        else

            PortLabels={'A+','A-','B+','B-','C+','C-','D+','D-','E+','E-'};

        end

    end



    switch MotorType

    case 'Permanent-magnet / Hybrid'


        if WantFourHybPhases

            if HaveThreeVarPhases

                RemoveTerminals(block,PortLabels,{'C+','C-'},{5,6});
            elseif HaveFourVarPhases

                RemoveTerminals(block,PortLabels,{'C+','C-','D+','D-'},{5,6,7,8});
            elseif HaveFiveVarPhases

                RemoveTerminals(block,PortLabels,{'C+','C-','D+','D-','E+','E-'},{5,6,7,8,9,10});
            end

            if HaveTwoHybPhases||HaveThreeVarPhases||HaveFourVarPhases||HaveFiveVarPhases

                AddTerminals(block,PortLabels,{'CA','CB'},{2,5});
            end

        elseif WantTwoHybPhases

            if HaveFourHybPhases
                RemoveTerminals(block,PortLabels,{'CA','CB'},{2,5});
            elseif HaveThreeVarPhases
                RemoveTerminals(block,PortLabels,{'C+','C-'},{5,6});
            elseif HaveFourVarPhases
                RemoveTerminals(block,PortLabels,{'C+','C-','D+','D-'},{5,6,7,8});
            elseif HaveFiveVarPhases
                RemoveTerminals(block,PortLabels,{'C+','C-','D+','D-','E+','E-'},{5,6,7,8,9,10});
            end

        end


    case 'Variable reluctance'



        if WantThreeVarPhases

            if HaveFourVarPhases
                RemoveTerminals(block,PortLabels,{'D+','D-'},{7,8});
            elseif HaveFiveVarPhases
                RemoveTerminals(block,PortLabels,{'D+','D-','E+','E-'},{7,8,9,10});
            elseif HaveFourHybPhases

                RemoveTerminals(block,PortLabels,{'CA','CB'},{2,5});
            end

            if HaveTwoHybPhases||HaveFourHybPhases

                AddTerminals(block,PortLabels,{'C+','C-'},{5,6});
            end

        elseif WantFourVarPhases

            if HaveThreeVarPhases
                AddTerminals(block,PortLabels,{'D+','D-'},{7,8});
            elseif HaveFiveVarPhases
                RemoveTerminals(block,PortLabels,{'E+','E-'},{9,10});
            elseif HaveFourHybPhases

                RemoveTerminals(block,PortLabels,{'CA','CB'},{2,5});
            end

            if HaveTwoHybPhases||HaveFourHybPhases

                AddTerminals(block,PortLabels,{'C+','C-','D+','D-'},{5,6,7,8});
            end

        elseif WantFiveVarPhases

            if HaveFourHybPhases

                RemoveTerminals(block,PortLabels,{'CA','CB'},{2,5});
            elseif HaveThreeVarPhases
                AddTerminals(block,PortLabels,{'D+','D-','E+','E-'},{7,8,9,10});
            elseif HaveFourVarPhases
                AddTerminals(block,PortLabels,{'E+','E-'},{9,10});
            end

            if HaveTwoHybPhases||HaveFourHybPhases

                AddTerminals(block,PortLabels,{'C+','C-','D+','D-','E+','E-'},{5,6,7,8,9,10});
            end

        end

    end



    function AddTerminals(block,PortLabels,TermNames,PortP)







        try

            set_param([block,'/StepperMotor'],'LConnTags',PortLabels);

            for i=1:length(TermNames)

                add_block('built-in/PMIOPort',[block,'/',TermNames{i}]);
                set_param([block,'/',TermNames{i}],'port',mat2str(PortP{i}));
                set_param([block,'/',TermNames{i}],'Position',[40,PortP{i}*10+150,70,PortP{i}*10+180],'side','Left','orientation','Right');
                PMPortHandles=get_param([block,'/StepperMotor'],'PortHandles');
                PPortHandle=get_param([block,'/',TermNames{i}],'PortHandles');
                add_line(block,PMPortHandles.LConn(PortP{i}),PPortHandle.RConn)
            end
        catch ME %#ok
        end


        function RemoveTerminals(block,PortLabels,TermNames,PortP)

            PortHandles=get_param([block,'/StepperMotor'],'PortHandles');

            for i=1:length(TermNames)
                ligneP=get_param(PortHandles.LConn(PortP{i}),'line');
                delete_line(ligneP);
                delete_block([block,'/',TermNames{i}]);
            end


            set_param([block,'/StepperMotor'],'LConnTags',PortLabels);