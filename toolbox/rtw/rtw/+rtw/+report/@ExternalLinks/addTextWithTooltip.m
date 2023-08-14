function addTextWithTooltip(obj,txt,tooltip)
    t=['<div title="',tooltip,'">',txt,'</div>'];
    obj.TableData{end+1,1}=t;
end
