function varargout=PreApplyCallback(this,dlg)



    if(dlg.hasUnappliedChanges())

        customNames=dlg.getWidgetValue('MatchInputsString');

        if customNames&&~isnan(this.str2doubleNoComma(this.state.Inputs))
            this.state.Inputs=this.cellArr2Str(dlg.getUserData('signalsList'));
            this.state.InputsString=this.state.Inputs;
        elseif~customNames&&isnan(this.str2doubleNoComma(this.state.Inputs))
            this.state.InputsString=this.state.Inputs;
            this.state.Inputs=num2str(length(this.str2CellArr(this.state.Inputs)));
        end

        outputDTStr=dlg.getWidgetValue('OutDataTypeStr');
        if(strcmp(outputDTStr,'Inherit: auto'))
            dlg.setWidgetValue('InheritFromInputs',true);
            dlg.setWidgetValue('NonVirtualBus',false);
        end

        dlg.setWidgetValue('Inputs',this.state.Inputs);
        set_param(this.getBlock.Handle,'InputsString',this.state.InputsString);


        [varargout{1},varargout{2}]=this.preApplyCallback(dlg);

        if~isempty(varargout{2})



            errid='Simulink:General:StringFormat';
            errorDuringEval=MException(errid,varargout{2});
            throwAsCaller(errorDuringEval);
        end

        this.refresh(dlg,false);
    else
        varargout{1}=true;
        varargout{2}='';
    end

end


