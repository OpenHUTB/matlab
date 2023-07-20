classdef DocbookEntityResolver<matlab.io.xml.dom.EntityResolver






    properties
DTDDir
    end

    methods

        function path=resolveEntity(obj,ri)
            import matlab.io.xml.dom.*

            path='';
            riType=getResourceIdentifierType(ri);
            switch(riType)
            case ResourceIdentifierType.ExternalEntity


                if ri.PublicID=="-//OASIS//DTD DocBook XML V4.2//EN"
                    path=fullfile(matlabroot,"sys/namespace/docbook/v4/dtd/docbookx.dtd");
                    obj.DTDDir=fileparts(path);
                else
                    if ri.PublicID~=""
                        path=fullfile(obj.DTDDir,ri.SystemID);
                    else
                        docDir=fileparts(ri.BaseURI);
                        path=fullfile(docDir,ri.SystemID);
                    end
                end
            otherwise
            end
        end
    end
end

