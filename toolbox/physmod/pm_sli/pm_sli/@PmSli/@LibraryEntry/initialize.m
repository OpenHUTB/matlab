function initialize(hObj,libName,libProduct,context)










    narginchk(2,4);

    if nargin<3
        libProduct=pmsl_defaultproduct;
    end

    if nargin<4
        context=pmsl_defaultlibrary;
    end

    hObj.Name=libName;
    hObj.Product=libProduct;
    hObj.Context=context;
    hObj.IsValid=false;
    hObj.RegistrationFile='';
    hObj.Descriptor=hObj.Name;
    hObj.Icon=PmSli.Icon;

    hObj.Icon.setText(hObj.Descriptor);





    hObj.File='';

    hObj.DocumentationFcn=PmSli.LibraryEntry.defaultDocumentationFcn;

    hObj.EditingModeFcn='';

end
