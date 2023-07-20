function[src,stat,code,data,info]=mblklog(src,param)







    [flag,code,data,info]=logexp2pc(src);
    if(isempty(flag))
        if(length(param)==info(3))
            CR=char(10);
            ind=find(src==';');
            src(ind)=CR;
            if(src(end)==CR)
                src(end)='';
            end
            stat=pdecode(code,data,info(4));
        else
            error(message('sb2sl_blks:mblklog:IncorrectDimension'));
        end
    else
        error(message('sb2sl_blks:mblklog:ErrorFlag',flag));
    end
    return

    function src=pdecode(code,data,stksize)




        nCode=size(code,1);
        pc=1;
        stack=cell(stksize,1);
        stype=zeros(stksize,1);
        tos=0;
        src='[';
        opsym=cell(32,1);
        opsym(13:17)={'-';' + ';' - ';...
        ' * ';' / '};
        opsym(20:21)={' == ';' != '};
        opsym(27:32)={' != ';' == ';' < ';' <= ';' > ';' >= '};
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
                if(stype(tos)<=3)
                    if(stype(tos+1)<3)
                        fmt='%s%s%s';
                    else
                        fmt='%s%s(%s)';
                    end
                else
                    if(stype(tos+1)<3)
                        fmt='(%s)+%s';
                    else
                        fmt='(%s)+(%s)';
                    end
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
                stype(tos)=1;
            case 19
                tos=tos-1;
                stack{tos}=sprintf('powdi(%s^ %s)',stack{tos},stack{tos+1});
                stype(tos)=1;
            case{20,21}
                tos=tos-1;
                algL=stype(tos)<4;
                algR=stype(tos+1)<4;
                if(stype(tos+1)<8)
                    if(algL&algR)
                        fmt='(%s > 0)%s(%s > 0)';
                    elseif(algL&~algR)
                        fmt='(%s > 0)%s(%s)';
                    elseif(~algL&algR)
                        fmt='(%s)%s(%s > 0)';
                    else
                        fmt='(%s)%s(%s)';
                    end
                else
                    if(algL)
                        fmt='(%s > 0)%s(%s)';
                    else
                        fmt='(%s)%s(%s)';
                    end
                end
                stack{tos}=sprintf(fmt,stack{tos},opsym{opCode},stack{tos+1});
                stype(tos)=8;
            case 22
                tos=tos-1;
                algL=stype(tos)<4;
                algR=stype(tos+1)<4;
                if(stype(tos)<=7)
                    if(stype(tos+1)<7)
                        if(algL&algR)
                            fmt='(%s > 0) || (%s > 0)';
                        elseif(algL&~algR)
                            fmt='(%s > 0) || %s';
                        elseif(~algL&algR)
                            fmt='%s || (%s > 0)';
                        else
                            fmt='%s || %s';
                        end
                    else
                        if(algL)
                            fmt='(%s > 0) || (%s)';
                        else
                            fmt='%s || (%s)';
                        end
                    end
                else
                    if(stype(tos+1)<7)
                        if(algR)
                            fmt='(%s) || (%s > 0)';
                        else
                            fmt='(%s) || %s';
                        end
                    else
                        fmt='(%s) || (%s)';
                    end
                end
                stack{tos}=sprintf(fmt,stack{tos},stack{tos+1});
                stype(tos)=7;
            case 23
                tos=tos-1;
                algL=stype(tos)<4;
                algR=stype(tos+1)<4;
                if(stype(tos)<=7)
                    if(stype(tos+1)<7)
                        if(algL&algR)
                            fmt='(%s <= 0) && (%s <= 0)';
                        elseif(algL&~algR)
                            fmt='(%s <= 0) && !(%s)';
                        elseif(~algL&algR)
                            fmt='!(%s) && (%s <= 0)';
                        else
                            fmt='!(%s) && !(%s)';
                        end
                    else
                        if(algL)
                            fmt='(%s <= 0) && !(%s)';
                        else
                            fmt='!(%s) || !(%s)';
                        end
                    end
                else
                    if(stype(tos+1)<7)
                        if(algR)
                            fmt='!(%s) && (%s <= 0)';
                        else
                            fmt='!(%s) && !(%s)';
                        end
                    else
                        fmt='!(%s) && !(%s)';
                    end
                end
                stack{tos}=sprintf(fmt,stack{tos},stack{tos+1});
                stype(tos)=7;
            case 24
                tos=tos-1;
                algL=stype(tos)<4;
                algR=stype(tos+1)<4;
                if(stype(tos)<=6)
                    if(stype(tos+1)<6)
                        if(algL&algR)
                            fmt='(%s > 0) && (%s > 0)';
                        elseif(algL&~algR)
                            fmt='(%s > 0) && %s';
                        elseif(~algL&algR)
                            fmt='%s && (%s > 0)';
                        else
                            fmt='%s && %s';
                        end
                    else
                        if(algL)
                            fmt='(%s > 0) && (%s)';
                        else
                            fmt='%s && (%s)';
                        end
                    end
                else
                    if(stype(tos+1)<6)
                        if(algR)
                            fmt='(%s) && (%s > 0)';
                        else
                            fmt='(%s) && %s';
                        end
                    else
                        fmt='(%s) && (%s)';
                    end
                end
                stack{tos}=sprintf(fmt,stack{tos},stack{tos+1});
                stype(tos)=6;
            case 25
                tos=tos-1;
                algL=stype(tos)<4;
                algR=stype(tos+1)<4;
                if(stype(tos)<=6)
                    if(stype(tos+1)<6)
                        if(algL&algR)
                            fmt='(%s <= 0) || (%s <= 0)';
                        elseif(algL&~algR)
                            fmt='(%s <= 0) || !(%s)';
                        elseif(~algL&algR)
                            fmt='!(%s) || (%s <= 0)';
                        else
                            fmt='!(%s) || !(%s)';
                        end
                    else
                        if(algL)
                            fmt='(%s <= 0) || !(%s)';
                        else
                            fmt='!(%s) || !(%s)';
                        end
                    end
                else
                    if(stype(tos+1)<6)
                        if(algR)
                            fmt='!(%s) || (%s <= 0)';
                        else
                            fmt='!(%s) || !(%s)';
                        end
                    else
                        fmt='!(%s) || !(%s)';
                    end
                end
                stack{tos}=sprintf(fmt,stack{tos},stack{tos+1});
                stype(tos)=6;
            case 26
                if(stype(tos)<4)
                    fmt='(%s <= 0)';
                else
                    fmt='!(%s)';
                end
                stack{tos}=sprintf(fmt,stack{tos});
                stype(tos)=5;
            case{27,28,29,30,31,32}

                tos=tos-1;
                if(stype(tos)<=4)
                    if(stype(tos+1)<4)
                        fmt='%s%s%s';
                    else
                        fmt='%s%s(%s)';
                    end
                else
                    if(stype(tos+1)<4)
                        fmt='(%s)%s%s';
                    else
                        fmt='(%s)%s(%s)';
                    end
                end
                stack{tos}=sprintf(fmt,stack{tos},opsym{opCode},stack{tos+1});
                stype(tos)=4;
            otherwise
            end
        end
        src(end)=']';
        return
