function[z,p]=augmentZPK(Ts,Type,IFormula,DFormula)




























    p=zeros(0,1);
    z=zeros(0,1);
    if Ts==0
        if any(Type=='i')

            p=0;
        end
    else
        switch Type
        case 'i'

            p=1;
            switch IFormula
            case 'B'

                z=0;
            case 'T'

                z=-1;
            end
        case 'pi'

            p=1;
        case 'pd'
            switch DFormula
            case 'B'

                p=0;
            case 'T'

                p=-1;
            end
        case 'pdf'
        case 'pid'
            switch DFormula
            case 'F'

                p=1;
            case 'B'

                p=[1;0];
            case 'T'

                p=[1;-1];
            end
        case 'pidf'

            p=1;
        end
    end
