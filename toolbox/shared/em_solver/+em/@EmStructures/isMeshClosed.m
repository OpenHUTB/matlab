function tf=isMeshClosed(obj)

    tf=true;
    TR=triangulation(obj.MesherStruct.Mesh.t(1:3,:)',obj.MesherStruct.Mesh.p');
    e=edges(TR);

    n=size(TR.Points,1)+size(TR.ConnectivityList,1)-size(e,1);


    if n<2




        tf=false;
    end