function addLink(obj,dest,txt)
    if~isempty(dest)
        link=['<a href="',dest,'" target="_top" class="extern" name="external_link">',txt,'</a>'];
    else
        link=txt;
    end
    obj.TableData{end+1,1}=link;
end
