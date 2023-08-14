function[elems,msgStr]=getChain(c,cloneChain)





    if nargin==1
        cloneChain=false;
    end



    if nargout<=1
        err=true;
    else
        err=false;
        msgStr='';
    end

    elems=[];
    if c.NumPorts~=2
        msg=message('rf:rfbudget:NumPortsNot2');
        if err
            error(msg)
        else
            msgStr=msg.string;
            return
        end
    end
    flatobj=rf.internal.circuit.Flattener;
    [celems,conn,cports,nv]=flatobj.flattencircuit(c);
    for i=1:numel(celems)
        if err
            validateattributes(celems(i),...
            {'amplifier','modulator','rfelement','nport',...
            'rf.internal.txline.basetxline'},...
            {'nonempty','vector'},'',...
            sprintf('circuit element %s',celems(i).Name))
        else
            try
                validateattributes(celems(i),...
                {'amplifier','modulator','rfelement','nport',...
                'rf.internal.txline.basetxline'},...
                {'nonempty','vector'},'',...
                sprintf('circuit element %s',celems(i).Name))
            catch Mexc
                msgStr=Mexc.message;
                return
            end
        end
    end

    conn=cell2mat(conn);
    cports=cell2mat(cports);
    cports=cports(:,1);
    ne=size(conn,1);
    inports=unique(conn(:,1));
    outports=unique(conn(:,2));
    ports=unique([inports;outports]);
    if numel(ports)~=ne+1||...
        ~all(conn(:,3:4)==conn(1,3),"all")||...
        sum(cports(1)==[conn(:,1);conn(:,2)])~=1||...
        sum(cports(2)==[conn(:,1);conn(:,2)])~=1
        msg=message('rf:rfbudget:NotChain');
        if err
            error(msg)
        else
            msgStr=msg.string;
            return
        end
    end




    toFw=cell(nv,1);
    toBw=cell(nv,1);
    thruFw=cell(nv,1);
    thruFwSymm=cell(nv,1);
    for i=1:ne
        rFw=conn(i,1);
        rBw=conn(i,2);
        toFw{rFw}=[toFw{rFw},rBw];
        toBw{rBw}=[toBw{rBw},rFw];
        if cloneChain
            thruFw{rFw}=[thruFw{rFw},clone(celems(i))];
        else
            thruFw{rFw}=[thruFw{rFw},celems(i)];
        end
        thruFwSymm{rFw}=[thruFwSymm{rFw}...
        ,isa(celems(i),'rf.internal.txline.basetxline')];
    end


    i=cports(1);
    elems=celems;
    elemsInd=1;
    while i~=cports(2)&&elemsInd<=ne
        toFwPos=toFw{i}>0;
        if any(toFwPos)

            iNext=toFw{i}(toFwPos);
            elems(elemsInd)=thruFw{i}(toFwPos);

            toFw{i}(toFwPos)=-1;


            toBw{iNext}(toBw{iNext}==i)=-1;
            i=iNext;
        else
            toBwPos=toBw{i}>0;
            if any(toBwPos)

                iNext=toBw{i}(toBwPos);



                toFwNextEqi=toFw{iNext}==i;
                elems(elemsInd)=thruFw{iNext}(toFwNextEqi);
                if~thruFwSymm{iNext}(toFwNextEqi)


                    break;
                end

                toBw{i}(toBwPos)=-1;


                toFw{iNext}(toFwNextEqi)=-1;
                i=iNext;
            else
                break;
            end
        end
        elemsInd=elemsInd+1;
    end
    if i~=cports(2)||elemsInd<=ne


        msg=message('rf:rfbudget:NotChain');
        if err
            error(msg)
        else
            elems=[];
            msgStr=msg.string;
            return
        end
    end
