function[p1,p2,p3,p4,p5,p6,p7,p8,mot,t1]=SaturableTransformerIcon(ThreeWindings)






    x=[0,0,0,1,5,11,17,24,29,32,33,31,28,28,24,23,25,28,34,41,47,52,56,56,54,51,51,47,46,48,52,57,64,70,76,79,80,78,74,74,71,70,71,75,81,87,94,99,100,100,100,100];
    y=[-40,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,-40];

    p1=(y-45);
    p2=(x-50);
    p3=(-y+45);
    p7=[23,10,-10,-23];
    p8=[80,80,-80,-80];
    if ThreeWindings
        p4=((x*0.5)+25);
        p5=((-y)+45);
        p6=((-x*0.5)-25);
        mot='3';
        t1=50;
    else
        p4=(x-50);
        p5=0;
        p6=0;
        mot='';
        t1=0;
    end