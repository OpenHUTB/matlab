function[domain,solid]=filterdomains(triangulation1,theta)

    tr=triangulation1;




    fe=tr.featureEdges(theta);

    domain=zeros(size(tr.ConnectivityList,1),1);
    bound=domain;
    solid=domain;
    edgetriang=edgeAttachments(tr,fe);
    edgetriangSize=cell2mat(cellfun(@(x)size(x,2),edgetriang,'UniformOutput',false));
    maxval=max(edgetriangSize);
    edgeTriangmat=ones(size(edgetriangSize,1),maxval)*-1;
    for i=1:maxval
        edgeTriangmat(edgetriangSize==i,1:i)=cell2mat(edgetriang(edgetriangSize==i));
    end

    edgetriang=edgeTriangmat;

    bound(setdiff(unique(edgetriang(:)),-1))=-1;
    idx=floor(rand*(size(tr.Points,1)-1))+1;
    tri=cell2mat(vertexAttachments(tr,idx));
    tri=tri(1);
    domainNum=1;
    solidnum=1;
    while any(domain==0)
        domain(tri)=domainNum;
        solid(tri)=solidnum;
        ntri=[];
        for i=1:numel(tri)
            n=neighbors(tr,tri(i));
            n=n(~isnan(n));
            if any(solid(n)>0)
                diffSolids=solid(n(solid(n)>0));
                neighborsolids=unique([diffSolids',solidnum]);
                solidNumberNew=min(neighborsolids);
                if solidNumberNew==0
                    solidNumberNew=solidnum;
                end
                for j=1:numel(neighborsolids)
                    solid(solid==neighborsolids(j))=solidNumberNew;
                end
                solidnum=solidNumberNew;
            else
                solid(n)=solidnum;
            end
            idx=edgetriang==tri(i);
            idx2=edgetriang==-1;
            idx=sum(and(idx,~idx2),2);
            if(sum(idx)~=0)

                othersideedgeTriang=setdiff(unique(edgetriang(logical(idx),:)),-1);
                ntri=[ntri,setdiff(n,othersideedgeTriang)];
            else
                ntri=[ntri,n];
            end

        end
        id=domain(ntri)==domainNum;
        ntri=ntri(~id);
        if isempty(ntri)
            solidnum=max(solid)+1;
            domainNum=domainNum+1;
            f=find(domain==0);
            if(isempty(f))
                break;
            else
                numElem=size(f,1);
                idx=rand*numElem;
                idx=abs(floor(idx));
                if round(idx)==0
                    idx=numElem;
                end
                try
                    tri=f(idx);
                catch
                    idx;
                end
            end
        else
            tri=setdiff(ntri,tri);
        end

    end

end
