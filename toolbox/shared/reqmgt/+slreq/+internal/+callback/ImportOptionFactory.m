classdef ImportOptionFactory<handle



    methods(Static,Hidden)

        function optionObj=createImportOptions(docType,options)
            switch lower(docType)
            case 'reqif'
                optionObj=slreq.callback.ReqIFImportOptions(docType,options);
            case 'linktype_rmi_word'
                optionObj=slreq.callback.MSWordImportOptions(docType,options);
            case 'linktype_rmi_excel'
                optionObj=slreq.callback.MSExcelImportOptions(docType,options);
            case 'linktype_rmi_doors'
                optionObj=slreq.callback.DOORSImportOptions(docType,options);
            otherwise
                optionObj=slreq.callback.CustomImportOptions(docType,options);
            end
        end

    end

end

