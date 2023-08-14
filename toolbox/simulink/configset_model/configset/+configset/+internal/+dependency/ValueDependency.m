classdef ValueDependency




    properties
        ValueToChange=NaN
        ValueOtherwise=NaN
        UIValueToChange=NaN
        UIValueOtherwise=NaN
    end

    methods
        function str=toString(obj,varargin)
            if nargin==1
                style='html';
            else
                style=varargin{1};
            end
            if strcmp(style,'html')
                html1='<a href="">';
                html2='</a>';
            else
                html1='';
                html2='';
            end

            if any(isnan(obj.ValueToChange))&&any(isnan(obj.ValueOtherwise))...
                &&any(isnan(obj.UIValueToChange))&&any(isnan(obj.UIValueOtherwise))
                str=['Value depends on ',html1,obj.ParentList(1).Name,html2,'.'];
                return;
            end

            str='IF ';
            for i=1:length(obj.ParentList)
                pl=obj.ParentList(i);
                name=pl.Name;
                if length(pl.ValueSet)==1
                    str=[str,html1,name,html2,' is ',configset.util.toString(pl.ValueSet{1})];%#ok
                else
                    str=[str,html1,name,html2,' choose value from ',configset.util.toString(pl.ValueSet)];%#ok
                end
                str=[str,' AND '];%#ok
            end
            str=[str(1:end-4),', THEN '];
            if~any(isnan(obj.ValueToChange))
                str=[str,'value=',configset.util.toString(obj.ValueToChange)];
            end
            if~any(isnan(obj.UIValueToChange))
                str=[str,'value=',configset.util.toString(obj.UIValueToChange),'(UI only)'];
            end
            if~any(isnan(obj.ValueOtherwise))
                str=[str,'value=',configset.util.toString(obj.ValueOtherwise)];
            end
            if~any(isnan(obj.UIValueOtherwise))
                str=[str,', ELSE value=',configset.util.toString(obj.UIValueOtherwise),'(UI only)'];
            end
            str=[str,'.'];
        end

        function obj=ValueDependency(v)
            assert(any(isnan(v{1}))||any(isnan(v{3})));
            assert(any(isnan(v{2}))||any(isnan(v{4})));

            obj.ValueToChange=v{1};
            obj.ValueOtherwise=v{2};
            obj.UIValueToChange=v{3};
            obj.UIValueOtherwise=v{4};
        end

        function[value,uionly]=checkValue(obj,cs)
            flag=true;

            for i=1:length(obj.ParentList)
                pl=obj.ParentList(i);
                name=configset.internal.util.toShortName(pl.Name);
                val=cs.getProp(name);
                if~obj.contains(pl,val)
                    flag=false;
                    break;
                end
            end

            if flag
                if any(isnan(obj.UIValueToChange))
                    value=obj.ValueToChange;
                    uionly=false;
                else
                    value=obj.UIValueToChange;
                    uionly=true;
                end
            else
                if any(isnan(obj.UIValueOtherwise))
                    value=obj.ValueOtherwise;
                    uionly=false;
                else
                    value=obj.UIValueOtherwise;
                    uionly=true;
                end
            end
        end

    end

end

