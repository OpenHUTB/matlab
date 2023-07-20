function setproperties(this,dlghandle,tag)





    for idx=1:length(tag)

        switch tag{idx}
        case 'Tfldesigner_GenAlignSpec'
            val=dlghandle.getWidgetValue('Tfldesigner_GenAlignSpec');
            if val
                this.speccount=1;
                this.object=RTW.AlignmentSpecification;
            else
                this.speccount=0;
                this.object=[];
            end
        end
    end
