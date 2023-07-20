function tf=isImplementationStatusEnabled(this,viewers)

    if nargin<2
        viewers=this.getAllViewers;
    end
    tf=false;
    for index=1:length(viewers)
        cViewer=viewers{index};
        if~isempty(cViewer)&&cViewer.displayImplementationStatus
            tf=true;
            return;
        end
    end
end