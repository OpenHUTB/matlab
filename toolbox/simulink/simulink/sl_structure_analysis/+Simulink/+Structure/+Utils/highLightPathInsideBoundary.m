



function[opC,ipC,artificialLoop]=highLightPathInsideBoundary(rootInNode,rootOutNode,ownerSub,passD)



    global subToDE;

    import Simulink.Structure.Utils.*

    IsArtificial=0;

    opC={};
    ipC={};

    op=[];
    ip=[];

    artificialLoop={};



    hSub=get_param(ownerSub,'handle');

    if passD
        [DE,ports,nI,nO,~]=createDE(ownerSub,passD);
    elseif~subToDE.isKey(hSub)
        [DE,ports,nI,nO,~]=createDE(ownerSub,passD);
        subToDE(hSub)={DE,ports,nI,nO};
    else
        c=subToDE(hSub);
        DE=c{1};
        ports=c{2};
        nI=c{3};
        nO=c{4};
    end

    startIdx=-1;
    endIdx=-1;
    for m=1:length(ports)
        if rootInNode==ports(m)
            startIdx=m;
        end
        if rootOutNode==ports(m)
            endIdx=m;
        end
    end

    if(startIdx==-1||endIdx==-1)
        return;
    end


    pathRegion=allPathRegion(DE,startIdx,endIdx);

    ownerSubObj=get_param(ownerSub,'Object');
    if(isempty(pathRegion)&&(isSubsystemNonVirtual(ownerSubObj)||isNormalModeModelRef(ownerSubObj)))

        if passD==1
            passD=0;



            opSub={};
            ipSub={};
            isArtifical=2;
            artificialLoop{end+1}=IsArtificial;
        else
            passD=1;


            [opSub,ipSub,artificialLoop]=highLightPathInsideBoundary(rootInNode,rootOutNode,ownerSub,passD);
            opC{end+1}=opSub;
            ipC{end+1}=ipSub;
            IsArtificial=1;


            artificialLoop{end}=IsArtificial;
        end
    else

        passD=0;
        [m,n]=size(pathRegion);

        nPorts=0;




        [k,j,~]=find(pathRegion(nI+1:nI+nO,1:nI));
        op=ports(k+nI);
        ip=ports(j);

        if IsArtificial>0



            IsArtificial=0;


        end




        n=length(ip);

        opC{1}=op;
        ipC{1}=ip;
        artificialLoop{1}=IsArtificial;

        for jj=1:n
            ownerSubSub=get_param(ip(jj),'Parent');
            so=get_param(ownerSubSub,'Object');



            if isNormalModeModelRef(so)||isSubsystemNonVirtual(so)
                allBlks=get_param(op,'Parent');
                for kk=1:length(allBlks)
                    if(strcmp(allBlks(kk),ownerSubSub))

                        outport=op(kk);
                        rootInNode=getInsidePort(ip(jj));
                        rootOutNode=getInsidePort(outport);
                        passD=0;

                        [opSub,ipSub,IsArtificial]=...
                        highLightPathInsideBoundary(rootInNode,...
                        rootOutNode,ownerSubSub,passD);
                        opC{end+1}=opSub;
                        ipC{end+1}=ipSub;
                        artificialLoop{end+1}=IsArtificial;
                    end
                end
            end
        end
    end

end
