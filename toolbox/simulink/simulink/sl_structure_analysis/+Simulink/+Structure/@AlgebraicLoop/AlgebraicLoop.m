classdef AlgebraicLoop<handle



    properties(SetAccess=private)
Model
Id
VariableBlockHandles
BlockHandles
IsArtificial
    end

    properties(SetAccess=private,Hidden=true)
nCycles
hAlgLoopSub
hloopOutports
hloopInports
nAtomicUnits
isArtificialCycle
hstyle
hSegments
hAllBlocks










isGraphicalLoop
    end

    methods



        function algLoop=AlgebraicLoop(model,hAlgLoopSub)

            import Simulink.Structure.Utils.*;

            global subToDE;

            subToDE=containers.Map('KeyType','double','ValueType','any');

            oAlgLoopSub=get_param(hAlgLoopSub,'Object');

            algLoop.Model=model;

            algLoop.hAlgLoopSub=hAlgLoopSub;
            algLoop.Id(1)=oAlgLoopSub.getSystemIndex;
            algLoop.Id(2)=oAlgLoopSub.getAlgebraicLoopId;

            algLoop.BlockHandles=oAlgLoopSub.getSortedList;

            algLoop.hSegments={};
            algLoop.hAllBlocks={};

            algLoop.hstyle=[];
            algLoop.isGraphicalLoop=1;

            n=length(algLoop.BlockHandles);

            hB=[];

            for i=1:n
                oblk=get_param(algLoop.BlockHandles(i),'Object');
                if oblk.isAlgVarAssignedTo
                    hB=[hB,algLoop.BlockHandles(i)];
                end
            end

            algLoop.VariableBlockHandles=getGGTopoBlocks(hB);
            algLoop.BlockHandles=getGGTopoBlocks(algLoop.BlockHandles);

            passD=0;





            [DE,ports,nI,nO,startNodeIdx,blks]=...
            createTopLoopGraph(hAlgLoopSub,passD);


            DEOut=findSCC(DE);

            nC=length(DEOut);

            algLoop.nCycles=nC;

            if(nC<1)

                algLoop.isGraphicalLoop=0;
            end

            for k=1:nC

                SCC=DEOut{k};





                cycle=SCC(nI+1:nI+nO,1:nI);

                artiC={0};
                opC={};
                ipC={};



                [opIdx,ipIdx]=find(cycle);


                opIdx=opIdx+nI;


                opk=ports(opIdx);
                ipk=ports(ipIdx);


                opC{1}={opk};
                ipC{1}={ipk};



                n=length(ipk);
                DE_k=DEOut{k};



                NonSubInuputIdx=[];

                for kIdx=1:n

                    iPort=ipk(kIdx);

                    ownerSub=get_param(iPort,'Parent');

                    so=get_param(ownerSub,'Object');

                    if~(isSubsystemNonVirtual(so)||isNormalModeModelRef(so))
                        NonSubInuputIdx(end+1)=ipIdx(kIdx);
                    end
                end



                DE_k(NonSubInuputIdx,:)=0;
                DE_k(:,NonSubInuputIdx)=0;



                Dk=DE_k(1:nI,nI+1:nI+nO);


                [rootInIdx,rootOutIdx]=find(Dk);


                nAtomatic=length(rootInIdx);

                for nSub=1:nAtomatic

                    iPort=ports(rootInIdx(nSub));
                    oPort=ports(rootOutIdx(nSub)+nI);


                    rootInNode=getInsidePort(iPort);
                    rootOutNode=getInsidePort(oPort);
                    ownerSub=get_param(iPort,'Parent');

                    [opSub,ipSub,arti]=highLightPathInsideBoundary(rootInNode,rootOutNode,ownerSub,passD);

                    opC{end+1}=opSub;
                    ipC{end+1}=ipSub;
                    artiC{end+1}=arti;
                end

                algLoop.hloopOutports{k}=opC;
                algLoop.hloopInports{k}=ipC;

                while~isempty(find(cellfun(@iscell,artiC),1))
                    artiC=horzcat(artiC{:});
                end
                artiC=cell2mat(artiC);
                algLoop.nAtomicUnits(k)=length(opC)-1;
                algLoop.isArtificialCycle(k)=~isempty(find(artiC(2:end)>0,1));
            end

            aCycle=algLoop.isArtificialCycle;

            algLoop.IsArtificial=isempty(find(aCycle==0,1));

            clearvars -global subToDE;
        end



    end
end

































































