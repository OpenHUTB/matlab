function[labelStr,fromStr,toStr]=parse_trans_path(transPath)




    labelStr=regexp(transPath,'.*?from \"','match','once');
    labelStr=strrep(labelStr,' from "','');


    fromStr=regexp(transPath,'from \".*?\"','match','once');
    toStr=regexp(transPath,'to \".*?\"','match','once');


    fromStr=regexp(fromStr,'\".*?\"','match','once');
    toStr=regexp(toStr,'\".*?\"','match','once');
    fromStr=strrep(fromStr,'"','');
    toStr=strrep(toStr,'"','');

