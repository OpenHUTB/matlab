function number_of_problems=docCheckRun(this)









    disp(getString(message('Slvnv:rmiref:docCheckCallback:checkerStart',strrep(this.docname,'\','/'))));

    shortName=this.docname;
    separators=strfind(strrep(shortName,'\','/'),'/');
    if length(shortName)>40&&~isempty(separators)&&separators(end)>length(shortName)-40
        shortName=[' ...',shortName(end-40:end)];
    end
    progress=waitbar(0/4,getString(message('Slvnv:rmiref:docCheckCallback:checkerInitializing')),'Name',strrep(shortName,'\','/'));
    this.sessionId=this.makeSessionId();

    waitbar(1/4,progress,getString(message('Slvnv:rmiref:docCheckCallback:checkerLookingFor')));
    total_links=this.findLinks();


    if total_links>1
        disp(getString(message('Slvnv:rmiref:docCheckCallback:checkerFoundNLinks',num2str(length(this.links)))));
    elseif total_links==1;
        disp(getString(message('Slvnv:rmiref:docCheckCallback:checkerFoundOneLink')));
    elseif total_links==0
        disp(getString(message('Slvnv:rmiref:docCheckCallback:checkerFoundNoLinks')));
        number_of_problems=0;
        waitbar(4/4,progress,getString(message('Slvnv:rmiref:docCheckCallback:checkerFoundNoLinks')));
        pause(0.5);
        delete(progress);
        return;
    elseif total_links==-1
        disp(getString(message('Slvnv:rmiref:docCheckCallback:checkerCanceled')));
        number_of_problems=-1;
        waitbar(4/4,progress,getString(message('Slvnv:rmiref:docCheckCallback:checkerCanceled')));
        pause(0.5);
        delete(progress);
        return;
    end

    waitbar(2/4,progress,getString(message('Slvnv:rmiref:docCheckCallback:checkerChecking')));
    number_of_problems=this.checkLinks();

    if strcmp(this.type,'doors')
        waitbar(5/8,progress,getString(message('Slvnv:rmiref:docCheckCallback:checkerIncoming')));
        this.checkIncoming();
    end

    waitbar(3/4,progress,getString(message('Slvnv:rmiref:docCheckCallback:checkerReport')));
    this.writeReport();
    dispStr=getString(message('Slvnv:rmiref:docCheckCallback:checkerDone',this.docname));
    if any(dispStr=='\')
        dispStr=strrep(dispStr,'\','\\');
    end
    waitbar(4/4,progress,dispStr);
    pause(0.5);
    delete(progress);
end
