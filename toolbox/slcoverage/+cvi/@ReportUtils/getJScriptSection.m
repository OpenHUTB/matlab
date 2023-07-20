function outStr=getJScriptSection()




    persistent scriptStr;
    if isempty(scriptStr)
        scriptStr='<script type="text/javascript" src="./scv_images/covreport_utils.js"></script>';
    end

    outStr=scriptStr;
