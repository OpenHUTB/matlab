function checkMeshForLargeStructure(obj,Mesh)

    if isfield(obj.MesherStruct,'UsePO')
        if obj.MesherStruct.UsePO==1
            p=Mesh.Points';
            t=Mesh.Triangles';
            [~,ind]=sort(t(:,4),'ascend');
            t=t(ind,:);
            radIndx=t(:,4)~=101;
            refIndx=t(:,4)>=101;
            trad=t(radIndx,:);

            tref=t(refIndx,:);

            prad=p;
            p=p';
            tref=tref';
            prad=prad';
            trad=trad';

            Parts=em.internal.makeMeshPartsStructure('Gnd',[{p},{tref}],...
            'Rad',[{prad},{trad}]);
            savePartMesh(obj,Parts);
        end
    end