function[ZL,loadedge]=loadingedgerfpcb(obj,~,frequency,...
    Zterm,addtermination,hwait)





    loadedge=0;ZL=50;
    if obj.MesherStruct.Load.numLoads==0&&addtermination==0
        return;
    end

    loadedge=[];Imp=[];frq=[];
    Zimp=obj.MesherStruct.Load.Impedance;
    Zfrq=obj.MesherStruct.Load.Frequency;
    Zfeed=obj.MesherStruct.Load.Feedtype;

    if iscell(Zfeed)
        idx=cellfun(@isempty,Zfeed);
        if any(idx)
            Zfeed(idx)={obj.MesherStruct.Mesh.FeedType};
        end
    end
    Zloc=obj.MesherStruct.Load.Location;
    numZloc=numel(Zloc)/3;

    for m=1:numZloc
        if any(strcmpi(Zfeed{m},'multiedge'))
            tmpedge=em.EmStructures.getFeedEdges(obj,obj.MesherStruct.Mesh.p,...
            obj.SolverStruct.RWG);
            tmpedge=tmpedge(:,m);
        else
            tmpedge=em.EmStructures.feeding_edge(obj.MesherStruct.Mesh.p,...
            obj.SolverStruct.RWG.Edges,Zloc(:,m),Zfeed{m});
        end
        loadedge=[loadedge,tmpedge'];%#ok<AGROW>
        if strcmpi(Zfeed{m},'doubleedge')
            Imp=[Imp,{2*Zimp{m}},{2*Zimp{m}}];%#ok<AGROW>
            frq=[frq,{Zfrq{m}},{Zfrq{m}}];%#ok<AGROW,CCAT1>
        elseif strcmpi(Zfeed{m},'multiedge')
            valImp=cell(1,numel(tmpedge));
            valfrq=cell(1,numel(tmpedge));
            for mm=1:numel(tmpedge)
                valImp{mm}=Zimp{m}.*numel(tmpedge);
                valfrq{mm}=Zfrq{m};
            end
            Imp=[Imp,valImp];%#ok<AGROW>
            frq=[frq,valfrq];%#ok<AGROW>
        else
            Imp=[Imp,{Zimp{m}}];%#ok<AGROW,CCAT1>
            frq=[frq,{Zfrq{m}}];%#ok<AGROW,CCAT1>
        end
    end

    if isempty(loadedge)
        loadedge=0;
    end

    if~all(loadedge==0)

        warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
        TR=triangulation(obj.MesherStruct.Mesh.t(1:3,:)',obj.MesherStruct.Mesh.p');
        warning(warnState);
        ti=edgeAttachments(TR,obj.SolverStruct.RWG.Edges(:,loadedge)');
        patchFaces=[];patchVertices=[];
        for m=1:numel(ti)
            Faces=obj.MesherStruct.Mesh.t(1:3,ti{m});
            if size(Faces,2)==1
                patchVertices=[patchVertices;obj.MesherStruct.Mesh.p(:,Faces)'];%#ok<AGROW>
                patchFaces=[patchFaces;[1,2,3]+(m-1)*3];%#ok<AGROW>
            else
                commonedge=intersect(Faces(:,1),Faces(:,2));
                otherpoints=setxor(Faces(:,1),Faces(:,2));
                Faces=[otherpoints(1);commonedge;otherpoints(2)];
                patchVertices=[patchVertices;obj.MesherStruct.Mesh.p(:,Faces)'];%#ok<AGROW>
                patchFaces=[patchFaces;[1,2,3;2,3,4]+(m-1)*4];%#ok<AGROW>
            end
        end
        FP.Vertices=patchVertices;
        FP.Faces=patchFaces;
        FP.FaceColor=[0,0,255]/255;
        FP.EdgeColor='black';
        FP.LineWidth=1;
        obj.MesherStruct.LoadPatch=FP;
    end


    if~all(loadedge==0)
        ZL=zeros(1,numel(Imp));
        for m=1:numel(Imp)
            if all(frq{m}==0)&&isscalar(Imp{m})
                ZL(m)=Imp{m};
            elseif isscalar(frq{m})&&isscalar(Imp{m})
                Imp1=[0,Imp{m},0];
                Frq1=[frq{m}-1,frq{m},frq{m}+1];
                ZL(m)=interp1(Frq1,Imp1,frequency);
            else
                if any(imag(Imp{m}))
                    ZL_r=interp1(frq{m},real(Imp{m}),frequency);
                    ZL_i=interp1(frq{m},imag(Imp{m}),frequency);
                    ZL(m)=complex(ZL_r,ZL_i);
                else
                    if frq{m}>0
                        ZL(m)=interp1(frq{m},Imp{m},frequency);
                    else
                        ZL(m)=Imp{m}(1);
                    end
                end
            end
        end
        if any(isnan(ZL))
            if~isempty(hwait)
                delete(hwait);
            end
            error(message('antenna:antennaerrors:IncorrectLoad'));
        end
    end


    if addtermination

        feededge=obj.SolverStruct.RWG.feededge;
        terminatingedge=reshape(feededge,1,numel(feededge));
        if all(loadedge==0)
            loadedge=terminatingedge;
            index=loadedge==0;
            loadedge(index)=[];
            ZL=Zterm*size(feededge,1)*ones(size(loadedge));
            if strcmpi(obj.MesherStruct.Mesh.FeedType,'doubleedge')
                ZL=ZL*2;
            end
        else
            [~,index]=intersect(loadedge,feededge);
            if isempty(index)
                loadedge=repmat(loadedge,size(feededge,1),1);
                loadedge=[loadedge,feededge];
                loadedge=unique(loadedge(:),'rows','stable')';


                Zval=Zterm*size(feededge,1)*ones(1,numel(terminatingedge));
                if strcmpi(obj.MesherStruct.Mesh.FeedType,'doubleedge')
                    Zval=Zval*2;
                end
                ZL=[ZL,Zval];
            else
                if strcmpi(obj.MesherStruct.Mesh.FeedType,'doubleedge')
                    Zterm=Zterm*2;
                end
                ZL(index)=ZL(index)+Zterm;
            end
        end

    else
        if all(loadedge==0)
            ZL=50;
        end
    end
end
