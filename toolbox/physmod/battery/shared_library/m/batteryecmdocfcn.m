function fcn=batteryecmdocfcn()











    fcn=@lDocumentationFcn;

    function link=lDocumentationFcn(block)




        libDb=PmSli.LibraryDatabase;
        productIsInstalled=dictionary(["SimscapeElectrical","SimscapeBattery"],...
        libDb.containsEntry({'ee_lib','batt_lib'}));

        if nargin<1||isempty(block)||all(~productIsInstalled.values)

            link=pmsl_defaultdocumentation;

        else

            if productIsInstalled("SimscapeBattery")
                productRoot='simscape-battery';
            else
                productRoot='sps';
            end
            blockType=get_param(block,'MaskType');
            link=lower(blockType);
            link=regexprep(link,'\W+','');
            link=[productRoot,'/ref/',link,'.html'];
        end
    end

end


