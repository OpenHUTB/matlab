function update(hCS)




    knownDataVersion=codertarget.data.isParameterInitialized(hCS,'DataVersion');

    if~knownDataVersion||...
        loc_CoderTargetDataVersionLessThan(hCS,'2016a',2)



        targetName=codertarget.target.getTargetName(hCS);
        targetType=codertarget.target.getTargetType(targetName);



        if isequal(targetType,1)
            set_param(hCS,'UseSimulinkCoderFeatures','off');
            set_param(hCS,'UseEmbeddedCoderFeatures','off');
        end

        codertarget.data.setVersion(hCS);
    end
end



function ret=loc_CoderTargetDataVersionLessThan(hCS,release,ver)
    ret=str2num(codertarget.data.getParameterValue(hCS,'DataVersion'))<...
    str2num(codertarget.data.getVersionFor(release,ver));%#ok<*ST2NM>
end
