function setWindow(obj)





    calculateSegmentLength(obj);

    [~,winFcn,winParam]=getENBW(obj,obj.pSegmentLength);
    if isempty(winParam)
        obj.pWindowData=double(feval(winFcn,obj.pSegmentLength));
    else
        obj.pWindowData=double(feval(winFcn,obj.pSegmentLength,winParam));
    end

    obj.pWindowPower=obj.pWindowData.'*obj.pWindowData;

    setupSegmentBuffer(obj);
end
