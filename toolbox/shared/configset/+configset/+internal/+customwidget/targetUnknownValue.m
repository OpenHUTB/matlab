function out=targetUnknownValue(cs,~,direction,~)


    if direction==0
        out={''};
    elseif direction==1
        out=cs.get_param('TargetUnknown');
    end