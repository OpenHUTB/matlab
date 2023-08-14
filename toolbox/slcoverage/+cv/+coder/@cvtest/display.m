



function display(this)%#ok<DISPLAY>

    fprintf(1,'\n');
    fprintf(1,'%s = ... %s\n',inputname(1),class(this));
    fprintf(1,'               label: %s\n',this.label);
    fprintf(1,'            setupCmd: %s\n',this.setupCmd);
    fprintf(1,'            settings: [1x1 struct]\n');
    fprintf(1,'             options: [1x1 struct]\n');
    fprintf(1,'              filter: %s\n',this.filter);
    fprintf(1,'\n');
