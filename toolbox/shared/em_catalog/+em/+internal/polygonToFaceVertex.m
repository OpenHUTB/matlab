function[faces,vertices]=polygonToFaceVertex(x,y)









    dt=em.internal.triangulatePolygon(x,y);


    vertices=dt.Points;
    faces=dt.ConnectivityList;


    inside=dt.isInterior();
    faces(~inside,:)=[];
