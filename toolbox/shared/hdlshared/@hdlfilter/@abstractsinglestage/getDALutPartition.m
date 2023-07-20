function varargout=getDALutPartition(this,varargin)





    if nargin~=1&&nargin~=3&&nargin~=5
        error(message('HDLShared:hdlfilter:needpvpairs'));
    end

    if strcmpi(this.InputSLType,'double')
        error(message('HDLShared:hdlfilter:notfixed'));
    end

    fl=this.getfilterlengths;
    if(isfield(fl,'firlen')&&fl.firlen<2)
        error(message('HDLShared:hdlfilter:zero_order'));
    end

    [allff,alldr,~,~]=getDAFoldingFactors(this);

    if nargin==1
        [damatrix,lutmatrix]=getDAPartMatrix(this);
        if nargout
            [fflist,darlist,linputslist,dalutpartlist]=convdamatrix2lists(damatrix,lutmatrix);
            varargout={fflist,darlist,linputslist,dalutpartlist};
        else

            displayDAPartition(this,damatrix,lutmatrix);
        end
    else
        if nargin==3



            inputprop=lower(varargin{1});
            propidx=strmatch(inputprop,{'foldingfactor','daradix','lutinputs','dalutpartition'});
            if~isempty(propidx)
                switch propidx
                case 1
                    ffact=varargin{2};
                    [baat,ffact]=checkFoldingFactor(this,ffact);
                    damatrix=getLUTMatrix(this,ffact,baat);
                case 2
                    daradix=varargin{2};
                    [baat,ffact]=checkDARadix(daradix,allff,alldr);
                    damatrix=getLUTMatrix(this,ffact,baat);

                case 3
                    lutinputs=varargin{2};
                    lutinputs=checkLutInputs(this,lutinputs);
                    dalutpart=getDALUTforwidth(this,lutinputs);
                    [lutsize,lutsizedisp]=getLUTSize(this,dalutpart,fl);
                    damatrix=getFFMatrix(this,lutinputs,lutsize,lutsizedisp);

                case 4
                    dalutpart=varargin{2};
                    dalutpart=checkFullDALUTPartition(this,dalutpart);
                    [lutsize,lutsizedisp]=getLUTSize(this,dalutpart,fl);
                    lutinputs=max(max(dalutpart'));
                    damatrix=getFFMatrix(this,lutinputs,lutsize,lutsizedisp);
                otherwise
                    error(message('HDLShared:hdlfilter:wrongargs'));
                end
            else
                error(message('HDLShared:hdlfilter:wrongargs'));
            end
            if nargout
                error(message('HDLShared:hdlfilter:wrongopargs'))
            else
                headHorz={'Folding Factor','LUT Inputs','LUT Size','LUT Details'};
                headVert={};
                justifies={'center','center','center','left'};
                dispMatrix(this,damatrix,headHorz,headVert,justifies);
            end
        else

            inputprop1=lower(varargin{1});
            inputprop2=lower(varargin{3});
            prop1idx=strmatch(inputprop1,{'foldingfactor','daradix','lutinputs','dalutpartition'});
            prop2idx=strmatch(inputprop2,{'foldingfactor','daradix','lutinputs','dalutpartition'});
            if length(prop1idx)~=1||length(prop2idx)~=1

                error(message('HDLShared:hdlfilter:wrongPropscombination'))
            end
            switch prop1idx
            case{1,2}
                switch prop2idx
                case{1,2}

                    error(message('HDLShared:hdlfilter:wrongPropscombination2'));
                case{3,4}
                    propffidx=prop1idx;
                    propffvalue=varargin{2};
                    proplutidx=prop2idx;
                    proplutvalue=varargin{4};
                otherwise
                    error(message('HDLShared:hdlfilter:wrongargs'));
                end
            case{3,4}
                switch prop2idx
                case{1,2}
                    propffidx=prop2idx;
                    propffvalue=varargin{4};
                    proplutidx=prop1idx;
                    proplutvalue=varargin{2};
                case{3,4}

                    error(message('HDLShared:hdlfilter:wrongPropscombination3'));
                otherwise
                    error(message('HDLShared:hdlfilter:wrongargs'));
                end
            otherwise
                error(message('HDLShared:hdlfilter:wrongargs'));
            end
            switch propffidx
            case 1
                ffact=propffvalue;
                [baat,ffact]=checkFoldingFactor(this,ffact);
                dalutpart=getDALUTforLutSpec(this,proplutidx,proplutvalue);
            case 2
                daradix=propffvalue;
                [baat,ffact]=checkDARadix(daradix,allff,alldr);
                dalutpart=getDALUTforLutSpec(this,proplutidx,proplutvalue);
            end
            [lutsize,lutsizedisp]=getLUTSize(this,dalutpart,fl);
            if nargout
                varargout={dalutpart,2^(baat),baat*lutsize,ffact};
            else
                damatrix={num2str(ffact),...
                [num2str(baat),' x ',num2str(lutsize),' = ',num2str(baat*lutsize)],...
                [num2str(baat),' x (',lutsizedisp,')']...
                ,this.convDALutPart2String(dalutpart),...
                ['2^',num2str(baat)]};
                headHorz={'Folding Factor','LUT Size','LUT Details','DALUTPartition','DARAdix'};
                headVert={};
                justifies={'center','center','left','center','center'};
                dispMatrix(this,damatrix,headHorz,headVert,justifies);
            end

        end

    end


    function[fflist,darlist,linputslist,dalutpartlist]=convdamatrix2lists(dpmatrix,lutmatrix)

        fflist=dpmatrix(:,1);
        darlist=dpmatrix(:,3);
        linputslist=lutmatrix(:,1);


        dalutpartlist=lutmatrix(:,4);

        function[baat,ffact]=checkFoldingFactor(this,ffact)


            [~,~,uff,udr]=getDAFoldingFactors(this);

            if ffact>max(uff)
                if ffact~=inf
                    warning(message('HDLShared:hdlfilter:highFoldingFactor',num2str(max(uff))));
                end
                ffact=max(uff);
            end
            if~any(ffact==uff)
                uffstr=num2str(unique(uff));
                error(message('HDLShared:hdlfilter:wrongff',uffstr));
            end

            baat=log2(udr(find(ffact==uff)));


            function[baat,ffact]=checkDARadix(daradix,allff,alldr)


                c=log2(daradix);
                if any(rem(daradix,1))||...
                    (~isreal(c)||any(rem(c,1))||c==0)||...
                    any(size(daradix)~=1)

                    error(message('HDLShared:hdlfilter:daradixintpow2'));
                end

                baat=log2(daradix);
                if~any(daradix==alldr)
                    log2dr=sort(log2(alldr),'ascend');
                    alldrstr=[];
                    for n=1:length(log2dr)
                        alldrstr=[alldrstr,'2^',num2str(log2dr(n))];
                        if n<length(log2dr)
                            alldrstr=[alldrstr,', '];
                        end
                    end
                    error(message('HDLShared:hdlfilter:wrongdaradix',alldrstr));
                end

                ffact=allff(find(daradix==alldr));

                function lutinputs=checkLutInputs(this,lutinputs)

                    fl=this.getfilterlengths;


                    if isempty(lutinputs)||~isnumeric(lutinputs)||(rem(lutinputs,1)~=0)||(lutinputs<=0)
                        error(message('HDLShared:hdlfilter:wrongLutinputs',num2str(fl.dalen)));
                    end

                    if lutinputs>12||lutinputs>fl.dalen
                        lutinputs=min(12,fl.dalen);
                        warning(message('HDLShared:hdlfilter:wrongLutinputswarn',num2str(fl.dalen),num2str(lutinputs)));

                    end

                    function dalutpart=checkFullDALUTPartition(this,dalutpart)

                        [lpi_checked,err_msg]=checkDALUTPartition(this,dalutpart);
                        if~lpi_checked
                            error(message('HDLShared:hdlfilter:wrongDALUTpartition',err_msg));
                        end

                        if size(dalutpart,1)==1
                            dalutpart=resolveDALUTPartition(this,dalutpart);
                        end


                        function dalutpart=getDALUTforLutSpec(this,proplutidx,proplutvalue)

                            switch proplutidx
                            case 3
                                lutinputs=proplutvalue;
                                lutinputs=checkLutInputs(this,lutinputs);
                                dalutpart=getDALUTforwidth(this,lutinputs);
                            case 4
                                dalutpart=proplutvalue;
                                dalutpart=checkFullDALUTPartition(this,dalutpart);
                            otherwise
                                error(message('HDLShared:hdlfilter:wrongargs'));
                            end

                            function damatrix=getFFMatrix(this,lutinput,lutsize,lutsizedisp)


                                [~,~,ff,dr]=getDAFoldingFactors(this);

                                ffmatrix=cell(length(ff),3);
                                recordnum=1;
                                baat=log2(dr);
                                for n=ff
                                    ffmatrix(recordnum,:)={num2str(n),...
                                    num2str(baat(recordnum)),...
                                    ['2^',num2str(baat(recordnum))]};
                                    recordnum=recordnum+1;
                                end

                                rows=size(ffmatrix,1);
                                damatrix=cell(rows,4);
                                for row=1:rows
                                    damatrix{row,1}=ffmatrix{row,1};
                                    damatrix{row,2}=num2str(lutinput);
                                    damatrix{row,3}=num2str(str2double(ffmatrix{row,2})*lutsize);
                                    damatrix{row,4}=[num2str(ffmatrix{row,2}),' x (',lutsizedisp,')'];
                                end

                                function damatrix=getLUTMatrix(this,ffact,baat)


                                    fl=this.getfilterlengths;
                                    taps=fl.dalen;
                                    lutwidths=min(12,taps):-1:2;

                                    recordnum=1;
                                    for lutw=lutwidths
                                        dalut=getDALUTforwidth(this,lutw);
                                        [lutsize,lutsizedisp]=getLUTSize(this,dalut,fl);
                                        totallutsize=sum(lutsize);
                                        lutmatrix(recordnum,:)={num2str(lutw),...
                                        num2str(baat*totallutsize),...
                                        [num2str(baat),' x (',lutsizedisp,')']};
                                        recordnum=recordnum+1;
                                    end
                                    rows=size(lutmatrix,1);
                                    damatrix=cell(rows,4);
                                    for row=1:rows
                                        damatrix{row,1}=num2str(ffact);
                                        damatrix(row,2:4)=lutmatrix(row,1:3);
                                    end

