function enables=GetColEnables(this,srow)


    hRow=this.RowSources(srow);




    stack=dbstack("-completenames");
    isVivadoSim=any(cellfun(@(x)(contains(x,'CoSimBlockDialogXSI')),{stack.file}));

    if isVivadoSim
        enables.path=false;
        enables.ioMode=false;
        enables.hdlType=false;
        enables.hdlDims=false;
    else
        enables.path=true;
        enables.ioMode=true;
        enables.hdlType=true;
        enables.hdlDims=true;
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
