function[cfmt,convs]=mlfmt2cfmt(mfmt,nargs,argStr,sizeArray,isPWSEnabled,useTmwtypesFmt64)











    n=length(mfmt);
    kc=0;


    cfmt=blanks(n+2*numel(argStr));
    fmtlist='EGXcdefgiosux';
    fmtstops=ismember(mfmt,fmtlist);
    convs='';
    numfmt=0;
    argk=1;








    init=true;
    while init||(numel(convs)>0&&numel(convs)<nargs)
        init=false;
        km=0;
        while km<n
            km=km+1;
            if mfmt(km)=='%'
                km=km+1;
                if km<=n&&mfmt(km)=='%'

                    kc=kc+1;
                    cfmt(kc)='%';
                    kc=kc+1;
                    cfmt(kc)='%';
                else








                    kc=kc+1;
                    cfmt(kc)='%';
                    kmstart=km;
                    kmend=find_format_end(fmtstops,km);


                    numfmt=numfmt+1;
                    if numfmt>nargs
                        cfmt(kc)=0;
                        break
                    end


                    coder.internal.errorIf(dollar(mfmt,kmstart,kmend),...
                    'Coder:toolbox:mfmt2cfmt_dollarNotSupported',mfmt(kmstart-1:kmend));
                    md=mfmt(kmend-1);

                    coder.internal.errorIf(md=='b'||md=='t',...
                    'Coder:toolbox:mfmt2cfmt_btNotSupported',mfmt(kmstart-1:kmend));
                    starstr=stars(mfmt,kmstart,kmend);
                    convs=[convs,starstr,mfmt(kmend)];%#ok























                    idxes=precision_inds(mfmt,kmstart,kmend);
                    for k=idxes
                        kc=kc+1;
                        cfmt(kc)=mfmt(k);
                    end


                    pfx=coder.internal.getPrintfIntegerFormatPrefix(mfmt(kmend),argStr(argk).intNumBits,sizeArray,isPWSEnabled,useTmwtypesFmt64);
                    argk=argk+1;
                    for k=1:numel(pfx)
                        kc=kc+1;
                        cfmt(kc)=pfx(k);
                    end


                    kc=kc+1;
                    cfmt(kc)=mfmt(kmend);
                    km=kmend;
                end
            elseif mfmt(km)=='\'


                kc=kc+1;
                km=km+1;
                switch mfmt(km)
                case '\'
                    cfmt(kc)='\';
                case 'a'
                    cfmt(kc)=char(7);
                case 'b'
                    cfmt(kc)=char(8);
                case 'f'
                    cfmt(kc)=char(12);
                case 'n'
                    cfmt(kc)=newline;
                case 'r'
                    cfmt(kc)=char(13);
                case 't'
                    cfmt(kc)=char(9);
                case 'v'
                    cfmt(kc)=char(11);
                case 'x'
                    km=km+1;
                    [cfmt(kc),km]=read_escape_char(mfmt,km,'hex');
                case{'0','1','2','3','4','5','6','7','8','9'}
                    [cfmt(kc),km]=read_escape_char(mfmt,km,'oct');
                otherwise
                    error(message('MATLAB:printf:BadEscapeSequenceInFormat',mfmt(km)));
                end
            else
                kc=kc+1;
                cfmt(kc)=mfmt(km);
            end
        end
    end

    kc=kc+1;
    cfmt(kc)=0;
    cfmt(kc+1:end)=[];



    function p=ishex(c)
        p=(c>='0'&&c<='9')||...
        (c>='A'&&c<='F')||...
        (c>='a'&&c<='f');



        function p=isoct(c)
            p=c>='0'&&c<='7';



            function[c,k]=read_escape_char(s,k,hex_or_oct)
                hex=coder.const(strcmp(hex_or_oct,'hex'));
                zerochar=double('0');
                n=numel(s);
                if hex
                    coder.internal.errorIf(~ishex(s(k)),'MATLAB:printf:HexCharCodeInvalid');
                    cdbl=hex2dec(s(k));
                else
                    coder.internal.errorIf(~isoct(s(k)),'MATLAB:printf:OctalCharCodeInvalid');
                    cdbl=double(s(k))-zerochar;
                end
                k=k+1;
                while k<n
                    if hex
                        if ishex(s(k))
                            cdbl=16*cdbl+hex2dec(s(k));
                        else
                            break
                        end
                    else
                        if isoct(s(k))
                            cdbl=8*cdbl+(s(k)-zerochar);
                        else
                            break
                        end
                    end
                    k=k+1;
                end
                k=k-1;
                coder.internal.errorIf(cdbl>127,'Coder:toolbox:mfmt2cfmt_unsupportedChar');
                c=char(cdbl);



                function p=dollar(mfmt,kmstart,kmend)


                    for k=kmstart:kmend-1
                        if mfmt(k)=='$'
                            p=true;
                            return
                        end
                    end
                    p=false;



                    function km=find_format_end(fmtstops,km)


                        n=length(fmtstops);
                        while km<=n
                            if fmtstops(km)
                                break
                            end
                            km=km+1;
                        end
                        coder.internal.errorIf(km>n,'Coder:toolbox:mfmt2cfmt_invalidFormat');



                        function str=stars(mfmt,kmstart,kmend)


                            staridx=zeros(1,0);
                            dotidx=zeros(1,0);


                            for k=kmstart:kmend-1
                                if mfmt(k)=='*'
                                    staridx=[staridx,k];%#ok
                                elseif mfmt(k)=='.'
                                    dotidx=[dotidx,k];%#ok
                                end
                            end
                            coder.internal.assert(numel(staridx)<=2,'Coder:toolbox:mfmt2cfmt_invalidFormat')

                            if numel(staridx)==2
                                coder.internal.assert(numel(dotidx)==1&&...
                                staridx(1)<dotidx&&dotidx<staridx(2),'Coder:toolbox:mfmt2cfmt_invalidFormat');
                            end
                            str=blanks(numel(staridx));
                            str(:)='*';



                            function inds=precision_inds(mfmt,kmstart,kmend)




                                dotidx=kmstart;
                                precend=dotidx+1;
                                idx=kmstart;



                                while idx<kmend
                                    if strcmp(mfmt(idx),'.')
                                        if strcmp(mfmt(idx+1),'-')

                                            dotidx=idx-1;
                                            idx=idx+2;



                                            coder.internal.assert(idx<kmend&&isdigit(mfmt(idx)),...
                                            'Coder:toolbox:mfmt2cfmt_invalidFormat');
                                            while idx<=kmend&&isdigit(mfmt(idx))
                                                idx=idx+1;
                                            end


                                            precend=idx;
                                        else

                                            coder.internal.assert(isdigit(mfmt(idx+1))||strcmp(mfmt(idx+1),'*'),...
                                            'Coder:toolbox:mfmt2cfmt_invalidFormat');
                                        end
                                        break
                                    end
                                    idx=idx+1;
                                end
                                inds=[kmstart:dotidx,precend:kmend];
                                inds=inds(1:end-1);





                                if~isempty(inds)&&mfmt(inds(end))=='l'&&ismember(mfmt(inds(end)+1),'diuoxX')
                                    inds=inds(1:end-1);
                                end



                                function digitq=isdigit(ch)

                                    digitq='0'<=ch&&ch<='9';


