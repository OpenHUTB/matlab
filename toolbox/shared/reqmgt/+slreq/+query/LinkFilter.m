classdef LinkFilter<slreq.query.Filter
    methods(Access=protected)
        function rs=finalFilter(this,items)
            rs=slreq.data.Link.empty(0,numel(items));
            c=0;
            for i=1:numel(items)
                if isa(items(i),'slreq.data.Link')
                    c=c+1;
                    rs(c)=items(i);
                else
                    this.lastErrors{end+1}=struct('id','Slvnv:slreq:NonLinkItemAfterFilter','message',...
                    getString(message('Slvnv:slreq:NonLinkItemAfterFilter')));
                end
            end
            rs=rs(1:c);
        end
    end

    methods
        function ls=findAll(~)
            ls=slreq.find('type','Link','_returnType','dataObject');
        end

        function r=apply(this)
            this.lastErrors=struct([]);

            if isempty(this.query)
                r=this.findAll();
            else
                apiObjs=this.evalQueryAsCellArray();
                dataObjs=slreq.data.ReqData.getDataObj(apiObjs);
                r=this.finalFilter(dataObjs);
            end

            this.queryResult=r;
        end
    end

end