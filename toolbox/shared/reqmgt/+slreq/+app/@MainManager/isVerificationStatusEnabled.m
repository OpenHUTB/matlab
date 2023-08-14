function tf=isVerificationStatusEnabled(this,viewers)

    if nargin<2
        viewers=this.getAllViewers;
    end
    tf=false;
    for index=1:length(viewers)
        cViewer=viewers{index};
        if~isempty(cViewer)&&cViewer.displayVerificationStatus
            tf=true;
            return;
        end
    end
end