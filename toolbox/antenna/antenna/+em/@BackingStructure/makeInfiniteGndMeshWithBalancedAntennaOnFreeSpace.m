function[Mesh,Parts]=makeInfiniteGndMeshWithBalancedAntennaOnFreeSpace(obj,isRemesh)



    if isRemesh


        createGeometry(obj);

        checkIntersectionForInfGndPlane(obj);

        meshExciter(obj);
        minel=getMinContourEdgeLength(obj.Exciter);
        setMeshMinContourEdgeLength(obj,minel);

        [pexciter,texciter]=getExciterMesh(obj);

        [pimage,timage]=createImage(obj,pexciter,texciter);
    else

        [pexciter,texciter]=getExciterMesh(obj);
        [pimage,timage]=getPartMesh(obj,'Rad');
        pimage=cell2mat(pimage(1));
        timage=cell2mat(timage(1));
    end



    [Mesh,Parts]=assembleAndVerifyInfiniteGndMesh(obj,pexciter,texciter,pimage,timage);

end
