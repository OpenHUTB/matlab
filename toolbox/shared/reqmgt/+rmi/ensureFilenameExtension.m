function doc=ensureFilenameExtension(doc,registration)








    [~,~,ext]=fileparts(doc);
    if isempty(ext)
        switch registration
        case 'linktype_rmi_matlab'
            doc=[doc,'.m'];


        case 'linktype_rmi_data'
            doc=[doc,'.sldd'];
        case 'linktype_rmi_testmgr'
            doc=[doc,'.mldatx'];
        otherwise
        end
    end
end
