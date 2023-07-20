function psb=nscinet(psb)









    noeuds=[psb.rlc;psb.source];
    if isempty(noeuds)
        return
    end
    noeuds=noeuds(:,1:2);

    liste=[-123456];
    nores=[];
    indres=1;
    newneu=[];

    for i=1:size(noeuds,1)
        if isempty(find(noeuds(i,1)==liste))&isempty(find(noeuds(i,2)==liste))
            if i==1,liste=[];
            end
            ww=noeuds(i,:);
            wwold=[];
            while length(ww)>length(wwold)
                wwold=ww;
                for j=1:size(noeuds,1)

                    if~isempty(find(ww==noeuds(j,1)))

                        if isempty(find(ww==noeuds(j,2)))

                            ww=[ww,noeuds(j,2)];
                        end
                    end

                    if~isempty(find(ww==noeuds(j,2)))

                        if isempty(find(ww==noeuds(j,1)))

                            ww=[ww,noeuds(j,1)];
                        end
                    end
                end
            end
            liste=[liste,ww];
            nores=[nores,indres*ones(1,length(ww))];
            indres=indres+1;
            ww=[];
        end
    end
    nbrres=indres-1;


    for i=1:size(psb.VoltNodes,1)
        n1=psb.VoltNodes(i,1);
        n2=psb.VoltNodes(i,2);
        n1group=nores(find(n1==liste));
        n2group=nores(find(n2==liste));
        if~iscell(psb.measurenames)
            psb.measurenames={psb.measurenames};
        end
        if isempty(n1group)||isempty(n2group)||all(n1group~=n2group)
            nom=psb.measurenames{i};
            if n1==0||n2==0
                message=['The Voltage Measurement block ''',nom,''' is connected between two isolated networks. For a valid measurement, the positive and negative terminals of the block must be connected to electrical nodes that are part of the same electrical circuit. Also check if the ground reference node is defined for that circuit.'];
            else
                message=['The Voltage Measurement block ''',nom,''' is connected between two isolated networks. For a valid measurement, the positive and negative terminals of the block must be connected to electrical nodes that are part of the same electrical circuit.'];
            end
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:MeasurementBlock:ConnectionError';
            psberror(Erreur);
        end
    end

    mainres=find(nores==1);


    for i=2:nbrres

        subres=find(nores==i);
        node1=liste(mainres(1));
        node2=liste(subres(1));

        if~isempty(psb.source)


            hasCurrentSource1=0;
            [x,y]=find(psb.source(:,1:2)==node1);
            if~isempty(x)
                if any(psb.source(unique(x),3))
                    hasCurrentSource1=1;
                end
            end

            if hasCurrentSource1
                if~isempty(psb.rlc)
                    idx1=find(~psb.rlc(:,5));
                    if~isempty(idx1)
                        xx=psb.rlc(idx1,1:2);
                        if ismember(node1,xx(:));
                            hasCurrentSource1=0;
                        end
                    end
                end
            end


            hasCurrentSource2=0;
            [x,y]=find(psb.source(:,1:2)==node2);
            if~isempty(x)
                if any(psb.source(unique(x),3))
                    hasCurrentSource2=1;
                end
            end

            if hasCurrentSource2
                if~isempty(psb.rlc)
                    idx1=find(~psb.rlc(:,5));
                    if~isempty(idx1)
                        xx=psb.rlc(idx1,1:2);
                        if ismember(node2,xx(:));
                            hasCurrentSource2=0;
                        end
                    end
                end
            end









            sit=(~hasCurrentSource1&~hasCurrentSource2)+...
            (hasCurrentSource1&~hasCurrentSource2)*2+...
            (~hasCurrentSource1&hasCurrentSource2)*3+...
            (hasCurrentSource1&hasCurrentSource2)*4;

            switch sit
            case 2

                if~isempty(psb.rlc)

                    idx1=ismember(psb.rlc(:,1:2),liste(subres));
                    x=find(idx1(:,1).*idx1(:,2));


                    idx1=find(~psb.rlc(x,5));
                    if~isempty(idx1)
                        node2=psb.rlc(x(idx1(1)),1);
                    else
                        x=find(~psb.source(:,3));
                        idx1=ismember(psb.source(x,1:2),liste(subres));
                        idx1=idx1(:,1).*idx1(:,2);
                        idx1=x(find(idx1));

                        if~isempty(idx1)
                            node2=psb.source(idx1(1),1);
                        end

                    end
                end
            case 3

                if~isempty(psb.rlc)

                    idx1=ismember(psb.rlc(:,1:2),liste(mainres));
                    x=find(idx1(:,1).*idx1(:,2));


                    idx1=find(~psb.rlc(x,5));
                    if~isempty(idx1)
                        node1=psb.rlc(x(idx1(1)),1);
                    else
                        x=find(~psb.source(:,3));
                        idx1=ismember(psb.source(x,1:2),liste(mainres));
                        idx1=idx1(:,1).*idx1(:,2);
                        idx1=x(find(idx1));

                        if~isempty(idx1)
                            node1=psb.source(idx1(1),1);
                        end

                    end
                end
            end

        end


        R=10;
        si=size(psb.rlc,1)+1;
        psb.rlc=[psb.rlc;node1,node2,0,R,0,0,si];

    end