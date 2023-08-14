function str=getTargetMapFileString(hCS)





    targetName=codertarget.target.getTargetName(hCS);
    targetName=strrep(targetName,' ','');
    uniqueTargetString=strrep(targetName,'-','_');
    str=['Tag_ConfigSet_',uniqueTargetString,'_Coder_Target_Panel'];
end
