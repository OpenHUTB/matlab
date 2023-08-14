function qabHelp(userdata,cbinfo)




    switch userdata
    case 'editorDoc'
        sfprivate('eml_man','help_editor');
    case 'mlfbDoc'
        web('https://www.mathworks.com/help/simulink/matlab-function-block.html');
    case 'supportedFcn'
        sfprivate('eml_man','help_library_ref');
    case 'mlfbExamples'
        web('https://www.mathworks.com/help/simulink/examples.html?category=matlab-function-block');
    otherwise
        return;
    end

end
