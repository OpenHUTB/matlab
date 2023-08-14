function vararg=mblkalg(opt,src,param)







    [flag,code,data,info]=algexp2pc(src);
    if(isempty(flag))
        if(length(param)==info(3))
            CR=char(10);
            ind=find(src==';');
            src(ind)=CR;
            if(src(end)==CR)
                src(end)='';
            end
            pc=1;
            tos=0;
            stack=zeros(info(4),1);
            csize=size(code,1);
            switch(opt)
            case 'constant'
                cnst=zeros(info(2),1);
                while(pc<csize)
                    switch(code(pc))
                    case 4
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=data(code(pc));
                    case 5
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=param(code(pc));
                    case 9
                        pc=pc+1;
                        param(code(pc))=stack(tos);
                        tos=tos-1;
                    case 11
                        pc=pc+1;
                        cnst(code(pc))=stack(tos);
                        tos=tos-1;
                    case 13
                        stack(tos)=-stack(tos);
                    case 14
                        tos=tos-1;
                        stack(tos)=stack(tos)+stack(tos+1);
                    case 15
                        tos=tos-1;
                        stack(tos)=stack(tos)-stack(tos+1);
                    case 16
                        tos=tos-1;
                        stack(tos)=stack(tos)*stack(tos+1);
                    case 17
                        tos=tos-1;
                        stack(tos)=stack(tos)/stack(tos+1);
                    case{18,19}
                        tos=tos-1;
                        stack(tos)=stack(tos).^stack(tos+1);
                    otherwise
                        error(message('sb2sl_blks:mblkalg:AlgExpNotSupported'));
                    end
                    pc=pc+1;
                end
                vararg={src,cnst};
            case 'scale'
                gain=zeros(info(2),1);
                ni=info(1);
                map=ones(size(gain));
                ind=0;
                chn=0;%#ok<NASGU>
                while(pc<csize)
                    switch(code(pc))
                    case 2
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=1;
                        ind=code(pc);
                    case 4
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=data(code(pc));
                    case 5
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=param(code(pc));
                    case 9
                        pc=pc+1;
                        param(code(pc))=stack(tos);
                        tos=tos-1;
                    case 11
                        pc=pc+1;
                        chn=code(pc);
                        gain(chn)=stack(tos);
                        map(chn)=ind;
                        tos=tos-1;
                    case 13
                        stack(tos)=-stack(tos);
                    case 14
                        tos=tos-1;
                        stack(tos)=stack(tos)+stack(tos+1);
                    case 15
                        tos=tos-1;
                        stack(tos)=stack(tos)-stack(tos+1);
                    case 16
                        tos=tos-1;
                        stack(tos)=stack(tos)*stack(tos+1);
                    case 17
                        tos=tos-1;
                        stack(tos)=stack(tos)/stack(tos+1);
                    case{18,19}
                        tos=tos-1;
                        stack(tos)=stack(tos).^stack(tos+1);
                    otherwise
                        error(message('sb2sl_blks:mblkalg:AlgExpNotSupported'));
                    end
                    pc=pc+1;
                end
                vararg={src,gain,map,ni};
            case 'product'
                sgn=zeros(info(2),1);
                ni=info(1);
                map=ones(size(sgn,1),2);
                sacc=1;
                oper='';
                chn=0;%#ok<NASGU>
                calc=0;
                while(pc<csize)
                    switch(code(pc))
                    case 2
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=code(pc);
                        calc=0;
                    case 4
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=data(code(pc));
                        calc=1;
                    case 5
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=param(code(pc));
                        calc=1;
                    case 9
                        pc=pc+1;
                        param(code(pc))=stack(tos);
                        tos=tos-1;
                    case 11
                        pc=pc+1;
                        chn=code(pc);
                        sgn(chn)=sacc;
                        sacc=1;
                        map(chn,:)=stack(tos:tos+1)';
                        tos=tos-1;
                    case 13
                        if(calc)
                            stack(tos)=-stack(tos);
                        else
                            sacc=-sacc;
                        end
                    case 14
                        tos=tos-1;
                        stack(tos)=stack(tos)+stack(tos+1);
                    case 15
                        tos=tos-1;
                        stack(tos)=stack(tos)-stack(tos+1);
                    case 16
                        tos=tos-1;
                        if(calc)
                            stack(tos)=stack(tos)*stack(tos+1);
                        else
                            if(isempty(oper))
                                oper='**';
                            end
                        end
                    case 17
                        tos=tos-1;
                        if(calc)
                            stack(tos)=stack(tos)/stack(tos+1);
                        else
                            if(isempty(oper))
                                oper='*/';
                            end
                        end
                    case{18,19}
                        tos=tos-1;
                        stack(tos)=stack(tos).^stack(tos+1);
                    otherwise
                        error(message('sb2sl_blks:mblkalg:AlgExpNotSupported'));
                    end
                    pc=pc+1;
                end
                vararg={src,sgn,map,ni,oper};
            case 'reciprocal'
                cnst=zeros(info(2),1);
                ni=info(1);
                map=ones(size(cnst));
                ind=0;
                chn=0;%#ok<NASGU>
                while(pc<csize)
                    switch(code(pc))
                    case 2
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=1;
                        ind=code(pc);
                    case 4
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=data(code(pc));
                    case 5
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=param(code(pc));
                    case 9
                        pc=pc+1;
                        param(code(pc))=stack(tos);
                        tos=tos-1;
                    case 11
                        pc=pc+1;
                        chn=code(pc);
                        cnst(chn)=stack(tos);
                        map(chn)=ind;
                        tos=tos-1;
                    case 13
                        stack(tos)=-stack(tos);
                    case 14
                        tos=tos-1;
                        stack(tos)=stack(tos)+stack(tos+1);
                    case 15
                        tos=tos-1;
                        stack(tos)=stack(tos)-stack(tos+1);
                    case 16
                        tos=tos-1;
                        stack(tos)=stack(tos)*stack(tos+1);
                    case 17
                        tos=tos-1;
                        stack(tos)=stack(tos)/stack(tos+1);
                    case{18,19}
                        tos=tos-1;
                        stack(tos)=stack(tos).^stack(tos+1);
                    otherwise
                        error(message('sb2sl_blks:mblkalg:AlgExpNotSupported'));
                    end
                    pc=pc+1;
                end
                vararg={src,cnst,map,ni};
            case 'offset'
                cnst=zeros(info(2),1);
                ni=info(1);
                map=ones(size(cnst));
                sgn=ones(size(cnst));
                sacc=1;
                ind=0;
                chn=0;%#ok<NASGU>
                lop=0;
                while(pc<csize)
                    switch(code(pc))
                    case 2
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=0;
                        lop=2;
                        ind=code(pc);
                    case 4
                        tos=tos+1;
                        pc=pc+1;
                        lop=1;
                        stack(tos)=data(code(pc));
                    case 5
                        tos=tos+1;
                        pc=pc+1;
                        lop=1;
                        stack(tos)=param(code(pc));
                    case 9
                        pc=pc+1;
                        param(code(pc))=stack(tos);
                        tos=tos-1;
                        sacc=1;
                    case 11
                        pc=pc+1;
                        chn=code(pc);
                        cnst(chn)=stack(tos);
                        map(chn)=ind;
                        sgn(chn)=sacc;
                        sacc=1;
                        tos=tos-1;
                    case 13
                        switch(lop)
                        case 1
                            stack(tos)=-stack(tos);
                        case 2
                            sacc=-sacc;
                        case 3
                            stack(tos)=-stack(tos);
                            sacc=-sacc;
                        otherwise
                        end
                    case 14
                        tos=tos-1;
                        lop=3;
                        stack(tos)=stack(tos)+stack(tos+1);
                    case 15
                        tos=tos-1;
                        if(lop==2)
                            sacc=-sacc;
                        end
                        lop=3;
                        stack(tos)=stack(tos)-stack(tos+1);
                    case 16
                        tos=tos-1;
                        lop=3;
                        stack(tos)=stack(tos)*stack(tos+1);
                    case 17
                        tos=tos-1;
                        lop=3;
                        stack(tos)=stack(tos)/stack(tos+1);
                    case{18,19}
                        tos=tos-1;
                        lop=3;
                        stack(tos)=stack(tos).^stack(tos+1);
                    otherwise
                        error(message('sb2sl_blks:mblkalg:AlgExpNotSupported'));
                    end
                    pc=pc+1;
                end
                vararg={src,cnst,map,ni,sgn};
            case 'summation'
                sgn=zeros(info(2),2);
                ni=info(1);
                map=ones(size(sgn));
                chn=0;%#ok<NASGU>
                calc=0;
                lop=0;
                while(pc<csize)
                    switch(code(pc))
                    case 2
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=code(pc);
                        calc=0;
                        lop=2;
                    case 4
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=data(code(pc));
                        lop=1;
                        calc=1;
                    case 5
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=param(code(pc));
                        lop=1;
                        calc=1;
                    case 9
                        pc=pc+1;
                        param(code(pc))=stack(tos);
                        tos=tos-1;
                    case 11
                        pc=pc+1;
                        chn=code(pc);
                        stk=stack(tos:tos+1)';
                        sgn(chn,:)=sign(stk);
                        map(chn,:)=abs(stk);
                        tos=tos-1;
                    case 13
                        if(lop==3)
                            stack(tos:tos+1)=-stack(tos:tos+1);
                        else
                            stack(tos)=-stack(tos);
                        end
                    case 14
                        tos=tos-1;
                        if(calc)
                            stack(tos)=stack(tos)+stack(tos+1);
                        else
                            lop=3;
                        end
                    case 15
                        tos=tos-1;
                        if(calc)
                            stack(tos)=stack(tos)-stack(tos+1);
                        else
                            stack(tos+1)=-stack(tos+1);
                            lop=3;
                        end
                    case 16
                        tos=tos-1;
                        stack(tos)=stack(tos)*stack(tos+1);
                    case 17
                        tos=tos-1;
                        stack(tos)=stack(tos)/stack(tos+1);
                    case{18,19}
                        tos=tos-1;
                        stack(tos)=stack(tos).^stack(tos+1);
                    otherwise
                        error(message('sb2sl_blks:mblkalg:AlgExpNotSupported'));
                    end
                    pc=pc+1;
                end
                vararg={src,map,ni,sgn};
            case 'powercu'
                cnst=zeros(info(2),1);
                ni=info(1);
                map=ones(size(cnst));
                sgn=zeros(size(cnst));
                sacc=1;
                calc=0;
                ind=0;
                chn=0;%#ok<NASGU>
                lop=0;
                while(pc<csize)
                    switch(code(pc))
                    case 2
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=1;
                        ind=code(pc);
                        calc=0;
                        lop=2;
                    case 4
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=data(code(pc));
                        calc=1;
                        lop=1;
                    case 5
                        tos=tos+1;
                        pc=pc+1;
                        stack(tos)=param(code(pc));
                        lop=1;
                        calc=1;
                    case 9
                        pc=pc+1;
                        param(code(pc))=stack(tos);
                        tos=tos-1;
                        sacc=1;
                    case 11
                        pc=pc+1;
                        chn=code(pc);
                        cnst(chn)=stack(tos);
                        map(chn)=ind;
                        sgn(chn)=sacc;
                        sacc=1;
                        tos=tos-1;
                    case 13
                        if(lop==3)
                            sacc=-sacc;
                        else
                            stack(tos)=-stack(tos);
                        end
                    case 14
                        tos=tos-1;
                        stack(tos)=stack(tos)+stack(tos+1);
                    case 15
                        tos=tos-1;
                        stack(tos)=stack(tos)-stack(tos+1);
                    case 16
                        tos=tos-1;
                        stack(tos)=stack(tos)*stack(tos+1);
                    case 17
                        tos=tos-1;
                        stack(tos)=stack(tos)/stack(tos+1);
                    case{18,19}
                        tos=tos-1;
                        stack(tos)=stack(tos).^stack(tos+1);
                        if(~calc)
                            lop=3;
                        end
                    otherwise
                        error(message('sb2sl_blks:mblkalg:AlgExpNotSupported'));
                    end
                    pc=pc+1;
                end
                vararg={src,cnst,map,ni,sgn};
            otherwise
                stat=pdecode(code,data,info(4));
                vararg={src,stat,code,data,info};
            end
        else
            error(message('sb2sl_blks:mblkalg:WrongDimension'));
        end
    else
        error(message('sb2sl_blks:mblkalg:ErrorFlag',flag));
    end
    return

    function src=pdecode(code,data,stksize)




        nCode=size(code,1);
        pc=1;
        stack=cell(stksize,1);
        stype=zeros(stksize,1);
        tos=0;
        src='[';
        opsym=cell(19,1);
        opsym(13:17)={'-';' + ';' - ';...
        ' * ';' / '};
        while(pc<nCode)
            opCode=code(pc);
            pc=pc+1;
            switch(opCode)
            case 1
                tos=tos+1;
                stack{tos}='@t';
                stype(tos)=0;
            case 2
                tos=tos+1;
                stack{tos}=sprintf('@u%d',code(pc));
                stype(tos)=0;
                pc=pc+1;
            case 4
                tos=tos+1;
                stack{tos}=sprintf('%g',data(code(pc)));
                stype(tos)=0;
                pc=pc+1;
            case 5
                tos=tos+1;
                stack{tos}=sprintf('@p%d',code(pc));
                stype(tos)=0;
                pc=pc+1;
            case 7
                tos=tos+1;
                stack{tos}=sprintf('@y%d',code(pc));
                stype(tos)=0;
                pc=pc+1;
            case 9
                src=sprintf('%s"@p%d = %s;",',src,code(pc),stack{tos});
                pc=pc+1;
                tos=tos-1;
            case 11
                src=sprintf('%s"@y%d = %s;",',src,code(pc),stack{tos});
                pc=pc+1;
                tos=tos-1;
            case 13
                if(stype(tos)<3)
                    fmt='%s%s';
                else
                    fmt='%s(%s)';
                end
                stack{tos}=sprintf(fmt,opsym{opCode},stack{tos});
                stype(tos)=3;
            case{14,15}
                tos=tos-1;
                if(stype(tos+1)<3)
                    fmt='%s%s%s';
                else
                    fmt='%s%s(%s)';
                end
                stack{tos}=sprintf(fmt,stack{tos},opsym{opCode},stack{tos+1});
                stype(tos)=3;
            case{16,17}
                tos=tos-1;
                if(stype(tos)<=2)
                    if(stype(tos+1)<2)
                        fmt='%s%s%s';
                    else
                        fmt='%s%s(%s)';
                    end
                else
                    if(stype(tos+1)<2)
                        fmt='(%s)%s%s';
                    else
                        fmt='(%s)%s(%s)';
                    end
                end
                stack{tos}=sprintf(fmt,stack{tos},opsym{opCode},stack{tos+1});
                stype(tos)=2;
            case 18
                tos=tos-1;
                stack{tos}=sprintf('pow(%s^ %s)',stack{tos},stack{tos+1});
            case 19
                tos=tos-1;
                stack{tos}=sprintf('powdi(%s^ %s)',stack{tos},stack{tos+1});
                stype(tos)=1;
            otherwise
            end
        end
        src(end)=']';
        return
