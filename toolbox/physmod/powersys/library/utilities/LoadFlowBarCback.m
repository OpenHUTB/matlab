function[LFB]=LoadFlowBarCback(block,Phases,Connectors)





    LFB.phase1='x';
    LFB.phase2='x';
    LFB.phase3='x';
    LFB.N=3;

    MV=get_param(block,'MaskVisibilities');
    MV{2}='on';
    MV{8}='on';
    MV{9}='on';
    MV{11}='on';
    MV{12}='on';

    switch Phases
    case 'single'
        LFB.phase1='3';
        Drawconnectors(block,'on one side',1)
        LFB.N=1;
        MV{2}='off';
        MV{8}='off';
        MV{9}='off';
        MV{11}='off';
        MV{12}='off';
    case 'ABC'
        LFB.phase1='A';
        LFB.phase2='B';
        LFB.phase3='C';
        Drawconnectors(block,Connectors,3)
    case 'AB'
        LFB.phase1='A';
        LFB.phase2='B';
        Drawconnectors(block,Connectors,2)
        LFB.N=2;
    case 'AC'
        LFB.phase1='A';
        LFB.phase2='C';
        Drawconnectors(block,Connectors,2)
        LFB.N=2;
    case 'BC'
        LFB.phase1='B';
        LFB.phase2='C';
        Drawconnectors(block,Connectors,2)
        LFB.N=2;
    case 'A'
        LFB.phase1='A';
        Drawconnectors(block,Connectors,1)
        LFB.N=1;
    case 'B'
        LFB.phase1='B';
        Drawconnectors(block,Connectors,1)
        LFB.N=1;
    case 'C'
        LFB.phase1='C';
        Drawconnectors(block,Connectors,1)
        LFB.N=1;
    end

    MaskObj=Simulink.Mask.get(block);
    LF1=MaskObj.getDialogControl('LF1');
    LF2=MaskObj.getDialogControl('LF2');
    LF3=MaskObj.getDialogControl('LF3');
    LFU1=MaskObj.getDialogControl('LFU1');
    LFU2=MaskObj.getDialogControl('LFU2');
    LFU3=MaskObj.getDialogControl('LFU3');

    switch Phases
    case 'single'
        LFU1.Visible='off';
        LFU2.Visible='off';
        LFU3.Visible='off';
        LF1.Visible='on';
        LF2.Visible='on';
        LF3.Visible='on';
    otherwise
        LFU1.Visible='on';
        LFU2.Visible='on';
        LFU3.Visible='on';
        LF1.Visible='off';
        LF2.Visible='off';
        LF3.Visible='off';
    end

    set_param(block,'MaskVisibilities',MV);

    function Drawconnectors(block,Connectors,P)

        switch Connectors
        case 'on one side'
            switch P
            case 1
                set_param(block,'Lconntags',{'a'});
            case 2
                set_param(block,'Lconntags',{'a','b'});
            case 3
                set_param(block,'Lconntags',{'a','b','c'});
            end
            set_param(block,'Rconntags',{});
        case 'on both sides'
            switch P
            case 1
                set_param(block,'Lconntags',{'a'},'Rconntags',{'a'})
            case 2
                set_param(block,'Lconntags',{'a','b'},'Rconntags',{'a','b'})
            case 3
                set_param(block,'Lconntags',{'a','b','c'},'Rconntags',{'a','b','c'});
            end
        end