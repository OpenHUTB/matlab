function result=getSimCompilerFromCompInfo(compInfo)




    if isempty(compInfo)
        result='';
        return;
    end

    comp=compInfo.DefaultMexCompInfo.comp;
    result=Simulink.packagedmodel.constructCompilerStr(comp);
end