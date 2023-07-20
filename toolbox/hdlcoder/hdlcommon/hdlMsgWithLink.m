function[disptxt,modelLink]=hdlMsgWithLink(blkpath,msg)





    if nargin<2
        msg='';
    end

    ModelLink=formLink(blkpath);
    Txt=sprintf('%s\n   %s',ModelLink,msg);

    if nargout<2
        disptxt=Txt;
    else
        modelLink=ModelLink;
        disptxt=Txt;
    end



    function modelLink=formLink(blkpath)

        if~isempty(blkpath)
            hilitename=['''',blkpath,''''];
            hilitename=strrep(hilitename,char(10),' ');

            if feature('hotlinks')
                modelLink=sprintf(['<a href="matlab:hilite(get_param(''%s'',''object''),''none'');',...
                'hilite_system(%s)">%s</a>'],...
                get_param(bdroot,'Name'),hilitename,hilitename);
            else
                modelLink=hilitename;
            end
        else
            modelLink='';
        end




