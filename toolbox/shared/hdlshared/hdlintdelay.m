function[vbody,vsignals]=hdlintdelay(varargin)








    narginchk(4,5);



    in=varargin{1};
    out=varargin{2};
    pname=varargin{3};
    delay=varargin{4};

    if(length(delay)>1)
        if(length(in)==1)

            in=hdlexpandvectorsignal(in);
        end
        if(length(out)==1)

            out=hdlexpandvectorsignal(out);
        end
    end


    inlen=length(in);
    outlen=length(out);
    delaylen=length(delay);

    if(inlen~=delaylen||inlen~=outlen)

        error(message('HDLShared:directemit:mismatchdim'));
    end



    zerodelay_idx=(delay==0);

    zerodelay_list=delay(zerodelay_idx);
    delay_list=delay(~zerodelay_idx);


    zbody='';
    if~isempty(zerodelay_list)
        in_z=in(zerodelay_idx);
        out_z=out(zerodelay_idx);
        for i=1:length(zerodelay_list)

            tmpstr=hdlsignalassignment(in_z(i),out_z(i));
            tmpstr=strrep(tmpstr,'\n\n','\n');
            zbody=[zbody,tmpstr];
        end
    end


    ibody='';isignals='';
    if~isempty(delay_list)


        if length(delay_list)==1&&delay_list(1)==1
            if nargin>=5
                [ibody,isignals]=hdlunitdelay(in(~zerodelay_idx),...
                out(~zerodelay_idx),pname,varargin{5});
            else
                [ibody,isignals]=hdlunitdelay(in(~zerodelay_idx),...
                out(~zerodelay_idx),pname,0);
            end
        else

            if hdlgetparameter('isvhdl')
                intdelayfunc=@vhdlintdelay;
            elseif hdlgetparameter('isverilog')
                intdelayfunc=@verilogintdelay;
            else
                error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
            end

            if nargin>=5
                [ibody,isignals]=intdelayfunc(in(~zerodelay_idx),...
                out(~zerodelay_idx),pname,delay_list,varargin{5});
            else
                [ibody,isignals]=intdelayfunc(in(~zerodelay_idx),...
                out(~zerodelay_idx),pname,delay_list);
            end
        end
    end

    vbody=['\n',zbody,ibody];
    vsignals=isignals;




