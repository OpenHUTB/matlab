function display(cvtest)%#ok





    valid(cvtest);
    id=cvtest.id;

    fprintf(1,' ');
    fprintf(1,'%s = ... %s\n',inputname(1),class(cvtest));
    fprintf(1,'                  id: %g (READ ONLY)\n',id);
    fprintf(1,'            modelcov: %g (READ ONLY)\n',cv('get',id,'testdata.modelcov'));
    fprintf(1,'            rootPath: %s\n',cv('get',id,'testdata.rootPath'));
    fprintf(1,'               label: %s\n',cv('get',id,'testdata.label'));
    fprintf(1,'            setupCmd: %s\n',cv('get',id,'testdata.mlSetupCmd'));
    fprintf(1,'            settings: [1x1 struct]\n');
    fprintf(1,'    modelRefSettings: [1x1 struct]\n');
    fprintf(1,'         emlSettings: [1x1 struct]\n');
    fprintf(1,'        sfcnSettings: [1x1 struct]\n');
    fprintf(1,'             options: [1x1 struct]\n');
    fprintf(1,'              filter: %s\n',cv('get',id,'testdata.covFilter'));
    fprintf(1,'\n');

