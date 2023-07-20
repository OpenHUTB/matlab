function out=getDeclaration(obj)




    prototypes={
    getFunctionClockTickFunction(obj)
    };
    out=[
    obj.getDeclarationHeader...
    ,' imported through file: "',obj.getServiceHeaderFileName,'"'...
    ,obj.getPreviewCodeDiv(sprintf('%s;\n',prototypes{:}))...
    ];
