function enables=GetColEnables(this,srow)


    hRow=this.RowSources(srow);




    stack=dbstack("-completenames");
    topofstack=stack(end);
    isVivadoSim=~isempty(strfind(topofstack.file,'CoSimBlockDialogXSI'));

    if isVivadoSim
        enables.path=false;
        enables.ioMode=false;
    else
        enables.path=true;
        enables.ioMode=true;
    end

    switch(hRow.ioMode)
    case 1
        enables.sampleTime=false;
        enables.datatype=false;
        enables.sign=false;
        enables.fracLength=false;
    case 2
        enables.sampleTime=true;
        enables.datatype=true;
        switch(hRow.datatype)
        case{-1,1,2,3}
            enables.fracLength=false;
            enables.sign=false;
        otherwise
            enables.fracLength=true;
            enables.sign=true;
        end
    end

end
