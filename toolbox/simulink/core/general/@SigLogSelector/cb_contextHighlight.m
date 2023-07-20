function cb_contextHighlight(varargin)




    numArgs=length(varargin);


    if numArgs<2||~varargin{2}
        obj=SigLogSelector.getSelectedSubsystem();
        if isempty(obj)||~obj.isLoaded||~obj.isValid()
            return;
        end
    else
        [~,obj]=SigLogSelector.getSelectedSubsystem();
        if isempty(obj)
            return;
        elseif length(obj)>1
            obj=obj(1);
        end
    end


    bHighlight=true;
    if numArgs>0
        bHighlight=varargin{1};
    end


    obj.highlightBlock(bHighlight);

end