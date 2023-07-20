function onBack(this,dlg)



    try
        dlg.apply;
        switch(this.StepID)
        case 2
            this.StepID=1;
        case 3
            this.StepID=2;
        case 4
            this.StepID=3;
        case 5
            this.StepID=4;
        end
        this.Status='';
    catch ME
        this.Status=['Error: ',ME.message];

    end

    dlg.refresh;

end

