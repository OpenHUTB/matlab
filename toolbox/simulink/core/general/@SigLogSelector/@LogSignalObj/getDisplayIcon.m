function val=getDisplayIcon(h)




    val='off';


    if~isempty(h)&&~isempty(h.daobject)
        if(isprop(h.daobject,'line'))
            try
                line=get_param(h.daobject.line,'Object');
                if~isempty(line)&&ishandle(line)
                    val=line.getDisplayIcon;
                end
            catch

            end
        end
    end

end
