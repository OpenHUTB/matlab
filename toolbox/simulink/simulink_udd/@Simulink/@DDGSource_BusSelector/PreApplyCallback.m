function varargout=PreApplyCallback(this,dlg)



    if(dlg.hasUnappliedChanges())

        outSignals=this.cleanQuestionMarks(this.mOutputSignals);


        if isempty(outSignals)
            outSignals={'empty'};
        end

        [varargout{1},varargout{2}]=this.preApplyCallback(dlg);

        this.refresh(dlg,false);

        set_param(this.getBlock.handle,'OutputSignals',outSignals);

    else
        varargout{1}=true;
        varargout{2}='';
    end

end

