function varargout=blocicon(parametres)





    varargout={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    block=parametres{1};
    values={parametres{2:end}};

    switch block

    case{'Series RLC Branch'}

        BranchType=values{4};

        if~strcmp(BranchType,'Open circuit');

            switch BranchType
            case 'RLC'
                r=1;l=1;c=1;
            case 'R'
                r=1;l=0;c=0;
            case 'L'
                r=0;l=1;c=0;
            case 'C'
                r=0;l=0;c=1;
            case 'RL'
                r=1;l=1;c=0;
            case 'RC'
                r=1;l=0;c=1;
            case 'LC'
                r=0;l=1;c=1;
            end

            rx=[0,30,30,38,53,68,83,98,113,120,120,150];
            ry=[0,0,0,25,-25,25,-25,25,-25,0,0,0]*0.5;

            lx=[0,23,23,24,28,34,40,47,52,55,56,54,51,51,47,46,48,51,57,64,70,75,79,79,77,74,74,70,69,71,75,80,87,93,99,102,103,101,97,97,94,93,94,98,104,110,117,122,125,126,126,150];
            ly=[0,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,0]*0.5;

            cx1=150-[0,60,60,57,55,57,60,60,57,55];
            cy1=[0,0,8,16,25,16,8,-8,-16,-25]*0.5;
            cx2=150-[90,90,90,150];
            cy2=[25,-25,0,0]*0.5;

            test=[r,l,c];

            if test==[1,0,0]%#ok
                varargout{1}=0;
                varargout{2}=-50;
                varargout{3}=150;
                varargout{4}=50;
                varargout{5}=rx;
                varargout{6}=ry;
            end
            if test==[0,1,0]%#ok
                varargout{1}=0;
                varargout{2}=-50;
                varargout{3}=150;
                varargout{4}=50;
                varargout{5}=lx;
                varargout{6}=ly;
            end
            if test==[0,0,1]%#ok
                varargout{1}=0;
                varargout{2}=-50;
                varargout{3}=150;
                varargout{4}=50;
                varargout{5}=cx1;
                varargout{6}=cy1;
                varargout{7}=cx2;
                varargout{8}=cy2;
            end
            if test==[1,0,1]%#ok
                varargout{1}=0;
                varargout{2}=-50;
                varargout{3}=300;
                varargout{4}=50;
                varargout{5}=rx;
                varargout{6}=ry;
                varargout{7}=cx1+150;
                varargout{8}=cy1;
                varargout{9}=cx2+150;
                varargout{10}=cy2;
            end
            if test==[1,1,0]%#ok
                varargout{1}=0;
                varargout{2}=-50;
                varargout{3}=300;
                varargout{4}=50;
                varargout{5}=rx;
                varargout{6}=ry;
                varargout{7}=lx+150;
                varargout{8}=ly;
            end
            if test==[0,1,1]%#ok
                varargout{1}=0;
                varargout{2}=-50;
                varargout{3}=300;
                varargout{4}=50;
                varargout{5}=lx;
                varargout{6}=ly;
                varargout{7}=cx1+150;
                varargout{8}=cy1;
                varargout{9}=cx2+150;
                varargout{10}=cy2;
            end
            if test==[1,1,1]%#ok
                varargout{1}=0;
                varargout{2}=-50;
                varargout{3}=450;
                varargout{4}=50;
                varargout{5}=rx;
                varargout{6}=ry;
                varargout{7}=lx+150;
                varargout{8}=ly;
                varargout{9}=cx1+300;
                varargout{10}=cy1;
                varargout{11}=cx2+300;
                varargout{12}=cy2;
            end
        else

            varargout{1}=0;
            varargout{2}=-50;
            varargout{3}=150;
            varargout{4}=50;
            varargout{5}=[0,20,20,30,30,20,20,0];
            varargout{6}=[0,0,10,10,-10,-10,0,0];
            varargout{7}=[150,130,130,120,120,130,130,150];
            varargout{8}=[0,0,10,10,-10,-10,0,0];
        end

    case{'Series RLC Load'}

        r=values{1};
        l=values{2};
        c=values{3};

        if length(values)>3
            UnbalancedPower=values{4};
            if UnbalancedPower
                switch values{11}
                case{1,2,3}
                    r=sum(values{5});
                    l=sum(values{6});
                    c=sum(values{7});
                otherwise
                    r=sum(values{8});
                    l=sum(values{9});
                    c=sum(values{10});
                end
            end
        end


        if isempty(r);r=1;end
        if isempty(l);l=1;end
        if isempty(c);c=1;end
        if c==inf;c=0;end
        t1=length(r)==1&r~=0;
        t2=length(l)==1&l~=0;
        t3=length(c)==1&c~=0;
        t1=t1(1);
        t2=t2(1);
        t3=t3(1);
        test=[t1,t2,t3]&[1,1,1];

        if test==[0,0,0]%#ok
            varargout{1}=0;
            varargout{2}=-50;
            varargout{3}=150;
            varargout{4}=50;
            varargout{5}=[0,20,20,30,30,20,20,0];
            varargout{6}=[0,0,10,10,-10,-10,0,0];
            varargout{7}=[150,130,130,120,120,130,130,150];
            varargout{8}=[0,0,10,10,-10,-10,0,0];
        end

        if test==[1,0,0]%#ok
            [varargout{1:12}]=blocicon({'Series RLC Branch',1,0,0,'R'});
        end

        if test==[0,1,0]%#ok
            [varargout{1:12}]=blocicon({'Series RLC Branch',0,1,0,'L'});
        end

        if test==[0,0,1]%#ok
            [varargout{1:12}]=blocicon({'Series RLC Branch',0,0,1,'C'});
        end

        if test==[1,0,1]%#ok
            [varargout{1:12}]=blocicon({'Series RLC Branch',1,0,1,'RC'});
        end

        if test==[1,1,0]%#ok
            [varargout{1:12}]=blocicon({'Series RLC Branch',1,1,0,'RL'});
        end

        if test==[0,1,1]%#ok
            [varargout{1:12}]=blocicon({'Series RLC Branch',0,1,1,'LC'});
        end

        if test==[1,1,1]%#ok
            [varargout{1:12}]=blocicon({'Series RLC Branch',1,1,1,'RLC'});
        end

    case 'Parallel RLC Branch'

        BranchType=values{4};

        if~strcmp(BranchType,'Open circuit');

            switch BranchType
            case 'RLC'
                r=1;l=1;c=1;
            case 'R'
                r=1;l=0;c=0;
            case 'L'
                r=0;l=1;c=0;
            case 'C'
                r=0;l=0;c=1;
            case 'RL'
                r=1;l=1;c=0;
            case 'RC'
                r=1;l=0;c=1;
            case 'LC'
                r=0;l=1;c=1;
            end

            test=[r,l,c];

            if test==[1,0,0]%#ok
                [varargout{1:12}]=blocicon({'Series RLC Branch',1,0,0,'R'});
                varargout{13}=0;
                varargout{14}=0;
                varargout{15}=0;
                varargout{16}=0;
            end
            if test==[0,1,0]%#ok
                [varargout{1:12}]=blocicon({'Series RLC Branch',0,1,0,'L'});
                varargout{13}=0;
                varargout{14}=0;
                varargout{15}=0;
                varargout{16}=0;
            end
            if test==[0,0,1]%#ok
                [varargout{1:12}]=blocicon({'Series RLC Branch',0,0,1,'C'});
                varargout{13}=0;
                varargout{14}=0;
                varargout{15}=0;
                varargout{16}=0;
            end

            rx=[0,30,30,38,53,68,83,98,113,120,120,150];
            ry=[0,0,0,25,-25,25,-25,25,-25,0,0,0];
            lx=[0,23,23,24,28,34,40,47,52,55,56,54,51,51,47,46,48,51,57,64,70,75,79,79,77,74,74,70,69,71,75,80,87,93,99,102,103,101,97,97,94,93,94,98,104,110,117,122,125,126,126,150];
            ly=[0,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,0];
            cx1=150-[0,60,60,57,55,57,60,60,57,55];
            cy1=[0,0,8,16,25,16,8,-8,-16,-25];
            cx2=150-[90,90,90,150];
            cy2=[25,-25,0,0];
            c2el1x=[0,25,25,25];
            c2el1y=[0,0,-50,50];
            c2el2x=[175,175,175,200];
            c2el2y=[-50,50,0,0];
            c3el1y=[0,0,-100,100];
            c3el2y=[-100,100,0,0];

            if test==[1,1,0]%#ok
                varargout{1}=0;
                varargout{2}=-100;
                varargout{3}=200;
                varargout{4}=100;
                varargout{5}=rx+25;
                varargout{6}=ry+50;
                varargout{7}=lx+25;
                varargout{8}=ly-50;
                varargout{13}=c2el1x;
                varargout{14}=c2el1y;
                varargout{15}=c2el2x;
                varargout{16}=c2el2y;
            end

            if test==[1,0,1]%#ok
                varargout{1}=0;
                varargout{2}=-100;
                varargout{3}=200;
                varargout{4}=100;
                varargout{5}=rx+25;
                varargout{6}=ry+50;
                varargout{9}=cx1+25;
                varargout{10}=cy1-50;
                varargout{11}=cx2+25;
                varargout{12}=cy2-50;
                varargout{13}=c2el1x;
                varargout{14}=c2el1y;
                varargout{15}=c2el2x;
                varargout{16}=c2el2y;
            end

            if test==[0,1,1]%#ok
                varargout{1}=0;
                varargout{2}=-100;
                varargout{3}=200;
                varargout{4}=100;
                varargout{7}=lx+25;
                varargout{8}=ly+50;
                varargout{9}=cx1+25;
                varargout{10}=cy1-50;
                varargout{11}=cx2+25;
                varargout{12}=cy2-50;
                varargout{13}=c2el1x;
                varargout{14}=c2el1y;
                varargout{15}=c2el2x;
                varargout{16}=c2el2y;
            end

            if test==[1,1,1]%#ok
                varargout{1}=0;
                varargout{2}=-175;
                varargout{3}=200;
                varargout{4}=175;
                varargout{5}=rx+25;
                varargout{6}=ry+100;
                varargout{7}=lx+25;
                varargout{8}=ly;
                varargout{9}=cx1+25;
                varargout{10}=cy1-100;
                varargout{11}=cx2+25;
                varargout{12}=cy2-100;
                varargout{13}=c2el1x;
                varargout{14}=c3el1y;
                varargout{15}=c2el2x;
                varargout{16}=c3el2y;
            end

        else
            [varargout{1:12}]=blocicon({'Series RLC Branch',0,0,0,'Open circuit'});
            varargout{13}=0;
            varargout{14}=0;
            varargout{15}=0;
            varargout{16}=0;
        end

    case 'Parallel RLC Load'

        r=values{1};
        l=values{2};
        c=values{3};

        if length(values)>3
            UnbalancedPower=values{4};
            if UnbalancedPower
                switch values{11}
                case{1,2,3}
                    r=sum(values{5});
                    l=sum(values{6});
                    c=sum(values{7});
                otherwise
                    r=sum(values{8});
                    l=sum(values{9});
                    c=sum(values{10});
                end
            end
        end

        if isempty(r);r=1;end
        if isempty(l);l=1;end
        if isempty(c);c=1;end
        if l==inf
            l=0;
        end
        if r==inf
            r=0;
        end
        test=[r,l,c]&[1,1,1];

        if test==[1,0,0]%#ok
            [varargout{1:16}]=blocicon({'Parallel RLC Branch',1,0,0,'R'});
        end

        if test==[0,1,0]%#ok
            [varargout{1:16}]=blocicon({'Parallel RLC Branch',0,1,0,'L'});
        end

        if test==[0,0,1]%#ok
            [varargout{1:16}]=blocicon({'Parallel RLC Branch',0,0,1,'C'});
        end

        if test==[1,0,1]%#ok
            [varargout{1:16}]=blocicon({'Parallel RLC Branch',1,0,1,'RC'});
        end

        if test==[1,1,0]%#ok
            [varargout{1:16}]=blocicon({'Parallel RLC Branch',1,1,0,'RL'});
        end

        if test==[0,1,1]%#ok
            [varargout{1:16}]=blocicon({'Parallel RLC Branch',0,1,1,'LC'});
        end

        if test==[1,1,1]%#ok
            [varargout{1:16}]=blocicon({'Parallel RLC Branch',1,1,1,'RLC'});
        end

    case 'Mutual Inductance'

        ThreeWindings=values{1};


        modifyIO=strcmp(get_param(gcb,'MaskType'),'Mutual Inductance');

        x=[-40,0,0,1,5,11,17,24,29,32,33,31,28,28,24,23,25,28,34,41,47,52,56,56,54,51,51,47,46,48,52,57,64,70,76,79,80,78,74,74,71,70,71,75,81,87,94,99,100,100,100,140];
        y=[0,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,0];
        bx=[-50,50];
        by=[0,0];
        if strcmp(get_param(gcb,'Tag'),'PoWeRsYsTeMbLoCk')
            na=get_param(gcb,'OutputPorts');
            if size(na,1)==2&&ThreeWindings&&modifyIO
                add_block('built-in/Inport',[gcb,'/in_3']);
                set_param([gcb,'/in_3'],'position',[35,140,55,160]);
                set_param([gcb,'/in_3'],'Port','3');
                add_block('built-in/Terminator',[gcb,'/Terminator3']);
                set_param([gcb,'/Terminator3'],'position',[80,135,105,165]);
                add_block('built-in/constant',[gcb,'/Constant3']);
                set_param([gcb,'/Constant3'],'position',[135,135,160,165]);
                add_block('built-in/Outport',[gcb,'/out_3']);
                set_param([gcb,'/out_3'],'position',[190,140,210,160]);
                set_param([gcb,'/out_3'],'Port','3');
                add_line(gcb,'in_3/1','Terminator3/1');
                add_line(gcb,'Constant3/1','out_3/1');
            end
        end
        varargout{1}=-90;
        varargout{2}=-75;
        varargout{3}=90;
        varargout{4}=85;
        varargout{5}=x-50;
        varargout{6}=-y*0.8+58;
        varargout{7}=x-50;
        varargout{8}=y*0.8+5;
        varargout{9}=x-50;
        varargout{10}=y*0.8-49;
        varargout{11}=bx;
        varargout{12}=by+30;
        varargout{13}=bx;
        varargout{14}=by-20;
        if~ThreeWindings
            varargout{2}=-100;
            varargout{4}=110;
            varargout{6}=(-y+60)*1.3-20;
            varargout{7}=[];
            varargout{8}=[];
            varargout{10}=(y-53)*1.3+20;
            varargout{11}=bx;
            varargout{12}=by+5;
            varargout{13}=[];
            varargout{14}=[];
            na=get_param(gcb,'OutputPorts');
            if size(na,1)==3&modifyIO
                if~strcmp('running',get_param(bdroot(gcb),'simulationstatus'));
                    delete_line(gcb,'in_3/1','Terminator3/1');
                    delete_line(gcb,'Constant3/1','out_3/1');
                    delete_block([gcb,'/out_3']);
                    delete_block([gcb,'/in_3']);
                    delete_block([gcb,'/Terminator3']);
                    delete_block([gcb,'/Constant3']);
                end
            end
        end

    case 'Linear Transformer'

        ThreeWindings=values{1};

        x=[0,0,0,1,5,11,17,24,29,32,33,31,28,28,24,23,25,28,34,41,47,52,56,56,54,51,51,47,46,48,52,57,64,70,76,79,80,78,74,74,71,70,71,75,81,87,94,99,100,100,100,100];
        y=[-40,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,-40];
        bx=[-75,75];
        by=[0,0];
        na=get_param(gcb,'OutputPorts');
        if size(na,1)==2&ThreeWindings
            add_block('built-in/Outport',[gcb,'/out_3']);
            set_param([gcb,'/out_3'],'position',[175,115,195,135]);
            set_param([gcb,'/out_3'],'Port','3');
            add_block('built-in/Outport',[gcb,'/out_4']);
            set_param([gcb,'/out_4'],'position',[175,160,195,180]);
            set_param([gcb,'/out_4'],'Port','4');
            add_block('built-in/constant',[gcb,'/Constant3']);
            set_param([gcb,'/Constant3'],'position',[120,110,145,140]);
            add_block('built-in/constant',[gcb,'/Constant4']);
            set_param([gcb,'/Constant4'],'position',[120,155,145,185]);
            add_line(gcb,'Constant3/1','out_3/1');
            add_line(gcb,'Constant4/1','out_4/1');
        end
        varargout{1}=-85;
        varargout{2}=-100;
        varargout{3}=85;
        varargout{4}=100;
        varargout{5}=y-45;
        varargout{6}=x-50;
        varargout{7}=(-y)+45;
        varargout{8}=(x*0.5)+25;
        varargout{9}=(-y)+45;
        varargout{10}=(-x*0.5)-25;
        if~ThreeWindings
            varargout{8}=x-50;
            varargout{9}=[];
            varargout{10}=[];
            na=get_param(gcb,'OutputPorts');
            if size(na,1)==4
                delete_line(gcb,'Constant3/1','out_3/1');
                delete_line(gcb,'Constant4/1','out_4/1');
                delete_block([gcb,'/out_3']);
                delete_block([gcb,'/out_4']);
                delete_block([gcb,'/Constant3']);
                delete_block([gcb,'/Constant4']);
            end
        end
        varargout{11}=by-5;
        varargout{12}=bx;
        varargout{13}=by+5;
        varargout{14}=bx;

    case 'Saturable Transformer'

        ThreeWindings=values{1};
        na=get_param(gcb,'OutputPorts');

        x=[0,0,0,1,5,11,17,24,29,32,33,31,28,28,24,23,25,28,34,41,47,52,56,56,54,51,51,47,46,48,52,57,64,70,76,79,80,78,74,74,71,70,71,75,81,87,94,99,100,100,100,100];
        y=[-40,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,-40];
        if size(na,1)==2&ThreeWindings
            add_block('built-in/Outport',[gcb,'/out_3']);
            set_param([gcb,'/out_3'],'position',[175,115,195,135]);
            set_param([gcb,'/out_3'],'Port','3');
            add_block('built-in/Outport',[gcb,'/out_4']);
            set_param([gcb,'/out_4'],'position',[175,160,195,180]);
            set_param([gcb,'/out_4'],'Port','4');
            add_block('built-in/constant',[gcb,'/Constant3']);
            set_param([gcb,'/Constant3'],'position',[120,110,145,140]);
            add_block('built-in/constant',[gcb,'/Constant4']);
            set_param([gcb,'/Constant4'],'position',[120,155,145,185]);
            add_line(gcb,'Constant3/1','out_3/1');
            add_line(gcb,'Constant4/1','out_4/1');
        end
        varargout{1}=-85;
        varargout{2}=-100;
        varargout{3}=85;
        varargout{4}=100;
        varargout{5}=y-45;
        varargout{6}=x-50;
        varargout{7}=(-y)+45;
        varargout{8}=(x*0.5)+25;
        varargout{9}=(-y)+45;
        varargout{10}=(-x*0.5)-25;
        varargout{11}=[23,10,-10,-23];
        varargout{12}=[80,80,-80,-80];
        if~ThreeWindings
            varargout{8}=x-50;
            varargout{9}=[];
            varargout{10}=[];
            na=get_param(gcb,'OutputPorts');
            if size(na,1)==4
                if~strcmp('running',get_param(bdroot(gcb),'simulationstatus'));
                    delete_line(gcb,'Constant3/1','out_3/1');
                    delete_line(gcb,'Constant4/1','out_4/1');
                    delete_block([gcb,'/out_3']);
                    delete_block([gcb,'/out_4']);
                    delete_block([gcb,'/Constant3']);
                    delete_block([gcb,'/Constant4']);
                end
            end
        end

    case 'Synchronous Machine'

        varargout{1}=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0]*1.2;
        varargout{2}=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30]*1.2+15;
        varargout{3}=[23,48];
        varargout{4}=[27,27]+15;
        varargout{5}=[36,48];
        varargout{6}=[15,15];
        varargout{7}=[23,48];
        varargout{8}=[-27,-27]+15;
        varargout{9}=[-36,-45,-45,60];
        varargout{10}=[0,0,-50,-50];
        varargout{11}=[0,-9,-18,-24,-16,-16,-24,-18,-9,0,9,18,24,16,16,24,18,9,0];
        varargout{12}=[-30,-29,-24,-18,-18,18,18,24,29,30,29,24,18,18,-18,-18,-24,-29,-30]+15;

    case 'PM Synchronous Machine'

        varargout{1}=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0]*1.2;
        varargout{2}=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30]*1.2+15;
        varargout{3}=-[20,48];
        varargout{4}=[45,45];
        varargout{5}=-[36,48];
        varargout{6}=[15,15];
        varargout{7}=-[20,48];
        varargout{8}=[-15,-15];
        varargout{9}=[-10,10,10,-10,-10];
        varargout{10}=[38,38,-8,-8,38];
        varargout{11}=[-2.5,-2.5,2.5,2.5];
        varargout{12}=[0,5,0,5]*1.75+25;
        varargout{13}=[0,5,10,10,0,0,5,10]*.5-2.5;
        varargout{14}=[0,0,2,4,6,8,10,10]*.8;

    case 'Asynchronous Machine'

        RotorType=values{1};
        if isempty(RotorType)
            RotorType=1;
        end
        varargout{1}=[0,10.8,21.6,28.8,34.8,36,34.8,28.8,21.6,10.8,0,-10.8,-21.6,-28.8,-34.8,-36,-34.8,-28.8,-21.6,-10.8,0];
        varargout{2}=[56.1,54.78,48.18,40.26,28.38,16.5,4.62,-7.26,-15.18,-21.78,-23.1,-21.78,-15.18,-7.26,4.62,16.5,28.38,40.26,48.18,54.78,56.1];
        varargout{3}=[-20,-43];
        varargout{4}=[50,50];
        varargout{5}=[-36,-43];
        varargout{6}=[15,15];
        varargout{7}=[-18,-43];
        varargout{8}=[-18,-18];
        switch RotorType
        case 1
            varargout{9}=[15,30,43];
            varargout{10}=[40,50,50];
            varargout{11}=[45,27];
            varargout{12}=[15,15];
            varargout{13}=[15,30,43];
            varargout{14}=[-9,-18,-18];
        case 2
            varargout{9}=15;
            varargout{10}=40;
            varargout{11}=45;
            varargout{12}=15;
            varargout{13}=15;
            varargout{14}=-9;
        end
        varargout{15}=varargout{1}*0.75;
        varargout{16}=varargout{2}*0.75+4;

    case 'Distributed Parameters Line'

        nphase=values{1};
        sys=get_param(0,'CurrentSystem');
        block=get_param(sys,'CurrentBlock');
        objet=[sys,'/',block];
        actx=get_param(objet,'inport');

        if isempty(nphase);nphase=size(actx,1);end

        if isinf(nphase);nphase=size(actx,1);end

        varargout{1}=[0,20,20,80,80,100,80,80,20,20];
        varargout{2}=[0,0,5,5,0,0,0,-5,-5,0]+76;
        varargout{3}=0;
        varargout{4}=0;
        varargout{5}=0;
        varargout{6}=0;
        varargout{7}=0;
        varargout{8}=0;
        if nphase==2;
            varargout{2}=[0,0,5,5,0,0,0,-5,-5,0]+82;
            varargout{3}=varargout{1};
            varargout{4}=[0,0,5,5,0,0,0,-5,-5,0]+50;
        end
        if nphase==3
            varargout{2}=[0,0,5,5,0,0,0,-5,-5,0]+89;
            varargout{3}=varargout{1};
            varargout{4}=[0,0,5,5,0,0,0,-5,-5,0]+63;
            varargout{5}=varargout{1};
            varargout{6}=[0,0,5,5,0,0,0,-5,-5,0]+37;
        end
        if nphase>3
            varargout{1}=varargout{1}*0.5+25;
            varargout{2}=([0,0,5,5,0,0,0,-5,-5,0]+100)*.5;
        end
        if sum(actx)==0
            return
        end

        in=size(actx,1);
        if nphase>in,
            for i=in+1:nphase
                Y1=(i-1)*50+25;
                add_block('built-in/Inport',[objet,'/',num2str(i)])
                set_param([objet,'/',num2str(i)],...
                'position',[25,Y1,45,Y1+20],'Port',num2str(i))
                add_block('built-in/Terminator',[objet,'/t',num2str(i)])
                set_param([objet,'/t',num2str(i)],...
                'position',[80,Y1-5,105,Y1+25]);
                add_line(objet,[num2str(i),'/1'],['t',num2str(i),'/1'])
                add_block('built-in/Outport',[objet,'/ ',num2str(i)])
                set_param([objet,'/ ',num2str(i)],...
                'position',[185,Y1,205,Y1+20],'Port',num2str(i))
                add_block('built-in/Constant',[objet,'/g',num2str(i)])
                set_param([objet,'/g',num2str(i)],...
                'position',[130,Y1-5,155,Y1+25]);
                add_line(objet,['g',num2str(i),'/1'],[' ',num2str(i),'/1']);
            end
        end
        if nphase<in
            for i=in:-1:nphase+1
                delete_line(objet,[num2str(i),'/1'],['t',num2str(i),'/1']);
                delete_block([objet,'/',num2str(i)]);
                delete_block([objet,'/t',num2str(i)]);
                delete_line(objet,['g',num2str(i),'/1'],[' ',num2str(i),'/1']);
                delete_block([objet,'/ ',num2str(i)]);
                delete_block([objet,'/g',num2str(i)]);
            end
        end

    case 'Breaker'

        InitialState=values{1};
        Rs=values{2};
        Cs=values{3};
        times=values{4};
        ComExt=values{5};
        if isempty(InitialState);InitialState=0;end
        if isempty(Rs);Rs=Inf;end;
        if isempty(Cs);Cs=0;end;
        if isempty(times);times=0;end;
        if isempty(ComExt);ComExt=0;end;
        if InitialState==0
            varargout{3}=75;
        else
            varargout{3}=50;
        end
        if(Rs==Inf)|(Cs==0)
            varargout{4}=50;
            varargout{5}=50;
        else
            varargout{4}=[20,20,40,40,60,60,80,80,80,60,60,40,40];
            varargout{5}=[45,30,30,35,35,30,30,45,30,30,25,25,30];
        end
        n=length(times);
        vec_dt=[times,0]-[0,times];
        vec_dt=vec_dt(2:n);
        if any(vec_dt<=0),
            message=['In mask of ''',gcb,''' block:',char(10),'Saturation data must be a 2-by-N array for N points.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        switchings=ones(1,length(times));
        switchings(2-InitialState:2:length(times))=0;
        com=strcmp(ComExt,'on');
        if~com
            set_param(gcb,'MaskIconFrame','off');
            set_param(gcb,'MaskIconOpaque','on');
            varargout{1}=15;
            varargout{2}=85;
        else
            varargout{1}=0;
            varargout{2}=100;
            set_param(gcb,'MaskIconFrame','on');
            set_param(gcb,'MaskIconOpaque','off');
        end
        varargout{6}=com;
        varargout{7}=switchings;

    case 'PowerSwitch'











    case '3-phase inductive source - Ungrounded neutral'

        R=values{1};
        L=values{2};
        if isempty(R),R=0;end
        if isempty(L),L=0;end
        short_x=[0,150];
        short_y=[0,0];
        resistor_x=[0,30,30,38,53,68,83,98,113,120,120,150];
        resistor_y=[0,0,0,25,-25,25,-25,25,-25,0,0,0];
        inductor_x=[150,173,173,174,178,184,190,197,202,205,206,204,201,201,197,196,198,201,207,214,220,225,229,229,227,224,224,220,219,221,225,230,237,243,249,252,253,251,247,247,244,243,244,248,254,260,267,272,275,276,276,300];
        inductor_y=[0,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,0];
        if R~=0
            varargout{1}=resistor_x;
            varargout{2}=resistor_y;
        else
            varargout{1}=short_x;
            varargout{2}=short_y;
        end
        if L~=0
            varargout{3}=inductor_x;
            varargout{4}=inductor_y;
        else
            varargout{3}=short_x+150;
            varargout{4}=short_y;
        end

    case '3-phase RL  positive & zero-sequence impedance'

        RL1=values{1};
        RL0=values{2};
        if isempty(RL1);RL1=[0,0];end
        if isempty(RL0);RL0=[0,0];end
        if sum(size(RL1)~=[1,2]);
            message=['In mask of ''',gcb,''' block:',char(10),'Positive-sequence parameter must be a [1 by 2] vector.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if sum(size(RL0)~=[1,2]);
            message=['In mask of ''',gcb,''' block:',char(10),'Zero-sequence parameter must be a [1 by 2] vector.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7},varargout{8},varargout{9},varargout{10}]=blocicon({'Mutual Inductance',[1,1]});
        varargout{5}=varargout{5}*0.7;
        varargout{7}=varargout{7}*0.7;
        varargout{9}=varargout{9}*0.7;
        varargout{11}=(2*RL1(1)+RL0(1))/3;
        varargout{12}=(2*RL1(2)+RL0(2))/3;
        varargout{13}=(RL0(1)-RL1(1))/3;
        varargout{14}=(RL0(2)-RL1(2))/3;

    case '3-phase RLC series element'



























    case '3-phase parallel RLC element'









    case '3-phase series RLC load'













    case '3-phase parallel RLC load'














    case 'Three-phase Linear Transformer 12-terminals'

        x=[0,0,0,1,5,11,17,24,29,32,33,33,30,30,26,25,27,31,36,43,49,55,58,59,57,53,53,50,49,50,54,60,66,73,78,79,79,79,79]*.5;
        y=[-40,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,-40]*.7;
        bx=[0,40];
        by=[0,0];

        varargout{1}=y-40;
        varargout{2}=x+50;
        varargout{3}=(-y)+40;
        varargout{4}=x+50;

        varargout{5}=y-40;
        varargout{6}=x-20;
        varargout{7}=(-y)+40;
        varargout{8}=x-20;


        varargout{9}=y-40;
        varargout{10}=x-90;
        varargout{11}=(-y)+40;
        varargout{12}=x-90;


        varargout{13}=by-5;
        varargout{14}=bx+50;
        varargout{15}=by+5;
        varargout{16}=bx+50;

        varargout{17}=by-5;
        varargout{18}=bx-20;
        varargout{19}=by+5;
        varargout{20}=bx-20;

        varargout{21}=by-5;
        varargout{22}=bx-90;
        varargout{23}=by+5;
        varargout{24}=bx-90;


    case 'Three-Phase Fault'

        Rdef=values{1};
        Rt=values{2};
        sw_times=values{3};
        sw_status=values{4};
        sa=values{5};
        sb=values{6};
        sc=values{7};
        st=values{8};
        init_statext=values{9};
        comext=values{10};

        if isempty(Rdef);Rdef=0.001;end
        if isempty(Rt);Rt=0.001;end
        if isempty(sw_times);sw_times=[0.001];end
        if isempty(sw_status);sw_status=[1];end
        if isempty(init_statext);init_statext=[1,1,1];end

        desc0='error';
        desc1='';
        desc2='';
        desc3='';
        desc4='';
        st_a=0;
        st_b=0;
        st_c=0;

        if Rdef<=0
            PowerguiInfo=getPowerguiInfo(bdroot(gcb),gcb);
            if PowerguiInfo.SPID==0
                message=['In mask of ''',gcb,''' block:',char(10),'You must specify a fault resistance greater than zero.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
        end
        if Rt<=0
            message=['In mask of ''',gcb,''' block:',char(10),'You must specify a ground resistance greater than zero.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if length(sw_times)~=length(sw_status)
            message=['In mask of ''',gcb,''' block:',char(10),'The vectors specifying the transition times and status must have the same length.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if~all(sw_status==0|sw_status==1)
            message=['In mask of ''',gcb,''' block:',char(10),'All fault status must be 0 or 1.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if sw_times(1)==0
            message=['In mask of ''',gcb,''' block:',char(10),'You cannot specify a fault status for time zero.',char(10),'A status of ',num2str(sw_status(1)),' is implicitely defined by the fault status vector.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        n=length(sw_times);
        vec_dt=[sw_times,0]-[0,sw_times];
        vec_dt=vec_dt(2:n);
        if any(vec_dt<=0)
            message=['In mask of ''',gcb,''' block:',char(10),'Transition times must be defined in increasing order.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        if strcmp(sa,'off')&strcmp(sb,'off')&strcmp(sc,'off')
            desc0='No Fault';
        else
            desc0='Fault';
        end
        nb_fault=0;
        if strcmp(sa,'on')
            st_a=1;
            desc1='A';
            nb_fault=nb_fault+1;
        end
        if strcmp(sb,'on')
            st_b=1;
            desc2='B';
            nb_fault=nb_fault+1;
        end
        if strcmp(sc,'on'),
            st_c=1;
            desc3='C';
            nb_fault=nb_fault+1;
        end
        if strcmp(st,'on')&strcmp(desc0,'Fault')
            desc4='-G';
        end
        if nb_fault==1&strcmp(st,'off'),
            st_a=0;
            st_b=0;
            st_c=0;
            desc0='No fault';
            desc1='';
            desc2='';
            desc3='';
            desc4='';
        end
        if strcmp(st,'on')
            Rground=Rt;
        else
            Rground=1e6;
        end

        init_a=st_a*~(sw_status(1));
        init_b=st_b*~(sw_status(1));
        init_c=st_c*~(sw_status(1));
        if comext==1,
            init_a=init_statext(1);
            init_b=init_statext(2);
            init_c=init_statext(3);
        end;
        varargout{1}=st_a;
        varargout{2}=st_b;
        varargout{3}=st_c;
        varargout{4}=Rground;
        varargout{5}=init_a;
        varargout{6}=init_b;
        varargout{7}=init_c;
        varargout{8}=abs(desc0);
        varargout{9}=abs(desc1);
        varargout{10}=abs(desc2);
        varargout{11}=abs(desc3);
        varargout{12}=abs(desc4);

    case 'Three-Phase Breaker'

        init_states=values{1};
        sa=values{2};
        sb=values{3};
        sc=values{4};
        Ron=values{5};
        sw_times=values{6};
        comext=values{7};
        if strcmp(init_states,'open');
            etat=0;
        else;
            etat=1;
        end

        if isempty(Ron);Ron=0.001;end
        if isempty(sw_times);sw_times=[0.001];end

        desc0='error';
        desc1='';
        desc2='';
        desc3='';
        sta=0;
        stb=0;
        stc=0;
        if strcmp(sa,'on')
            sta=1;
            desc1='A';
        end
        if strcmp(sb,'on')
            stb=1;
            desc2='B';
        end
        if strcmp(sc,'on')
            stc=1;
            desc3='C';
        end

        if Ron<=0,
            PowerguiInfo=getPowerguiInfo(bdroot(gcb),gcb);
            if PowerguiInfo.SPID==0
                message=['In mask of ''',gcb,''' block:',char(10),'You must specify breaker resistances greater than zero.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end
        end
        n=length(sw_times);
        vec_dt=[sw_times,0]-[0,sw_times];
        vec_dt=vec_dt(2:n);
        if any(vec_dt<=0)&strcmp(comext,'off')
            message=['In mask of ''',gcb,''' block:',char(10),'Transition times must be defined in increasing order.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        if~sta&~stb&~stc,
            desc0='No';
            desc1='Switch.';
        else
            desc0='Switch. ';
        end
        switchings=ones(1,length(sw_times));
        switchings(2-etat:2:length(sw_times))=0;
        varargout{1}=sta;
        varargout{2}=stb;
        varargout{3}=stc;
        varargout{4}=etat;
        varargout{5}=sw_times;
        varargout{6}=switchings;
        varargout{7}=abs(desc0);
        varargout{8}=abs(desc1);
        varargout{9}=abs(desc2);
        varargout{10}=abs(desc3);

    case 'Three-phase transmission line pi-section'

        f=values{1};
        R10=values{2};
        L10=values{3};
        C10=values{4};
        long=values{5};

        if isempty(f);f=60;end
        if isempty(R10);R10=[0.012,.38];end
        if isempty(L10);L10=[.93e-3,4.12e-3];end
        if isempty(C10);C10=[12.7e-9,7.75e-9];end
        if isempty(long);long=100;end

        if C10(1)==C10(2)
            message=['In mask of ''',gcb,''' block:',char(10),'The positive- and zero-sequence capacitances must be different.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        w=2*pi*f;
        [z_ser1,y_sh1]=etazline(long,R10(1),L10(1)*w,C10(1)*w);
        [z_ser0,y_sh0]=etazline(long,R10(2),L10(2)*w,C10(2)*w);
        R1=real(z_ser1);
        L1=imag(z_ser1)/w;
        C1=imag(y_sh1)/w;
        R0=real(z_ser0);
        L0=imag(z_ser0)/w;
        C0=imag(y_sh0)/w;
        varargout{1}=(2*R1+R0)/3;
        varargout{2}=(2*L1+L0)/3;
        varargout{3}=(R0-R1)/3;
        varargout{4}=(L0-L1)/3;
        varargout{5}=C1;
        varargout{6}=3*C1*C0/(C1-C0);

    case 'Bus Bar'

        entrees=values{1};
        sorties=values{2};

        if isempty(entrees);entrees=1;end
        if isempty(sorties);sorties=1;end

        varargout{1}=0;
        varargout{2}=0;
        varargout{3}=0;

        entrees=floor(entrees(1));
        sorties=floor(sorties(1));

        if entrees==0&sorties==0
            message=['In mask of ''',gcb,''' block:',char(10),'The number of inputs and outputs cannot be set to zero.',char(10),'A minimum of one input or one output is required.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        sys=get_param(0,'CurrentSystem');
        block=get_param(sys,'CurrentBlock');
        type=get_param([sys,'/',block],'mask type');
        objet=[sys,'/',block];

        ori=get_param(objet,'orientation');
        posi=get_param(objet,'position');
        if strcmp(ori,'left')|strcmp(ori,'right')
            upperleft=posi(2);
            varargout{1}=posi(4)-posi(2);
            isop=get_param(objet,'InputPorts');
            branches_in=isop(:,2)-upperleft;
            isop=get_param(objet,'OutputPorts');
            branches_out=isop(:,2)-upperleft;
        else
            upperleft=posi(3);
            varargout{1}=posi(3)-posi(1);
            isop=get_param(objet,'InputPorts');
            branches_in=isop(:,1)-upperleft;
            isop=get_param(objet,'OutputPorts');
            branches_out=isop(:,1)-upperleft;
        end
        flag=0;
        if isempty(branches_in)&isempty(branches_out),
            varargout{1}=156;
            branches={[78],[38;118],[28;78;128],[18;58;98;138],[23;53;83;113;143],[18;43;68;93;118;143]};
            if entrees>0
                branches_in=branches{entrees};
            else
                branches_in=[];
            end
            if sorties>0
                branches_out=branches{sorties};
            else
                branches_out=[];
            end
            flag=1;
        end

        if flag==0
            in=size(branches_in,1);
            ou=size(branches_out,1);
            if entrees>in,
                for i=in+1:entrees
                    Y1=(i-1)*50+25;
                    add_block('built-in/Inport',[objet,'/in_',num2str(i)])
                    set_param([objet,'/in_',num2str(i)],...
                    'position',[25,Y1,45,Y1+20],'Port',num2str(i))
                    add_block('built-in/Terminator',[objet,'/t',num2str(i)])
                    set_param([objet,'/t',num2str(i)],...
                    'position',[80,Y1-5,105,Y1+25]);
                    add_line(objet,['in_',num2str(i),'/1'],['t',num2str(i),'/1'])
                end
            end
            if sorties>ou
                for i=ou+1:sorties
                    Y1=(i-1)*50+25;
                    add_block('built-in/Outport',[objet,'/out_',num2str(i)])
                    set_param([objet,'/out_',num2str(i)],...
                    'position',[185,Y1,205,Y1+20],'Port',num2str(i))
                    add_block('built-in/constant',[objet,'/g',num2str(i)])
                    set_param([objet,'/g',num2str(i)],...
                    'position',[130,Y1-5,155,Y1+25]);
                    add_line(objet,['g',num2str(i),'/1'],['out_',num2str(i),'/1']);
                end
            end
            if entrees<in
                for i=in:-1:entrees+1
                    delete_line(objet,['in_',num2str(i),'/1'],['t',num2str(i),'/1']);
                    delete_block([objet,'/in_',num2str(i)]);
                    delete_block([objet,'/t',num2str(i)]);
                end
            end
            if sorties<ou
                for i=ou:-1:sorties+1
                    delete_line(objet,['g',num2str(i),'/1'],['out_',num2str(i),'/1']);
                    delete_block([objet,'/out_',num2str(i)]);
                    delete_block([objet,'/g',num2str(i)]);
                end
            end
            if strcmp(ori,'left')||strcmp(ori,'right')
                isop=get_param(objet,'InputPorts');
                branches_in=abs(isop(:,2)-upperleft);
                isop=get_param(objet,'OutputPorts');
                branches_out=abs(isop(:,2)-upperleft);
            else
                isop=get_param(objet,'InputPorts');
                branches_in=abs(isop(:,1)-upperleft);
                isop=get_param(objet,'OutputPorts');
                branches_out=abs(isop(:,1)-upperleft);
            end
        end

        dep=max([branches_in;branches_out]);
        arr=min([branches_in;branches_out]);
        varargout{2}=[5,5];
        varargout{3}=[dep,arr];

        o=get_param(gcb,'orientation');
        posi=get_param(gcb,'position');
        if strcmp(o,'right')||strcmp(o,'left')
            set_param(gcb,'position',[posi(1),posi(2),posi(1)+5,posi(4)]);
        else
            set_param(gcb,'position',[posi(1),posi(2),posi(3),posi(2)+5]);
        end

    end