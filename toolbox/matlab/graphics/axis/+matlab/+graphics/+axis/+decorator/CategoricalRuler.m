classdef(ConstructOnLoad)CategoricalRuler<...
    matlab.graphics.axis.decorator.ScalableAxisRuler&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.data.AbstractNonNumericConverter




    properties(Dependent)
        Categories;
    end

    properties(Access='private',AffectsObject)
        CategoryNames={};
        Ordinal=false;
    end

    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Categories','Limits','TickValues'});
        end
    end

    methods

        function hObj=CategoricalRuler(varargin)
            hObj.BuiltinLimitPadding=0.5;
            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end

        function set.Categories(ruler,val)
            val=makeCategoricalIfString(val);
            if~iscategorical(val)||...
                ~(isvector(val)||isempty(val))||...
                length(unique(val))~=length(val)
                error(message('MATLAB:graphics:CategoricalRuler:Categories'));
            end
            newcats=categoriesInUseOrder(val);
            ruler.Ordinal=isordinal(val);
            if isequal(newcats,ruler.CategoryNames)
                return;
            end




            if strcmp(ruler.TickValuesMode,'manual')
                t=ruler.TickValues;
                t2=setcats(t,newcats);
                t3=double(t2);
                ruler.NumericTickValues_I=unique(t3(isfinite(t3)));
            end
            if strcmp(ruler.MinorTickValuesMode,'manual')
                t=ruler.MinorTickValues;
                t2=setcats(t,newcats);
                t3=double(t2);
                ruler.NumericMinorTickValues_I=unique(t3(isfinite(t3)));
            end
            if strcmp(ruler.LimitsMode,'manual')
                t=ruler.Limits;
                t2=setcats(t,newcats);
                t3=double(t2);
                newlim=unique(t3(isfinite(t3)));
                if isempty(newlim)
                    ruler.NumericLimits=[0.5,1.5];
                else
                    ruler.NumericLimits=[min(newlim)-0.5,max(newlim)+0.5];
                end
            end
            ax=ancestor(ruler,'axes','node');
            if isempty(ax)
                return;
            end
            tm=ax.TargetManager;
            if isempty(tm)
                return;
            end
            targets=tm.Children;
            ch=gobjects(0);
            for k=1:length(targets)
                target=targets(k);
                if isequal(ruler,target.AxisA)||isequal(ruler,target.AxisB)||isequal(ruler,target.AxisC)

                    ch=[ch;findall(target.ChildContainer,'-isa','matlab.graphics.primitive.Data')];%#ok



                    MarkXYZLimitDependency(target.DataSpace);
                end
            end





            for j=1:length(ch)
                try %#ok
                    resetDataCacheProperties(ch(j));
                end
            end
            ruler.CategoryNames=newcats;
            for j=1:length(ch)
                try %#ok
                    resetDataCachePropertiesPost(ch(j));
                end
            end
        end

        function val=get.Categories(ruler)
            val=reshape(ruler.CategoryNames,[],1);
        end

    end

    methods(Hidden)

        function y=makeNumeric(ruler,x)
            if isempty(x)
                y=zeros(size(x));
            elseif isnumeric(x)
                y=x;
            elseif~isa(x,'categorical')
                error(message('MATLAB:graphics:CategoricalRuler:NonNumericType'));
            elseif isequal(categories(x),ruler.CategoryNames)
                y=double(x);
            else
                cats=ruler.CategoryNames;
                x=setcats(x,cats);
                y=double(x);
            end
        end

        function y=makeNonNumeric(ruler,x)
            cats=ruler.CategoryNames;
            n=length(cats);
            if isa(x,'categorical')
                y=x;
            elseif isempty(x)
                c=categorical([],1:n,cats,'Ordinal',ruler.Ordinal);
                y=reshape(c,size(x));
            elseif~isnumeric(x)
                error(message('MATLAB:graphics:CategoricalRuler:NonNumericType'));
            else
                xi=roundNumeric(ruler,x);
                y=categorical(xi,1:n,cats,'Ordinal',ruler.Ordinal);
            end
        end

        function y=makeNonNumericLimits(ruler,x)



            if isnumeric(x)
                dx=diff(x);
                round_dx=round(dx);
                if round_dx>0&&abs(dx-round_dx)<1e-8


                    n=length(ruler.CategoryNames);
                    if x(1)<0.5
                        offset=0.5-x(1);
                        x=x+offset;
                    elseif x(2)>n+0.5
                        offset=x(2)-(n+0.5);
                        x=x-offset;
                    end


                    x=x(2)-[round_dx-0.5,0.5];
                end
            end
            y=makeNonNumeric(ruler,x);
        end

        function y=format(~,x)


            y=x;
        end

        function res=isCompatibleCategorical(ruler,val)

            res=isa(val,'categorical')&&all(ismember(categories(removecats(val)),ruler.CategoryNames));
        end

        function addData(ruler,val)



            newcats=mergeDataCategories(ruler,val,ruler.CategoryNames);
            if isempty(newcats)||isequal(newcats,ruler.CategoryNames)
                return;
            end
            if ruler.Ordinal
                n=length(newcats);
                ruler.Categories=categorical(1:n,1:n,newcats,'Ordinal',true);
            else
                ruler.CategoryNames=newcats;
            end
        end

        function newcats=mergeDataCategories(ruler,val,oldcats)
            oldcats=cellstr(oldcats);
            newcats=oldcats;
            if isempty(val)||~isa(val,'categorical')
                return;
            end
            if~isempty(oldcats)
                if isordinal(val)&&~ruler.Ordinal
                    error(message('MATLAB:graphics:CategoricalRuler:OrdinalDataNonOrdinalRuler'));
                end
                if~isordinal(val)&&ruler.Ordinal
                    error(message('MATLAB:graphics:CategoricalRuler:OrdinalRulerNonOrdinalData'));
                end
            else
                ruler.Ordinal=isordinal(val);
            end
            if isequal(categories(val),oldcats)
                return;
            end
            if ruler.Ordinal


                valcats=categories(val);
                [ismem,index]=ismember(valcats,oldcats);
                if all(ismem)
                    if any(diff(index)<0)
                        error(message('MATLAB:graphics:CategoricalRuler:OrdinalMismatch'));
                    end
                    return;
                end
                [ismem,index]=ismember(oldcats,valcats);
                if~all(ismem)
                    error(message('MATLAB:graphics:CategoricalRuler:OrdinalMismatch'));
                end
                if any(diff(index)<0)
                    error(message('MATLAB:graphics:CategoricalRuler:OrdinalMismatch'));
                end
                usecats=categories(val);
                [~,useindex]=ismember(usecats,valcats);
                finalindex=unique([index;useindex]);
                newcats=valcats(finalindex);
            else
                val=removecats(val,oldcats);
                newcats=[oldcats;categoriesInRealOrder(val)];
            end
        end

        function updateRulerCategories(ruler,obj,cats)



            cats=reshape(cats,[],1);
            ch=matlab.graphics.internal.getChildrenForRuler(ruler);
            ch=setdiff(ch,obj);
            dim=ruler.Axis+1;
            for k=1:length(ch)
                obj=ch(k);
                data=matlab.graphics.internal.getDimensionData(obj,dim);
                if~isempty(data)&&iscategorical(data)
                    cats=mergeDataCategories(ruler,data,cats);
                end
            end
            if~iscategorical(cats)
                n=length(cats);
                ruler.Categories=categorical(1:n,1:n,cats,'Ordinal',ruler.Ordinal);
            else
                ruler.Categories=cats;
            end
        end

        function newlims=validateLimits(ruler,lims)


            valid=true;
            lims=makeCategoricalIfString(lims,ruler.CategoryNames);
            newlims=lims;
            if~isCompatibleCategorical(ruler,lims)
                valid=false;
            elseif~isempty(ruler.CategoryNames)
                lims=setcats(lims,ruler.CategoryNames);
                lims=double(lims);
                if numel(lims)~=2
                    valid=false;
                elseif~(lims(1)<=lims(2))
                    valid=false;
                end
            end
            if~valid
                error(message('MATLAB:graphics:CategoricalRuler:Limits'))
            end
        end

        function[lims,numlims]=setLimitsDelegate(ruler,inlims)


            inlims=validateLimits(ruler,inlims);
            if isa(inlims,'categorical')
                lims=inlims;
            else
                lims=convertNumericLimits(ruler,inlims);
            end
            if isempty(ruler.CategoryNames)
                lim1=[1,1];
            else
                lim1=makeNumeric(ruler,lims);
            end

            numlims=[lim1(1)-0.5,lim1(2)+0.5];
        end

        function dtlims=convertNumericLimits(ruler,numlims)



            dtlims=makeNonNumericLimits(ruler,numlims);
        end

        function out=computeLabels(ruler,ticks,~)

            if strcmp(ruler.TickLabelsMode,'auto')
                xi=roundNumeric(ruler,ticks);
                xi=xi(:).';
                cats=ruler.CategoryNames;
                out=cats(xi);


                out=regexprep(out,'[\n\r]+',' ');
                ruler.TickLabels_I=out;
            else
                out=ruler.TickLabels_I;
            end
        end

        function ticks=validateTicks(ruler,ticks)


            if isempty(ticks)
                return;
            end
            ticks=makeCategoricalIfString(ticks,ruler.CategoryNames);
            if~isCompatibleCategorical(ruler,ticks)
                valid=false;
            elseif~isvector(ticks)
                valid=false;
            else
                newticks=setcats(ticks,ruler.CategoryNames);
                y=double(newticks);
                valid=isfinite(y(1));
                for k=2:length(y)
                    if~(y(k-1)<y(k))
                        valid=false;
                        break;
                    end
                end
            end
            if~valid
                error(message('MATLAB:graphics:CategoricalRuler:Ticks'))
            end
        end

        function[ticks,numticks]=setTicksDelegate(ruler,inticks)


            inticks=validateTicks(ruler,inticks);
            if isa(inticks,'categorical')
                ticks=inticks;
            else
                ticks=makeNonNumeric(ruler,inticks);
            end
            numticks=makeNumeric(ruler,ticks);
        end

        function cticks=convertNumericTicks(ruler,numticks)


            cticks=makeNonNumeric(ruler,numticks);
        end

        function ticks=doChooseMajorTickValues(ruler,~,layout)

            if strcmp(ruler.TickValuesMode,'auto')
                lims=layout(5:6);
                rlims=roundNumeric(ruler,lims);
                ticks=rlims(1):rlims(2);
                ticks(ticks<lims(1))=[];
                ticks(ticks>lims(2))=[];
                if isempty(ruler.CategoryNames)
                    ticks=[];
                end
                ruler.NumericTickValues_I=ticks;
            else
                ticks=ruler.NumericTickValues_I;
            end
        end

        function allow=allowTickLabelThinning(~)


            allow=false;
        end

        function out=doStretchLimits(ruler,extents,~)




            if strcmp(ruler.LimitsMode,'auto')
                pad=0.5;

                out=extents+[-pad,pad];

                if isequal(extents,[0,1])

                    out=[pad,pad];
                end

                n=max(length(ruler.CategoryNames),1);
                out(1)=min(out(1),1-pad);
                out(2)=max(out(2),n+.5);
            else
                out=ruler.NumericLimits;
            end
        end

        function xi=roundNumeric(ruler,x)


            c=ruler.CategoryNames;
            x=real(full(double(x)));
            finitevals=isfinite(x);
            x(finitevals)=max(1.,min(length(c),x(finitevals)));
            xi=round(x);
        end

        function setHierarchicalTicks(ruler,ticks,labelmatrix)






            assert(isequal(ruler.Categories,cellstr(ticks(:))),'ticks must match the ruler categories.');

            if isempty(labelmatrix)
                ruler.clearIntervalTickRows;
                return
            end
            assert(isequal(numel(ticks),size(labelmatrix,1)),'Rows of labels must match number of ruler categories.');
            ruler.clearIntervalTickRows;


            labelmatrix=string(labelmatrix);


            tickval=ruler.makeNumeric(ticks(:));

            start=tickval(1)-.5;
            stop=tickval(end)+.5;
            for tickrow=1:width(labelmatrix)
                chg=diff(findgroups(labelmatrix(:,tickrow)))~=0;
                splits=tickval(chg)+.5;
                spans=[start;splits;stop];
                lbls=[labelmatrix(chg,tickrow);labelmatrix(end,tickrow)];
                ruler.addIntervalTickRow(spans,lbls);
            end
        end
    end
end

function res=categoriesInRealOrder(x)

    res=categories(x);
end

function res=categoriesInUseOrder(x)



    x=x(:);
    x=removecats(x);
    w=double(x);
    if isempty(w)
        res=categories(x);
    else
        res=categories(x);
        n=length(res);
        slots=zeros(1,n);
        inds=zeros(1,n);
        j=1;
        for k=1:length(w)
            val=w(k);
            if isfinite(val)&&slots(val)==0
                slots(val)=k;
                inds(j)=val;
                j=j+1;
            end
        end
        if j==n+1
            res=res(inds);
        end
    end
end

function val=makeCategoricalIfString(val,cats)


    if iscellstr(val)||isstring(val)
        if nargin==1
            n=numel(val);
            if n==0
                val=categorical.empty();
            else
                val=categorical(1:n,1:n,cellstr(val));
            end
        else
            val=categorical(val,cats);
        end
    end
end
