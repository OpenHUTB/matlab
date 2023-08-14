function signaldecl=makehdlsignaldecl(index)







    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if hdlispirbased||~emitMode











        signaldecl='';
    else
        signaldecl='';
        isvhdl=hdlgetparameter('isvhdl');
        comment_char=hdlgetparameter('comment_char');
        initialize_real_signals=hdlgetparameter('initialize_real_signals');
        for n=1:length(index)
            signaldecl=[signaldecl,scalarsignaldecl(index(n),isvhdl,...
            comment_char,initialize_real_signals)];%#ok
        end
    end


    function signaldecl=scalarsignaldecl(index,isvhdl,comment_char,initialize_real_signals)

        vsignal=hdlsignalname(index);
        vtype=hdlsignalvtype(index);
        sltype=hdlsignalsltype(index);
        vector=hdlsignalvector(index);

        initializer='';
        if initialize_real_signals
            if isvhdl
                if strcmp(vtype,'real')
                    initializer=' := 0.0';
                elseif strcmp(sltype,'double')&&any(vector)~=0
                    veclen=max(vector);
                    initializer=sprintf(' := (%s %s)',...
                    repmat(sprintf('%s,',formatvhdlinitialvalue(0.0)),1,veclen-1),...
                    formatvhdlinitialvalue(0.0));
                end
            else
                if strcmp(vtype,'real')&&length(vector)==1&&vector==0
                    initializer=' = 0.0';
                elseif strcmp(sltype,'double')&&any(vector)~=0
                    veclen=max(vector);
                    initializer=[' = {',sprintf('%2.1f, ',zeros(1,veclen-1)),'0.0}'];
                end
            end
        end

        comment=sltype;
        if~isempty(comment)
            comment=[comment_char,' ',comment];
        end

        if length(vector)~=1||(vector~=0&&vector~=1)

            if length(vector)==1||vector(1)==1||vector(2)==0||vector(2)==1
                vectordecl=sprintf(' [0:%d] ',max(vector)-1);
            else
                error(message('HDLShared:directemit:matrixnotsupported'));
            end
        else
            vectordecl='';
        end

        if isvhdl
            signaldecl=sprintf('  SIGNAL %-32s : %s%s; %s\n',vsignal,vtype,initializer,comment);
        else
            signaldecl=sprintf('  %s %s%s; %s\n',vtype,vsignal,vectordecl,comment);
        end


        if hdlsignaliscomplex(index)==1
            vsignal=hdlsignalname(hdlsignalimag(index));
            vtype=hdlsignalvtype(hdlsignalimag(index));
            comment=hdlsignalsltype(hdlsignalimag(index));
            if~isempty(comment)
                comment=[comment_char,' ',comment];
            end

            if isvhdl
                signaldecl=sprintf('%s  SIGNAL %-32s : %s%s; %s\n',signaldecl,vsignal,vtype,initializer,comment);
            else
                signaldecl=sprintf('%s  %s %s%s; %s\n',signaldecl,vtype,vsignal,vectordecl,comment);
            end
        end


        function vhdlstr=formatvhdlinitialvalue(value)
            vhdlstr=sprintf('%2.1f',double(value));
            gp=pir;
            isnfp=isNativeFloatingPointMode();
            if gp.getTargetCodeGenSuccess||isnfp
                vhdlstr=sprintf('X"%s"',num2hex(value));
            end
