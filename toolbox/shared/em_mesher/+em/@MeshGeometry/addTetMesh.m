function addTetMesh(obj,meshControlOptions)

    [~,subname]=getSubstrateinfo(obj);
    if isscalar(subname)
        if~isempty(obj.MesherStruct.Mesh.T)
            warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
            TetObj=triangulation(obj.MesherStruct.Mesh.T',obj.MesherStruct.Mesh.p');
            warning(warnState);
            if any(strcmpi(meshControlOptions.View,{'dielectric volume','all'}))
                hold on
                tetramesh(TetObj,'FaceColor',[0.1,0.7,0.5],...
                'FaceAlpha',0.2,'tag','dielectric volume');
                axis equal;title('Dielectric volume');
                hold off
            elseif any(strcmpi(meshControlOptions.View,{'dielectric surface'}))
                [FBtri,FBpoints]=freeBoundary(TetObj);
                hold on;
                trisurf(FBtri,FBpoints(:,1),FBpoints(:,2),FBpoints(:,3),...
                'FaceColor',[0.1,0.7,0.5],'FaceAlpha',0.95,...
                'tag','dielectric surface');
                axis equal;title('Dielectric surface');
                hold off;
            end
        else
            if any(strcmpi(meshControlOptions.View,{'dielectric volume','dielectric surface'}))
                return;
            end
        end


    else
        if~iscell(subname)&&~isempty(subname)
            subname=cellstr(subname);
        end

        if~isempty(obj.MesherStruct.Mesh.T)
            [TetColor,TetsInLayer]=TetLayerInfo(obj.MesherStruct.Mesh.Eps_r,...
            obj.MesherStruct.infGP);
            if obj.MesherStruct.infGP
                idx=strcmpi(subname,{'Air'});
                subname(idx)=[];
                subname1=cell(1,2*numel(subname)-1);
                mid_layer=round(size(TetColor,1)/2);
                subname1(mid_layer:end)=subname;
                subname1(1:mid_layer-1)=subname(end:-1:2);
                subname=subname1;
            end









            hold on;
            for m=1:size(TetColor,1)
                T=obj.MesherStruct.Mesh.T';
                P=obj.MesherStruct.Mesh.p';
                idxGnd=find(P(:,3)==0);
                offset=max(P(:,3))*1e-3;
                P(:,3)=P(:,3)-offset;
                P(idxGnd,3)=P(idxGnd,3)+4*offset;
                start=TetsInLayer(m);
                stop=TetsInLayer(m+1);
                if m~=1
                    start=start+1;
                end
                if any(strcmpi(meshControlOptions.View,{'dielectric volume','all'}))
                    plottetmesh(T(start:stop,:).',P.',TetColor(m,:),0.2,...
                    subname{m},0);
                elseif any(strcmpi(meshControlOptions.View,{'dielectric surface'}))
                    plottetmesh(T(start:stop,:).',P.',TetColor(m,:),1,...
                    subname{m},0);
                end

            end
            axis equal;
            hold off;
            if any(strcmpi(meshControlOptions.View,{'dielectric volume'}))
                title('Dielectric volume');
            elseif any(strcmpi(meshControlOptions.View,{'dielectric surface'}))
                title('Dielectric surface');
            else
                title('Metal-Dielectric');
            end
        end
    end

end


function[TetColor,TetsInLayer]=TetLayerInfo(epsr,infGP)

    eps_vals=unique(epsr,'stable');
    numColors=numel(eps_vals);
    TetsInLayer=find(diff(epsr));
    TetsInLayer=[TetsInLayer,numel(epsr)];
    LayerEpsr=epsr(TetsInLayer);
    TetsInLayer=[1,TetsInLayer];

    deltaG=(0.7-0.1)/numColors;
    colors=(0:numColors-1)*deltaG;
    colorval=0.7-colors;

    TetColor=zeros(numel(LayerEpsr),3);
    TetColor(:,1)=0.1;
    TetColor(:,3)=0.5;

    if~infGP
        for m=1:numColors
            idx=find(LayerEpsr==eps_vals(m));
            TetColor(idx,2)=colorval(m);%#ok<FNDSB>
        end
    else
        mid_layer=round(numel(LayerEpsr)/2);
        TetColor(mid_layer,2)=colorval(1);
        for m=2:numColors
            idx=find(LayerEpsr==eps_vals(mid_layer-m+1));
            TetColor(idx,2)=colorval(m);%#ok<FNDSB>
        end


    end
end


















function plottetmesh(T,P,TetColor,facealpha,subname,option)

    if option
        X=reshape(P(1,T(1:4,:)),[4,size(T,2)]);
        Y=reshape(P(2,T(1:4,:)),[4,size(T,2)]);
        Z=reshape(P(3,T(1:4,:)),[4,size(T,2)]);
        htet=fill3(X,Y,Z,TetColor,'FaceAlpha',facealpha,'tag','dielectric');
    else
        htet=tetramesh(T',P','FaceColor',TetColor,...
        'FaceAlpha',facealpha,'tag','dielectric');
    end

    hAnnotation=get(htet,'Annotation');
    for n=2:numel(hAnnotation)
        hLegendEntry=get(hAnnotation{n},'LegendInformation');
        set(hLegendEntry,'IconDisplayStyle','off');
    end
    htet(1).FaceAlpha=0.8;
    set(htet(1),'DisplayName',subname,'Tag','substrate');

end
