

classdef BaseClass

    methods
        function other=copy(this,other)
            if nargin<2
                clsInfo=metaclass(this);
                other=feval(clsInfo.Name);
            end
            other=this.copyTo(other);
        end

        function dest=copyTo(this,dest)
            assert(isa(dest,class(dest)));

            srcClsInfo=metaclass(this);
            dstClsInfo=metaclass(dest);

            for ii=1:numel(srcClsInfo.PropertyList)
                propName=srcClsInfo.PropertyList(ii).Name;
                if~strcmpi(srcClsInfo.PropertyList(ii).GetAccess,'public')
                    continue
                end
                if isempty(findobj(dstClsInfo.PropertyList,'-depth',0,'Name',propName,'SetAccess','public'))
                    continue
                end

                if~isobject(this.(propName))
                    dest.(propName)=this.(propName);
                elseif isa(this.(propName),'cgfe.util.BaseClass')
                    dest.(propName)=this.(propName).copyTo(dest.(propName));
                end
            end
        end

        function out=toStruct(this)
            clsInfo=metaclass(this);
            out=struct();
            for ii=1:numel(clsInfo.PropertyList)
                if~strcmpi(clsInfo.PropertyList(ii).GetAccess,'public')
                    continue
                end
                propName=clsInfo.PropertyList(ii).Name;
                if~isobject(this.(propName))
                    out.(propName)=this.(propName);
                elseif isa(this.(propName),'cgfe.util.BaseClass')
                    out.(propName)=this.(propName).toStruct();
                end
            end
        end

    end
end

