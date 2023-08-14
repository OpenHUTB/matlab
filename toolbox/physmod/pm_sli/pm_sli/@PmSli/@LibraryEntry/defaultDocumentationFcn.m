function fcn=defaultDocumentationFcn(productPage,referenceRoot)












    [pmslDefaultProductPage,pmslDefaultReferenceRoot]=pmsl_defaultdocumentation;


    if nargin<1
        productPage=pmslDefaultProductPage;
    end

    if nargin<2
        referenceRoot=pmslDefaultReferenceRoot;
    end




    fcn=@lDocumentationFcn;

    function link=lDocumentationFcn(block)




        if nargin<1||isempty(block)

            link=productPage;

        else

            blockType=get_param(block,'MaskType');

            link=lower(blockType);
            link=regexprep(link,'[^\w\.]+','');

            link=[referenceRoot,'/',link,'.html'];

        end

    end

end
