function fv=makeStripShape(mlayer,vias,viadia,layer_heights)




    dia=viadia;

    mlayer1=mlayer{1,vias(1,3)};

    mlayer2=mlayer{1,vias(1,4)};

    layerHeightTop=layer_heights(vias(1,3));
    layerHeightBtm=layer_heights(vias(1,4));





    Xpt_layer1=mlayer1.BorderVertices(:,1);

    Xpt_layer2=mlayer2.BorderVertices(:,1);

    Ypt_layer1=mlayer1.BorderVertices(:,2);

    Ypt_layer2=mlayer2.BorderVertices(:,2);













    eps=1e-12;
    Xpttop=abs(Xpt_layer1-vias(1,1))<eps;
    Xptbtm=abs(Xpt_layer2-vias(1,1))<eps;


    XNumptsStartL=numel(find(Xpttop(:,1)==1));
    XNumptsStopL=numel(find(Xptbtm(:,1)));



    Ypttop=abs(Ypt_layer1-vias(1,2))<eps;
    Yptbtm=abs(Ypt_layer2-vias(1,2))<eps;


    YNumptsStartL=numel(find(Ypttop(:,1)==1));
    YNumptsStopL=numel(find(Yptbtm(:,1)));







    if XNumptsStartL>=2||XNumptsStopL>=2












        ViaXptindtop=sort(find(Xpttop(:,1)==1));
        ViaXptindbtm=sort(find(Xptbtm(:,1)==1));


        PairViaXpTop=nchoosek(ViaXptindtop,2);
        PairViaXpTop=reshape(PairViaXpTop',1,numel(PairViaXpTop));
        ViaXptindtop=PairViaXpTop';


        PairViaXpBtm=nchoosek(ViaXptindbtm,2);
        PairViaXpBtm=reshape(PairViaXpBtm',1,numel(PairViaXpBtm));
        ViaXptindbtm=PairViaXpBtm';



        if~isempty(ViaXptindtop)
            ViaXptind=ViaXptindtop;



            ViaYCen=zeros(numel(ViaXptind)/2,1);
            count=0;
            for i=1:2:numel(ViaXptind)
                count=count+1;

                consec=[Ypt_layer1(ViaXptind(i),1),Ypt_layer1(ViaXptind(i+1),1)];


                ViaYCen(count,1)=((consec(1,1)+consec(1,2))/2);
            end
        end













        if~isempty(ViaXptindbtm)&&isempty(ViaXptindtop)
            ViaXptind=ViaXptindbtm;



            ViaYCen=zeros(numel(ViaXptind)/2,1);
            count=0;
            for i=1:2:numel(ViaXptind)
                count=count+1;

                consec=[Ypt_layer2(ViaXptind(i),1),Ypt_layer2(ViaXptind(i+1),1)];


                ViaYCen(count,1)=((consec(1,1)+consec(1,2))/2);
            end
        end



        ViaYcenind=find((abs(ViaYCen(:,1)-vias(1,2))<eps)==1,1);


        if~isempty(ViaYcenind)||~(YNumptsStartL>=2||YNumptsStopL>=2)
            xp=ones(2,2);
            xp=xp.*vias(1,1);
            yp=[vias(1,2)-dia,vias(1,2)+dia;vias(1,2)+dia,vias(1,2)-dia];
        end
    end



    if YNumptsStartL>=2||YNumptsStopL>=2





        ViaYptindtop=sort(find(Ypttop(:,1)==1));
        ViaYptindbtm=sort(find(Yptbtm(:,1)==1));


        PairViaYpTop=nchoosek(ViaYptindtop,2);
        PairViaYpTop=reshape(PairViaYpTop',1,numel(PairViaYpTop));
        ViaYptindtop=PairViaYpTop';


        PairViaYpBtm=nchoosek(ViaYptindbtm,2);
        PairViaYpBtm=reshape(PairViaYpBtm',1,numel(PairViaYpBtm));
        ViaYptindbtm=PairViaYpBtm';



        if~isempty(ViaYptindtop)
            ViaYptind=ViaYptindtop;
            ViaXCen=zeros(numel(ViaYptind)/2,1);
            count=0;
            for i=1:2:numel(ViaYptind)
                count=count+1;
                consec=[Xpt_layer1(ViaYptind(i),1),Xpt_layer1(ViaYptind(i+1),1)];
                ViaXCen(count,1)=((consec(1,1)+consec(1,2))/2);
            end
        end













        if~isempty(ViaYptindbtm)&&isempty(ViaYptindtop)
            ViaYptind=ViaYptindbtm;
            ViaXCen=zeros(numel(ViaYptind)/2,1);
            count=0;
            for i=1:2:numel(ViaYptind)
                count=count+1;
                consec=[Xpt_layer2(ViaYptind(i),1),Xpt_layer2(ViaYptind(i+1),1)];
                ViaXCen(count,1)=((consec(1,1)+consec(1,2))/2);
            end
        end

        ViaXcenind=find((abs(ViaXCen(:,1)-vias(1,1))<eps)==1,1);



        if~isempty(ViaXcenind)||~(XNumptsStartL>=2||XNumptsStopL>=2)
            xp=[vias(1,1)-dia,vias(1,1)+dia;vias(1,1)+dia,vias(1,1)-dia];
            yp=ones(2,2);
            yp=yp.*vias(1,2);
        end
    end

    zp=ones(2,2);
    zp(1,:)=[layerHeightBtm,layerHeightBtm];
    zp(2,:)=[layerHeightTop,layerHeightTop];
    fv=surf2patch(xp,yp,zp);
    fv.BoundaryEdges=[1,3,2,4];
    fv.faces=[1,2,3;1,2,4];
    fv.vertices=fv.vertices';

end
