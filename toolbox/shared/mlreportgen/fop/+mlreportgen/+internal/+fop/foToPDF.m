function pdfFile=foToPDF(foFile,pdfFile,varargin)







    p=inputParser;
    p.addOptional("DebugMode",false);
    p.parse(varargin{:});
    r=p.Results;

    fop=mlreportgen.internal.fop.createFOPObject();
    fop.DocumentURI=foFile;
    fop.OutputFilePath=pdfFile;
    fop.DebugMode=r.DebugMode;
    fop.execute();
end