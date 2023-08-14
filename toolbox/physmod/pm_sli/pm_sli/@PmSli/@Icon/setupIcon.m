function setupIcon(this,block)





    block=get_param(block,'Handle');
    position=get_param(block,'Position');
    if any(this.Size)
        position(3:4)=position(1:2)+this.Size;
    end

    set_param(block,...
    'Position',position,...
    'Mask','on',...
    'MaskDisplay',this.Display,...
    'ShowName',lOnOff(this.ShowName),...
    'MaskIconFrame',lOnOff(this.ShowFrame));

end

function v=lOnOff(vIn)

    v='off';
    if vIn
        v='on';
    end
end

