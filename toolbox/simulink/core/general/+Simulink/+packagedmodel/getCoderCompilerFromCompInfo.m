function result=getCoderCompilerFromCompInfo(modelCompInfo)







    if isempty(modelCompInfo)||isempty(modelCompInfo.ModelMexCompInfo)
        result='';
        return;
    end

    comp=modelCompInfo.ModelMexCompInfo.comp;
    result=Simulink.packagedmodel.constructCompilerStr(comp);
end