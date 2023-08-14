classdef StylesheetURIResolver<matlab.io.xml.dom.EntityResolver





    methods

        function path=resolveEntity(~,ri)
            import matlab.io.xml.dom.*

            path='';
            riType=getResourceIdentifierType(ri);
            switch(riType)
            case ResourceIdentifierType.ExternalEntity
                path=ri.SystemID;
                if path~=""
                    if startsWith(path,regexpPattern('file:/[a-zA-Z]:/'))
                        path=strrep(path,"file:/","");
                    else
                        if startsWith(path,regexpPattern('file:/[^/]'))
                            path=strrep(path,"file:","/");
                        else
                            if startsWith(path,regexpPattern('file:///'))
                                path=strrep(path,"file:///","//");
                            end
                        end
                    end
                end
            otherwise
            end
        end
    end
end

