

classdef BrowserDialogFactory

    methods(Static=true,Hidden=true,Access='public')
        function[aBrowserDialog]=create(aBrowserType,aURL)
            aBrowserDialog=[];

            switch(aBrowserType)
            case 'CEF'
                aBrowserDialog=constraint_manager.CEFBrowserDialog(aURL);
            end
        end
    end
end


