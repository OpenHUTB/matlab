classdef Circuit



















    properties
CktNodes
DriveNodes
InPorts
OutPorts
LastCkt
LastDrv
LastInPort
LastOutPort
Yc
Yv
Ycsym
Yvsym
FScale

Numerator
Denominator
    end

    methods
        function obj=Circuit(m,n,p,q)





            obj.CktNodes=cell(1,n);
            obj.DriveNodes=cell(1,m);
            obj.InPorts=cell(1,p);
            obj.OutPorts=cell(1,q);
            obj.LastCkt=0;
            obj.LastDrv=0;
            obj.LastInPort=0;
            obj.LastOutPort=0;
            obj.FScale=1;
            obj.Numerator=[];
            obj.Denominator=[];
            matdrv=zeros(n,m,1);
            obj.Yv=msblks.utilities.PolyMat(matdrv);
            matckt=zeros(n,n,1);
            obj.Yc=msblks.utilities.PolyMat(matckt);
            obj.Ycsym=[];
            obj.Yvsym=[];
        end

        function obj=addSymbolic(obj,base,indexarray)

            [n,m]=size(obj.Yv);
            nndx=size(indexarray,2);
            valarray=cell(n,m);
            valarray(:,:)={zeros(1,nndx+1)};
            obj.Yvsym=msblks.utilities.VariMat(base,valarray,indexarray);
            valarray=cell(n,n);
            valarray(:,:)={zeros(1,nndx+1)};
            obj.Ycsym=msblks.utilities.VariMat(base,valarray,indexarray);
        end

        function[drvmatrix,cktmatrix]=evaluateSymbolicMatrices(obj)


            drvmatrix=obj.Yvsym.evaluateToMatrix(true);
            cktmatrix=obj.Ycsym.evaluateToMatrix(true);
        end

        function obj=setNode(obj,number,name,type)










            if number<=0
                return;
            end
            node.Number=number;
            node.Name=name;
            node.Type=type;
            node.Poles=msblks.utilities.PolyMat(1);
            [~,n]=size(obj.CktNodes);
            [~,m]=size(obj.DriveNodes);
            switch type
            case 0
                if obj.LastCkt<n
                    obj.LastCkt=obj.LastCkt+1;
                    node.TypeIndex=obj.LastCkt;
                    obj.CktNodes{obj.LastCkt}=node;
                else
                    error('Not enough circuit nodes specified.');
                end
            case 3
                if obj.LastDrv<m
                    obj.LastDrv=obj.LastDrv+1;
                    node.TypeIndex=obj.LastDrv;
                    obj.DriveNodes{obj.LastDrv}=node;
                else
                    error('Not enough drive nodes specified.');
                end
            case 4
                if obj.LastDrv<m
                    obj.LastDrv=obj.LastDrv+1;
                    node.TypeIndex=obj.LastDrv;
                    obj.DriveNodes{obj.LastDrv}=node;
                else
                    error('Not enough drive nodes specified.');
                end
            case 2
                if obj.LastCkt<n
                    obj.LastCkt=obj.LastCkt+1;
                    node.TypeIndex=obj.LastCkt;
                    obj.CktNodes{obj.LastCkt}=node;
                else
                    error('Not enough circuit nodes specified.');
                end
            case 1
                if obj.LastCkt<n
                    obj.LastCkt=obj.LastCkt+1;
                    node.TypeIndex=obj.LastCkt;
                    obj.CktNodes{obj.LastCkt}=node;
                else
                    error('Not enough circuit nodes specified.');
                end
            otherwise
                error(['Unrecognized node type: ',type]);
            end

        end

        function node=getNode(obj,number)











            if number<=0
                node=[];
                return;
            end
            if obj.LastCkt>0
                for indx=1:obj.LastCkt
                    node=obj.CktNodes{indx};
                    if node.Number==number
                        return;
                    end
                end
            end
            if obj.LastDrv>0
                for indx=1:obj.LastDrv
                    node=obj.DriveNodes{indx};
                    if node.Number==number
                        return;
                    end
                end
            end
            node=[];
        end

        function obj=addElement(obj,type,nodes,value)































            symbolicmode=false;
            one=msblks.utilities.PolyMat(1);
            [nr,nv]=size(value);
            if nr==0||nv==0
                error('Circuit element has no value.');
            end
            if isa(value,'msblks.utilities.VariMat')
                symbolicmode=true;

                onenum=polyMatToVariMat(one,value.Base,value.IndexArray);

                if nv>1||nr>1

                    num=value(1,1);




                    if nr>1
                        denmat=evaluateToMatrix(value(2,1),true);
                        den=msblks.utilities.PolyMat(denmat);
                    else
                        den=one;
                    end
                else
                    num=value;
                    den=one;
                end
            else

                onenum=one;

                indx=1;
                while indx<nv&&value(1,indx)==0
                    indx=indx+1;
                end
                num=msblks.utilities.PolyMat(reshape(value(1,indx:end),1,1,nv-indx+1));
                if nr>1
                    indx=1;
                    while indx<nv&&value(2,indx)==0
                        indx=indx+1;
                    end
                    den=msblks.utilities.PolyMat(reshape(value(2,indx:end),1,1,nv-indx+1));
                else
                    den=one;
                end
            end

            if isempty(nodes)
                error(['Circuit element ',type,' not connected.']);
            end
            nd2=zeros(1,2);
            nd4=zeros(1,4);
            [~,nn]=size(nodes);
            for indx=1:nn
                if indx<=2
                    nd2(indx)=nodes(indx);
                end
                if indx<=4
                    nd4(indx)=nodes(indx);
                end
            end
            switch type
            case 7
                if symbolicmode
                    valcell=value.ValArray;
                    valarray=valcell{1,1};
                    if any(valarray(1,2:end))



                    elseif valarray(1,1)>0
                        valarray(1,1)=1/valarray(1,1);
                    else
                        error(['Invalid resistance value ',num2str(value(1)),'.']);
                    end
                    valcell=cell(1);
                    valcell{1}=valarray;
                    tmpval=msblks.utilities.VariMat(value.Base,valcell,value.IndexArray);
                else
                    if value(1)>0
                        tmpval=msblks.utilities.PolyMat(1/value(1));
                    else
                        error(['Invalid resistance value ',num2str(value(1)),'.']);
                    end
                end
                obj=obj.addToCktEquations(nd2,tmpval,one);
                tmp=nd2(1);
                nd2(1)=nd2(2);
                nd2(2)=tmp;
                obj=obj.addToCktEquations(nd2,tmpval,one);

            case 8
                if symbolicmode
                    valcell=value.ValArray;
                    valarray=valcell{1,1};


                    valarray(1,2)=1;
                    valcell=cell(1);
                    valcell{1}=valarray;
                    tmpval=msblks.utilities.VariMat(value.Base,valcell,value.IndexArray);
                else
                    matin=zeros(1,1,2);
                    matin(1,1,1)=value(1);
                    tmpval=msblks.utilities.PolyMat(matin);
                end
                obj=obj.addToCktEquations(nd2,tmpval,one);
                tmp=nd2(1);
                nd2(1)=nd2(2);
                nd2(2)=tmp;
                obj=obj.addToCktEquations(nd2,tmpval,one);
            case 9
                node1=obj.getNode(nd4(1));
                node2=obj.getNode(nd4(2));
                node3=obj.getNode(nd4(3));

                if symbolicmode
                    valcell=value.ValArray;
                    valarray=valcell{1,1};

                    valarray(1,1)=-valarray(1,1);


                    valarray(1,2)=1;
                    valcell=cell(1);
                    valcell{1}=valarray;
                    tmpval=msblks.utilities.VariMat(value.Base,valcell,value.IndexArray);
                else
                    if value(1)>0
                        matin=zeros(1,1,2);
                        matin(1,1,1)=-value(1);
                        tmpval=msblks.utilities.PolyMat(matin);
                    else
                        error(['Invalid inductance value ',num2str(value(1)),'.']);
                    end
                end
                if~isempty(node3)
                    if node3.Type~=1
                        error('Inductor current node is not a state current node.');
                    end
                    nstate=node3.TypeIndex;
                    obj=obj.addToNode(true,nstate,nstate,tmpval,one);
                else
                    error(['Missing state current node for inductor current between nodes '...
                    ,num2str(nd4(1)),' and ',num2str(nd4(2)),'.']);
                end
                if~isempty(node1)
                    ncol=node1.TypeIndex;
                    obj=obj.addToNode((node1.Type==0),...
                    nstate,ncol,onenum,one);

                    if node1.Type==0
                        nrow=ncol;
                        obj=obj.addToNode(true,nrow,nstate,-onenum,one);
                    end
                end
                if~isempty(node2)
                    ncol=node2.TypeIndex;
                    obj=obj.addToNode((node2.Type==0),...
                    nstate,ncol,-onenum,one);

                    if node2.Type==0
                        nrow=ncol;
                        obj=obj.addToNode(true,nrow,nstate,onenum,one);
                    end
                end
            case 10
                node1=obj.getNode(nd2(1));
                node2=obj.getNode(nd2(2));

                if symbolicmode
                    valcell=value.ValArray;
                    valarray=valcell{1,1};

                    valarray(1,1)=-valarray(1,1);


                    valarray(1,2)=1;
                    valcell=cell(1);
                    valcell{1}=valarray;
                    tmpval=msblks.utilities.VariMat(value.Base,valcell,value.IndexArray);
                else
                    matin=zeros(1,1,2);
                    matin(1,1,1)=-value(1);
                    tmpval=msblks.utilities.PolyMat(matin);
                end
                if~isempty(node1)&&node1.Type==1&&...
                    ~isempty(node2)&&node2.Type==1
                    n1=node1.TypeIndex;
                    n2=node2.TypeIndex;
                    obj=obj.addToNode(true,n1,n2,tmpval,one);
                    obj=obj.addToNode(true,n2,n1,tmpval,one);
                end
            case 11

                node1=obj.getNode(nd4(1));
                node2=obj.getNode(nd4(2));
                node3=obj.getNode(nd4(3));
                node4=obj.getNode(nd4(4));
                node5=obj.getNode(nodes(5));
                if isempty(node3)&&isempty(node4)
                    error('Input of voltage controlled voltage source not connected.');
                end
                if~isempty(node5)

                    if node5.Type~=2
                        error('Output of voltage controlled current source not connected to circuit node.');
                    end
                    nrow=node5.TypeIndex;
                    if~isempty(node1)
                        obj=obj.addToNode((node1.Type==0),...
                        nrow,node1.TypeIndex,-onenum,one);
                    end
                    if~isempty(node2)
                        obj=obj.addToNode((node2.Type==0),...
                        nrow,node2.TypeIndex,onenum,one);
                    end
                    if~isempty(node3)
                        obj=obj.addToNode((node3.Type==0),...
                        nrow,node3.TypeIndex,num,den);
                    end
                    if~isempty(node4)
                        obj=obj.addToNode((node4.Type==0),...
                        nrow,node4.TypeIndex,-num,den);
                    end

                    ncol=nrow;
                    if~isempty(node1)&&node1.Type==0
                        obj=obj.addToNode(true,node1.TypeIndex,ncol,-onenum,one);
                    end
                    if~isempty(node2)&&node2.Type==0
                        obj=obj.addToNode(true,node2.TypeIndex,ncol,onenum,one);
                    end
                else
                    error('Control current node of voltage controlled voltage source not defined.');
                end
            case 12
                node1=obj.getNode(nd4(1));
                node2=obj.getNode(nd4(2));
                node3=obj.getNode(nd4(3));
                if~isempty(node3)&&(node3.Type==2||node2.Type==4)
                    ncol=node3.TypeIndex;
                    if~isempty(node1)&&node1.Type==0
                        obj=obj.addToNode((node3.Type==2),...
                        node1.TypeIndex,ncol,-num,den);
                    end
                    if~isempty(node2)&&node2.Type==0
                        obj=obj.addToNode((node3.Type==2),...
                        node2.TypeIndex,ncol,num,den);
                    end
                else
                    error('Current controlled current source not connected to control current.');
                end
            case 13
                node1=obj.getNode(nd4(1));
                node2=obj.getNode(nd4(2));
                node3=obj.getNode(nd4(3));
                node4=obj.getNode(nd4(4));
                if isempty(node1)&&isempty(node2)
                    error('Output of voltage controlled current source not connected.');
                end
                if isempty(node3)&&isempty(node4)
                    error('Input of voltage controlled current source not connected.');
                end
                if~isempty(node1)
                    if node1.Type~=0
                        error('Output of voltage controlled current source not connected to circuit node.');
                    end
                    nrow=node1.TypeIndex;
                    if~isempty(node3)
                        obj=obj.addToNode((node3.Type==0),...
                        nrow,node3.TypeIndex,-num,den);
                    end
                    if~isempty(node4)
                        obj=obj.addToNode((node4.Type==0),...
                        nrow,node4.TypeIndex,num,den);
                    end
                end
                if~isempty(node2)
                    if node2.Type~=0
                        error('Output of voltage controlled current source not connected to circuit node.');
                    end
                    nrow=node2.TypeIndex;
                    if~isempty(node3)
                        obj=obj.addToNode((node3.Type==0),...
                        nrow,node3.TypeIndex,num,den);
                    end
                    if~isempty(node4)
                        obj=obj.addToNode((node4.Type==0),...
                        nrow,node4.TypeIndex,-num,den);
                    end
                end
            case 14
                node1=obj.getNode(nd4(1));
                node2=obj.getNode(nd4(2));
                node3=obj.getNode(nd4(3));
                node4=obj.getNode(nd4(4));
                if~isempty(node4)&&node4.Type==2

                    nrow=node4.TypeIndex;
                    if~isempty(node1)
                        obj=obj.addToNode((node1.Type==0),...
                        nrow,node1.TypeIndex,-onenum,one);
                    end
                    if~isempty(node2)
                        obj=obj.addToNode((node2.Type==0),...
                        nrow,node2.TypeIndex,onenum,one);
                    end
                    if~isempty(node3)&&node3.Type==2
                        obj=obj.addToNode(true,nrow,nrow,num,den);
                    else
                        error('Current controlled voltage source not connected to a control current.');
                    end

                    ncol=nrow;
                    if~isempty(node1)&&node1.Type==0
                        obj=obj.addToNode(true,node1.TypeIndex,ncol,-onenum,one);
                    end
                    if~isempty(node2)&&node2.Type==0
                        obj=obj.addToNode(true,node2.TypeIndex,ncol,onenum,one);
                    end
                end
            case 15




                node1=obj.getNode(nd2(1));
                node2=obj.getNode(nd2(2));
                node3=obj.getNode(nd4(3));
                if isempty(node3)||node3.Type~=4
                    error('Driven node for independent current source is not correct.');
                end
                ncol=node3.TypeIndex;
                if~isempty(node1)
                    if node1.Type==0
                        obj=obj.addToNode(false,node1.TypeIndex,ncol,onenum,one);
                    else
                        error(['Current source connected to driven node ',node1.Name]);
                    end
                end
                if~isempty(node2)
                    if node2.Type==0
                        obj=obj.addToNode(false,node2.TypeIndex,ncol,-onenum,one);
                    else
                        error(['Current source connected to driven node ',node2.Name]);
                    end
                end
            case 16





                node1=obj.getNode(nd2(1));
                node2=obj.getNode(nd2(2));
                node3=obj.getNode(nd4(3));
                node4=obj.getNode(nd4(4));
                if isempty(node4)||node4.Type~=3
                    error('Driven node for independent voltage source is not correct.');
                end
                if~isempty(node3)&&node3.Type==2

                    nrow=node3.TypeIndex;
                    if~isempty(node4)&&node4.Type==3
                        obj=obj.addToNode(false,nrow,node4.TypeIndex,-onenum,one);
                    end


                    ncol=nrow;
                    if~isempty(node1)&&node1.Type==0
                        obj=obj.addToNode(true,nrow,node1.TypeIndex,onenum,one);
                        obj=obj.addToNode(true,node1.TypeIndex,ncol,-onenum,one);
                    end
                    if~isempty(node2)&&node2.Type==0
                        obj=obj.addToNode(true,nrow,node2.TypeIndex,-onenum,one);
                        obj=obj.addToNode(true,node2.TypeIndex,ncol,onenum,one);
                    end



                end
            otherwise
                error(['Unsupported circuit element',type]);
            end
        end

        function obj=addToCktEquations(obj,nodes,numerator,denominator)




            node1=obj.getNode(nodes(1));
            node2=obj.getNode(nodes(2));
            if~isempty(node1)&&node1.Type==0
                n1=node1.TypeIndex;
                obj=obj.addToNode(true,n1,n1,-numerator,denominator);
                if~isempty(node2)
                    n2=node2.TypeIndex;
                    switch node2.Type
                    case 0
                        obj=obj.addToNode(true,n1,n2,numerator,denominator);
                    case 3
                        obj=obj.addToNode(false,n1,n2,numerator,denominator);
                    case 4
                        obj=obj.addToNode(false,n1,n2,msblks.utilities.PolyMat(1),msblks.utilities.PolyMat(1));
                    otherwise
                    end
                end
            end
        end

        function obj=addToNode(obj,isCircuitNode,row,col,numerator,denominator)




















            if row<=0||col<=0

                return;
            end
            poles=obj.CktNodes{row}.Poles;
            [q,dividesEvenly]=dividePoly(poles,denominator);

            if isa(numerator,'msblks.utilities.VariMat')
                if dividesEvenly
                    qvar=polyMatToVariMat(q,numerator.Base,numerator.IndexArray);
                    if isCircuitNode
                        obj.Ycsym(row,col)=obj.Ycsym(row,col)+numerator*qvar;
                    else
                        obj.Yvsym(row,col)=obj.Yvsym(row,col)+numerator*qvar;
                    end
                else
                    denvar=polyMatToVariMat(denominator,numerator.Base,numerator.IndexArray);
                    polevar=polyMatToVariMat(poles,numerator.Base,numerator.IndexArray);
                    [~,nc]=size(obj.Ycsym);
                    for indx=1:nc
                        obj.Ycsym(row,indx)=obj.Ycsym(row,indx)*denvar;
                    end
                    [~,nc]=size(obj.Yvsym);
                    for indx=1:nc
                        obj.Yvsym(row,indx)=obj.Yvsym(row,indx)*denvar;
                    end
                    if isCircuitNode
                        obj.Ycsym(row,col)=obj.Ycsym(row,col)+numerator*polevar;
                    else
                        obj.Yvsym(row,col)=obj.Yvsym(row,col)+numerator*polevar;
                    end
                    obj.CktNodes{row}.Poles=obj.CktNodes{row}.Poles*denominator;

                end
            else
                if dividesEvenly
                    if isCircuitNode
                        obj.Yc(row,col)=obj.Yc(row,col)+numerator*q;
                    else
                        obj.Yv(row,col)=obj.Yv(row,col)+numerator*q;
                    end
                else
                    obj.Yc(row,:)=obj.Yc(row,:)*denominator;
                    obj.Yv(row,:)=obj.Yv(row,:)*denominator;
                    if isCircuitNode
                        obj.Yc(row,col)=obj.Yc(row,col)+numerator*poles;
                    else
                        obj.Yv(row,col)=obj.Yv(row,col)+numerator*poles;
                    end
                    obj.CktNodes{row}.Poles=obj.CktNodes{row}.Poles*denominator;

                end
            end
        end

        function obj=addSubcircuit(obj,nodes,subobj)















            num=subobj.Numerator.PolyArray;
            [nrow,ncol]=size(num,[1,2]);
            if nrow~=ncol
                error('Number of subcircuit output ports does not equal number of input ports.');
            end
            den=subobj.Denominator.PolyArray;
            subscale=subobj.FScale;

            scale=obj.FScale;


            ndeg=size(num,3);
            for indx=1:ndeg
                num(:,:,indx)=num(:,:,indx)*(subscale/scale)^(ndeg-indx);
            end
            num=msblks.utilities.PolyMat(num);
            ndeg=size(den,3);
            for indx=1:ndeg
                den(:,:,indx)=den(:,:,indx)*(subscale/scale)^(ndeg-indx);
            end
            den=msblks.utilities.PolyMat(den);


            npt=size(nodes,2);
            nrow=min([nrow,npt]);
            for indx=1:nrow

                ndindx1=obj.getNode(nodes(1,indx));
                ndindx2=obj.getNode(nodes(2,indx));
                for yndx=1:nrow

                    ndyndx1=obj.getNode(nodes(1,yndx));
                    ndyndx2=obj.getNode(nodes(2,yndx));
                    if isempty(ndindx2)
                        if isempty(ndyndx2)


                            obj=obj.addToNode(true,...
                            ndyndx1.TypeIndex,ndindx1.TypeIndex,num(yndx,indx),den);
                        else

                            obj=obj.addToNode(true,...
                            ndyndx2.TypeIndex,ndindx1.TypeIndex,num(yndx,indx),den);
                        end
                    else
                        if isempty(ndyndx2)


                            obj=obj.addToNode(true,...
                            ndyndx1.TypeIndex,ndindx2.TypeIndex,num(yndx,indx),den);
                        else

                            obj=obj.addToNode(true,...
                            ndyndx2.TypeIndex,ndindx2.TypeIndex,num(yndx,indx),den);
                        end
                    end
                end
            end
        end

        function obj=addPort(obj,name,type,nodes)









            [~,nn]=size(nodes);
            port.Name=name;

            [~,p]=size(obj.InPorts);
            [~,q]=size(obj.OutPorts);
            switch type
            case 'input'
                if obj.LastInPort<p
                    port.Type='input';
                    obj.LastInPort=obj.LastInPort+1;
                    port.TypeIndex=obj.LastInPort;
                    node1=obj.getNode(nodes(1));
                    if node1.Type~=3&&node1.Type~=4
                        error('Input nodes must be either voltage or current driven nodes.');
                    end
                    port.PlusNode=nodes(1);
                    port.MinusNode=0;
                    obj.InPorts{obj.LastInPort}=port;
                else
                    error('Not enough input ports specified.');
                end
            case 'output'
                if obj.LastOutPort<q
                    port.Type='output';
                    obj.LastOutPort=obj.LastOutPort+1;
                    port.TypeIndex=obj.LastOutPort;
                    node1=obj.getNode(nodes(1));
                    if node1.Type==3||node1.Type==4
                        error('Output nodes must be circuit, state current or control current nodes.');
                    end
                    port.PlusNode=nodes(1);
                    if nn>1
                        node2=obj.getNode(nodes(2));
                    else
                        node2=[];
                    end
                    if~isempty(node2)
                        if node1.Type~=node2.Type
                            error(['voltage/current mismatch in output port '...
                            ,num2str(port.TypeIndex),'.']);
                        end
                        port.MinusNode=nodes(2);
                    else
                        port.MinusNode=0;
                    end
                    obj.OutPorts{obj.LastOutPort}=port;
                else
                    error('Not enough output ports specified.');
                end
            otherwise
                error(['Programming error: port type ',type,' not recognized.']);
            end
        end

        function[inputs,outputs]=getPortNames(obj)


            ni=size(obj.InPorts,2);
            no=size(obj.OutPorts,2);
            inputs=cell(1,ni);
            outputs=cell(1,no);
            for indx=1:ni
                inputs{indx}=obj.InPorts{indx}.Name;
            end
            for indx=1:no
                outputs{indx}=obj.OutPorts{indx}.Name;
            end
        end

        function[inputs,outputs]=getPortNodes(obj)



            ni=size(obj.InPorts,2);
            no=size(obj.OutPorts,2);
            inputs=zeros(1,ni);
            for indx=1:ni
                inputs(indx)=obj.InPorts{indx}.PlusNode;
            end

            noutnodes=0;
            for indx=1:no
                if obj.OutPorts{indx}.PlusNode
                    noutnodes=noutnodes+1;
                end
                if obj.OutPorts{indx}.MinusNode
                    noutnodes=noutnodes+1;
                end
            end
            outputs=zeros(1,noutnodes);
            yndx=0;
            for indx=1:no
                if obj.OutPorts{indx}.PlusNode
                    yndx=yndx+1;
                    outputs(yndx)=obj.OutPorts{indx}.PlusNode;
                end
                if obj.OutPorts{indx}.MinusNode
                    yndx=yndx+1;
                    outputs(yndx)=obj.OutPorts{indx}.MinusNode;
                end
            end
        end

        function obj=scaleFrequency(obj)






            yc=obj.Yc.PolyArray;
            [nr,nc,nd]=size(yc);
            yv=obj.Yv.PolyArray;
            [nr1,nc1,nd1]=size(yv);
            assert(nr1==nr);

            clogtotal=0;
            ntotal=0;
            for j=1:nr
                for k=1:nc
                    for m=1:nd-1
                        if yc(j,k,m)~=0&&yc(j,k,m+1)~=0
                            clogtotal=clogtotal+log(abs(yc(j,k,m+1)/yc(j,k,m)));
                            ntotal=ntotal+1;
                        end
                    end
                end
            end
            if ntotal>0
                obj.FScale=exp(clogtotal/ntotal);
            end

            for j=1:nr
                for k=1:nc
                    for m=1:nd-1
                        yc(j,k,m)=yc(j,k,m)*obj.FScale^(nd-m);
                    end
                end
                for k=1:nc1
                    for m=1:nd1-1
                        yv(j,k,m)=yv(j,k,m)*obj.FScale^(nd1-m);
                    end
                end
            end
            obj.Yc=msblks.utilities.PolyMat(yc);
            obj.Yv=msblks.utilities.PolyMat(yv);
        end

        function obj=solveCircuit(obj,inputs,outputs)







            [~,ni]=size(inputs);
            [~,no]=size(outputs);
            colndx=zeros(1,ni);
            rowndx=zeros(1,no);
            for indx=1:ni
                if obj.LastDrv>0
                    for yndx=1:obj.LastDrv
                        node=obj.DriveNodes{yndx};
                        if node.Number==inputs(indx)
                            colndx(indx)=node.TypeIndex;
                        end
                    end
                end
                if colndx(indx)==0
                    error(['Input node number ',num2str(inputs(indx)),' not found.']);
                end
            end
            for indx=1:no
                if obj.LastCkt>0
                    for yndx=1:obj.LastCkt
                        node=obj.CktNodes{yndx};
                        if node.Number==outputs(indx)
                            rowndx(indx)=node.TypeIndex;
                        end
                    end
                end
                if rowndx(indx)==0
                    error(['Output node number ',num2str(outputs(indx)),' not found.']);
                end
            end

            [~,n]=size(obj.CktNodes);
            I=msblks.utilities.PolyMat(eye(n));
            zero=msblks.utilities.PolyMat(0);



            obj=obj.scaleFrequency();

            [Yinv,d]=msblks.utilities.invertRingMatrix(obj.Yc,I,zero);
            Ysoln=-Yinv*obj.Yv;

            noutpt=size(obj.OutPorts,2);
            matin=zeros(noutpt,ni,1);
            q=msblks.utilities.PolyMat(matin);



            for yndx=1:ni


                zndx=1;
                for indx=1:noutpt
                    if obj.OutPorts{indx}.PlusNode
                        q(indx,yndx)=Ysoln(rowndx(1,zndx),colndx(yndx));
                        zndx=zndx+1;
                    end
                    if obj.OutPorts{indx}.MinusNode
                        q(indx,yndx)=q(indx,yndx)-...
                        Ysoln(rowndx(1,zndx),colndx(yndx));
                        zndx=zndx+1;
                    end
                end
            end



            qmat=q.PolyArray;
            dmat=d.PolyArray;
            qmax=max(abs(qmat),[],'all');
            dmax=max(abs(dmat),[],'all');


            if qmax==0
                qmax=1;
            end
            if dmax==0
                dmax=1;
            end

            while max(abs(qmat(:,:,end)),[],'all')<qmax*1e-12&&...
                max(abs(dmat(:,:,end)),[],'all')<dmax*1e-12
                qmat=qmat(:,:,1:end-1);
                dmat=dmat(:,:,1:end-1);
            end

            obj.Numerator=msblks.utilities.PolyMat(qmat);
            obj.Denominator=msblks.utilities.PolyMat(dmat);
        end

        function HofF=getTransferFunction(obj,f)









            if isempty(obj.Numerator)||isempty(obj.Denominator)
                error('Need to solve the circuit before calculating the transfer function.');
            end
            [nr,nf]=size(f);
            if nr~=1||nf<1
                error('Expected a row vector for the frequency array.');
            end
            s=abs(f)*2j*pi/obj.FScale;
            qmat=obj.Numerator.PolyArray;
            dmat=obj.Denominator.PolyArray;
            [nr,nc,ndn]=size(qmat);
            [~,~,ndd]=size(dmat);
            HofF=zeros(nr,nc,nf);
            for ndx=1:nf
                for deg=1:ndn
                    HofF(:,:,ndx)=HofF(:,:,ndx)+...
                    qmat(:,:,deg)*s(ndx)^(ndn-deg);
                end
                den=0;
                for deg=1:ndd
                    den=den+dmat(1,1,deg)*s(ndx)^(ndd-deg);
                end
                HofF(:,:,ndx)=HofF(:,:,ndx)/den;
            end
        end

        function[z,p,k]=getZPK(obj)













            [nr,nc]=size(obj.Numerator);
            z=cell(nr,nc);
            k=zeros(nr,nc);
            denominator=obj.Denominator.PolyArray;
            ncoef=size(denominator,3);

            dmax=max(abs(denominator),[],'all');
            indx=ncoef;
            while abs(denominator(1,1,indx))<(dmax*1e-12)
                denominator(1,1,indx)=0;
                indx=indx-1;
            end
            p=obj.FScale*roots(squeeze(denominator));
            for indx=1:ncoef
                if denominator(1,1,indx)~=0
                    a0=denominator(1,1,indx);
                    denpower=ncoef-indx;
                end
            end
            numerator=obj.Numerator.PolyArray;
            for indx=1:nr
                for yndx=1:nc
                    ncoef=size(numerator,3);

                    qmax=max(abs(numerator(indx,yndx,:)),[],'all');
                    zndx=ncoef;
                    while abs(numerator(indx,yndx,zndx))<qmax*1e-12
                        numerator(indx,yndx,zndx)=0;
                        zndx=zndx-1;
                    end
                    z{indx,yndx}=obj.FScale*roots(squeeze(numerator(indx,yndx,:)));
                    b0=0;
                    for zndx=1:ncoef
                        if numerator(indx,yndx,zndx)~=0
                            b0=numerator(indx,yndx,zndx);
                            numpower=ncoef-zndx;
                        end
                    end

                    k(indx,yndx)=b0/a0*obj.FScale^(denpower-numpower);
                end
            end
        end

        function[sos,g]=getSOSArray(obj,tau)







            [z,p,k]=obj.getZPK();
            [n,m]=size(z);
            sos=cell(n,m);
            g=zeros(n,m);
            for indx=1:n
                for yndx=1:m
                    [sos{indx,yndx},g(indx,yndx)]=...
                    laplace2sos(p',z{indx,yndx}',k(indx,yndx),tau);
                end
            end
        end

        function[inports,outports]=getPortArrays(obj,tau)






















            n=size(obj.InPorts,2);
            m=size(obj.OutPorts,2);
            inports=cell(1,n);
            outports=cell(1,m);
            for indx=1:n
                inports{indx}.Name=obj.InPorts{indx}.Name;
                inports{indx}.Type=obj.InPorts{indx}.Type;
                if strcmp(inports{indx}.Type,'noise')
                    inports{indx}.SpectralDensity=...
                    obj.InPorts{indx}.SpectralDensity;
                    inports{indx}.Seed=obj.InPorts{indx}.Seed;
                    fp1=-2*pi*obj.InPorts{indx}.CornerFrequency/6;
                    fz1=fp1*sqrt(10);
                    fp2=fp1/10;
                    fz2=fp2*sqrt(10);
                    fp3=fp2/10;
                    fz3=fp3*sqrt(10);
                    fp4=fp3/10;
                    fz4=fp4*sqrt(10);
                    gain=10;
                    [inports.SOSMatrix,~]=...
                    laplace2sos([fp1,fp2,fp3,fp4],[fz1,fz2,fz3,fz4],gain,tau);
                else
                    inports{indx}.SpectralDensity=0;
                    inports{indx}.SOSMatrix=[];
                    inports{indx}.Seed=0;
                end
            end
            for indx=1:m
                outports{indx}.Name=obj.OutPorts{indx}.Name;
                outports{indx}.Type=obj.OutPorts{indx}.Type;
            end
        end

        function[A,B,C,D,e11,f22]=getStateModel(obj,varargin)











            if isempty(obj.Ycsym)||isempty(obj.Yvsym)
                A=[];
                B=[];
                C=[];
                D=[];
                e11=[];
                f22=[];
                return;
            end





            [nr,nc]=size(obj.Yvsym);
            base=obj.Yvsym.Base;
            indexarray=obj.Yvsym.IndexArray;
            nvar=size(indexarray,2);
            Ycpoly=evaluateToMatrix(obj.Ycsym,true);
            ndp=size(Ycpoly,3);




            extensionmap=cell(1,nr);
            next=nr;

            for yndx=1:nr
                degreefound=false;
                degree=ndp;
                maxcoeff=squeeze(max(abs(Ycpoly(:,yndx,:))));
                while degree>1&&~degreefound
                    degree=degree-1;
                    if maxcoeff(ndp-degree)>0
                        degreefound=true;
                    end
                end
                if degree>1
                    nmin=next+1;
                    nmax=next+(degree-1);
                    extensionmap{yndx}=[yndx,nmin:nmax];
                    next=nmax;
                else
                    extensionmap{yndx}=yndx;
                end
            end


            alphacell=cell(next);
            gammacell=cell(next);
            for indx=1:next
                for yndx=1:next
                    alphacell{indx,yndx}=zeros(1,nvar+1);
                    gammacell{indx,yndx}=zeros(1,nvar+1);
                end
            end

            for indx=1:nr
                columns=extensionmap{indx};
                ncolext=size(columns,2);
                for yndx=1:ncolext-1
                    alphacell{columns(yndx+1),columns(yndx+1)}=[1,zeros(1,nvar)];
                    gammacell{columns(yndx+1),columns(yndx)}=[1,zeros(1,nvar)];
                end
            end



            beta=msblks.utilities.VariMat(base,zeros(next,nc),indexarray);
            beta(1:nr,1:nc)=obj.Yvsym;


            valarray=obj.Ycsym.ValArray;
            for yndx=1:nr

                columns=extensionmap{yndx};
                ncolext=size(columns,2);
                for indx=1:nr
                    terms=valarray{indx,yndx};
                    nterms=size(terms,1);



                    for zndx=1:ncolext
                        alphacell{indx,columns(zndx)}=zeros(nterms,nvar+1);
                        gammacell{indx,columns(zndx)}=zeros(nterms,nvar+1);
                    end



                    for zndx=1:nterms
                        thisterm=terms(zndx,:);
                        thisexp=thisterm(2);
                        thisterm(2)=0;
                        switch thisexp
                        case 0
                            alphacell{indx,yndx}(zndx,:)=thisterm;
                        case 1
                            thisterm(1)=-thisterm(1);
                            gammacell{indx,yndx}(zndx,:)=thisterm;
                        otherwise
                            thisterm(1)=-thisterm(1);
                            gammacell{indx,columns(thisexp)}(zndx,:)=thisterm;
                        end
                    end
                end
            end


            alpha=msblks.utilities.VariMat(base,alphacell,indexarray);
            gamma=msblks.utilities.VariMat(base,gammacell,indexarray);





            gammaval=evaluateToMatrix(gamma,false);







            nnd=size(obj.CktNodes,2);
            nckt=0;
            for indx=1:nnd
                if obj.CktNodes{1,indx}.Type==0
                    nckt=nckt+1;
                end
            end
            cmax=max(abs(gammaval(1:nckt,:)),[],'all');






            for indx=nckt+1:next
                rowmax=max(abs(gammaval(indx,:)),[],'all');
                if cmax>0&&rowmax>0
                    gammaval(indx,:)=cmax/rowmax*gammaval(indx,:);
                    rowmult=msblks.utilities.VariMat(...
                    base,cmax/rowmax,indexarray);
                    alpha(indx,:)=rowmult*alpha(indx,:);
                    beta(indx,:)=rowmult*beta(indx,:);
                    gamma(indx,:)=rowmult*gamma(indx,:);

                end
            end


            [Umat,E,Vmat]=svd(gammaval);




            Umat=msblks.Circuit.Circuit.removeNumericalArtifacts(Umat);
            E=msblks.Circuit.Circuit.removeNumericalArtifacts(E);
            Vmat=msblks.Circuit.Circuit.removeNumericalArtifacts(Vmat);






            nstate=0;
            for indx=1:next
                if abs(E(indx,indx))>abs(E(1,1))*1e-12
                    nstate=nstate+1;
                end
            end

            Uinv=msblks.utilities.VariMat(base,Umat.',indexarray);
            V=msblks.utilities.VariMat(base,Vmat,indexarray);
            Esym=Uinv*gamma*V;


            F=Uinv*alpha*V;
            F11=F(1:nstate,1:nstate);
            F12=F(1:nstate,(nstate+1):next);
            F21=F((nstate+1):next,1:nstate);
            F22=F((nstate+1):next,(nstate+1):next);
            I=msblks.utilities.VariMat(base,eye(next-nstate),indexarray);
            zeromat=msblks.utilities.VariMat(base,0,indexarray);
            [F22inv,f22s]=msblks.utilities.invertRingMatrix(F22,I,zeromat);
            dI=msblks.utilities.VariMat(base,zeros(nstate),indexarray);
            for indx=1:nstate
                dI(indx,indx)=f22s;
            end
            Ist=msblks.utilities.VariMat(base,eye(nstate),indexarray);
            [E11inv,e11s]=msblks.utilities.invertRingMatrix(...
            Esym(1:nstate,1:nstate),Ist,zeromat);

            G=Uinv*beta;
            G11=G(1:nstate,:);
            G21=G((nstate+1):next,:);







            no=size(obj.OutPorts,2);
            Pmat=zeros(no,next);
            for indx=1:no
                pnode=obj.OutPorts{indx}.PlusNode;
                mnode=obj.OutPorts{indx}.MinusNode;
                if pnode>0&&pnode<=next
                    Pmat(indx,pnode)=1;
                end
                if mnode>0&&mnode<=next
                    Pmat(indx,mnode)=-1;
                end
            end
            PVmat=Pmat*Vmat;


            PVmat=msblks.Circuit.Circuit.removeNumericalArtifacts(PVmat);

            PV=msblks.utilities.VariMat(base,PVmat,indexarray);
            zout=msblks.utilities.VariMat(base,zeros(nstate,nc),indexarray);



            As=E11inv*(dI*F11-F12*F22inv*F21);
            Bs=E11inv*(dI*G11-F12*F22inv*G21);
            Cs=PV*[dI;-F22inv*F21];
            Ds=PV*[zout;-F22inv*G21];




            A=obj.removeNumericalArtifacts(obj.undistortExponents(As));
            B=obj.removeNumericalArtifacts(obj.undistortExponents(Bs));
            C=obj.removeNumericalArtifacts(obj.undistortExponents(Cs));
            D=obj.removeNumericalArtifacts(obj.undistortExponents(Ds));
            e11=obj.removeNumericalArtifacts(obj.undistortExponents(e11s));
            f22=obj.removeNumericalArtifacts(obj.undistortExponents(f22s));
            if isempty(varargin)||varargin{1}~=false
                A=A.printPoly();
                B=B.printPoly();
                C=C.printPoly();
                D=D.printPoly();
                e11=e11.printPoly();
                f22=f22.printPoly();
            end
        end
    end

    methods(Static)
        function X=undistortExponents(Xs)





            if~isa(Xs,'msblks.utilities.VariMat')
                error(['Attempted to generate a symbolic string from '...
                ,'an object that is not a VariMat.']);
            end

            valarray=Xs.ValArray;
            [nr,nc]=size(Xs);
            base=Xs.Base;
            indexarray=Xs.IndexArray;
            nv=size(indexarray,2);

            for ii=1:nv
                type=base.getType(indexarray(ii));
                switch type
                case 2
                    for ir=1:nr
                        for ic=1:nc
                            valarray{ir,ic}(:,ii+1)=...
                            -1*valarray{ir,ic}(:,ii+1);
                        end
                    end
                case 3
                    for ir=1:nr
                        for ic=1:nc
                            valarray{ir,ic}(:,ii+1)=...
                            0.5*valarray{ir,ic}(:,ii+1);
                        end
                    end
                otherwise
                end

            end
            X=msblks.utilities.VariMat(base,valarray,indexarray);

        end
    end

    methods(Static,Access=private)
        function X=removeNumericalArtifacts(Y)


            [nr,nc]=size(Y);
            if isa(Y,'msblks.utilities.VariMat')
                valarray=Y.ValArray;
                base=Y.Base;
                indexarray=Y.IndexArray;
                nvar=size(indexarray,2);
                for indx=1:nr
                    for yndx=1:nc
                        valmat=valarray{indx,yndx};
                        nt=size(valmat,1);
                        valvec=zeros(nt,1);
                        for zndx=1:nt
                            valvec(zndx)=...
                            base.evaluate(valmat(zndx,:),indexarray);
                        end
                        vmax=max(abs(valvec),[],'all');
                        if vmax>0
                            nkeep=0;
                            for zndx=1:nt
                                if abs(valvec(zndx))>vmax*1e-14
                                    nkeep=nkeep+1;
                                end
                            end
                            valmatkeep=zeros(nkeep,nvar+1);
                            wndx=0;
                            for zndx=1:nt
                                if abs(valvec(zndx))>vmax*1e-14
                                    wndx=wndx+1;
                                    valmatkeep(wndx,:)=valmat(zndx,:);
                                end
                            end
                            valarray{indx,yndx}=valmatkeep;
                        end
                    end
                end
                X=msblks.utilities.VariMat(base,valarray,indexarray);
            else
                Ymin=max(abs(Y),[],'all')*1e-14;
                X=Y;
                for indx=1:nr
                    for yndx=1:nc
                        if abs(Y(indx,yndx))<Ymin
                            X(indx,yndx)=0;
                        end
                    end
                end
            end
        end
    end
end

