function[feed_pt1,feed_pt1_idx,feed_pt2,feed_pt2_idx]=findcommonedge(tr1,feed_x,feed_y,W,feededgeaxis)





    nameOfFunction='findcommonedge';

    validateattributes(tr1,{'triangulation'},...
    {'nonempty'},...
    nameOfFunction,'Triangulation object',1);
    validateattributes(feed_x,{'numeric'},...
    {'nonempty','finite','real',...
    'nonnan','scalar'},...
    nameOfFunction,'Point 1',2);

    validateattributes(feed_y,{'numeric'},...
    {'nonempty','finite','real',...
    'nonnan','scalar'},...
    nameOfFunction,'feed_y',3);

    validateattributes(W,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Width',4);

    validateattributes(feededgeaxis,{'char','string'},{'nonempty','scalartext'},nameOfFunction,...
    'Axis of feeding edge',4);

    switch feededgeaxis
    case 'Edge-Y'
        test_pt1=[feed_x,feed_y-(W/2)];
        test_pt2=[feed_x,feed_y+(W/2)];
    case 'Edge-X'
        test_pt1=[feed_x-(W/2),feed_y];
        test_pt2=[feed_x+(W/2),feed_y];
    end

    [vertexID1,d1]=dsearchn(tr1.Points,test_pt1);
    [vertexID2,d2]=dsearchn(tr1.Points,test_pt2);
    isFeedPtAnEdge=isConnected(tr1,vertexID1,vertexID2);
    if(isFeedPtAnEdge)
        if(d1==0)&&(d2==0)
            feed_pt1=test_pt1';
            feed_pt1_idx=vertexID1;
            feed_pt2=test_pt2';
            feed_pt2_idx=vertexID2;
        else
            tempX=[test_pt1(1),test_pt2(1),feed_x];
            tempY=[test_pt1(2),test_pt2(2),feed_y];
            tempArea=em.internal.findArea(tempX,tempY);
            if(abs(tempArea)<eps)
                feed_pt1=tr1.Points(vertexID1,:)';
                feed_pt1_idx=vertexID1;
                feed_pt2=tr1.Points(vertexID2,:)';
                feed_pt2_idx=vertexID2;


            end
        end
    else
        feed_pt1=[];
        feed_pt1_idx=[];
        feed_pt2=[];
        feed_pt2_idx=[];
    end

end
