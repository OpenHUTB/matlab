function[link,result]=hdllog(msg,result,file,linkOnlyMsg)



    narginchk(3,4);

    if nargin<4
        linkOnlyMsg=false;
    end

    if isa(msg,'message')
        msg=msg.getString;
    end


    fid=fopen(file,'w');
    if(fid>1)

        link=sprintf('<a href="matlab:edit(''%s'')">%s</a>',file,file);
        link=message('hdlcoder:workflow:SynthesisToolLog',link).getString;


        fprintf(fid,'%s\n%s\n%s',msg,message('hdlcoder:workflow:SynthesisToolLog','').getString,result);


        if linkOnlyMsg
            result=sprintf('%s\n%s',msg,link);
        else
            result=sprintf('%s\n%s\n%s',msg,link,result);
        end

        fclose(fid);
    else
        link=message('hdlcoder:workflow:SynthesisToolLogWriteFail',file,result).getString;
    end