function display(this)%#ok<DISPLAY>




    fprintf(1,'\n');
    if isempty(this)
        fprintf(1,'%s =  0x0 cv.cvdatagroup\n\n',inputname(1));
        return
    end

    fprintf(1,'%s = ... %s\n\n',inputname(1),class(this));
    if~this.isLoaded
        cv.internal.cvdata.checkFileRef(this);
        fprintf(1,'                 file: %s\n',this.fileRef.name);
        fprintf(1,'                 date: %s\n',datestr(this.fileRef.datenum));

        return
    end

    names=this.allNames();
    for ii=1:numel(names)

        fprintf(1,'  %s',names{ii});

        if any([this.get(names{ii}).isObserver])
            fprintf(1,' (Observer)');
        else
            modes=this.allSimulationModes(names{ii});
            if~isempty(modes)
                fprintf(1,' (simulation mode: %s)',strjoin(modes,', '));
            end
        end
        fprintf(1,'\n');
    end

    fprintf(1,'\n\n');
