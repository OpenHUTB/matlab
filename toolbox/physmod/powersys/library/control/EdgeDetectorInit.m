function[WantBlockChoice,Ts,sps]=EdgeDetectorInit(block,ic,model,Ts)






    if model==3
        x1=20;
        x2=60;
        sps.X1=[5,20,20,35]+8;
        sps.Y1=[20,20,80,80];
        sps.X2=[5,20,35]+8;
        sps.Y2=[40,60,40];
        sps.X3=[5,20,20,35]+53;
        sps.Y3=[20+x2,20+x2,80-x2,80-x2];
        sps.X4=[5,20,35]+53;
        sps.Y4=[40+x1,60-x1,40+x1];
    else
        x1=(model-1)*20;
        x2=(model-1)*60;
        sps.X1=[5,20,20,35]+25;
        sps.Y1=[20+x2,20+x2,80-x2,80-x2];
        sps.X2=[5,20,35]+25;
        sps.Y2=[40+x1,60-x1,40+x1];
        sps.X3=[];
        sps.X4=[];
        sps.Y3=[];
        sps.Y4=[];
    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,1);



    if Init
        if~all(ic==0|ic==1)
            error(message('physmod:powersys:common:InvalidParameterState','Initial condition of previous input',block,'0','1'));
        end
    end