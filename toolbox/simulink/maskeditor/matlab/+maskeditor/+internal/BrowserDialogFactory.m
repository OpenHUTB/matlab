

classdef BrowserDialogFactory

    methods(Static=true,Hidden=true,Access='public')
        function[aBrowserDialog]=create(aBrowserType,aURL)
            aBrowserDialog=[];

            switch(aBrowserType)
            case 'CEF'
                aBrowserDialog=maskeditor.internal.CEFBrowserDialog(aURL);
            end
        end
    end

end


