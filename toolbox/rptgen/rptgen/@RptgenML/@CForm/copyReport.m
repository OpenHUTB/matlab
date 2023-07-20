function copyReport(this,rNew)






    allProps=get(rNew);

    readOnlyProps={
'Path'
'Output'
'Locale'
    };
    for i=1:length(readOnlyProps)
        if isfield(allProps,readOnlyProps{i})
            allProps=rmfield(allProps,readOnlyProps{i});
        end
    end

    set(this,allProps);
    fName=get(rNew,'RptFileName');
    set(this,'RptFileName',fName);

    if strcmp(class(rNew),'rptgen.cform_outline')
        set(this,'WarnOnSaveFileName',fName);
    end


    thisChild=this.down;
    while~isempty(thisChild)
        delete(thisChild);
        thisChild=this.down;
    end


    rDown=rNew.down;
    while~isempty(rDown)
        disconnect(rDown);
        connect(rDown,this,'up');
        rDown=rNew.down;
    end


    delete(rNew);

