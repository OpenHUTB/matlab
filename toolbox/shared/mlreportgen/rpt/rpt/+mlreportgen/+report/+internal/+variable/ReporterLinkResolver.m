classdef ReporterLinkResolver<handle





    properties


        LinkMap={}
    end

    methods

        function putLink(this,obj,reporter)


            if isValidObject(obj)


                domLink=getDOMLink(reporter,reporter.ReporterID,[]);
                this.LinkMap{end+1}={obj,domLink};
            end
        end

        function domLink=getLink(this,obj)


            domLink=[];

            if isValidObject(obj)
                type=class(obj);
                if~startsWith(type,'meta.')||isa(obj,'meta.class')
                    try
                        assoc=this.LinkMap(cellfun(@(assoc)eq(assoc{1},obj),...
                        this.LinkMap));
                    catch %#ok<CTCH>





                        assoc=[];
                    end

                    if~isempty(assoc)
                        domLink=clone(assoc{1}{2});
                    end
                end
            end
        end

        function clear(this)

            this.LinkMap={};
        end

    end

    methods(Static)
        function instance=instance()


            persistent INSTANCE
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.report.internal.variable.ReporterLinkResolver;
            end
            instance=INSTANCE;
        end
    end

end

function tf=isValidObject(obj)

    tf=false;
    if~isempty(obj)
        if numel(obj)>1
            if isobject(obj(1,1))||ishandle(obj(1,1))
                tf=true;
            end
        else
            if isobject(obj)||ishandle(obj)
                tf=true;
            end
        end
    end
end