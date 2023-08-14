classdef(CaseInsensitiveProperties,TruncatedProperties)...
    data<rfdata.data






























    properties(Hidden)

        CompositePlot=false;
    end
    methods
        function set.CompositePlot(obj,value)
            if~isequal(obj.CompositePlot,value)
                checkbool(obj,'CompositePlot',value)
                obj.CompositePlot=logical(value);
            end
        end
    end
    properties(Hidden)

        FigureTag='';
    end
    methods
        function set.FigureTag(obj,value)
            if~strcmp(obj.FigureTag,value)
                checkchar(obj,'FigureTag',value)
                obj.FigureTag=value;
            end
        end
    end

    methods
        function h=data(varargin)












            h=h@rfdata.data('PhantomConstruction');


            set(h,'Name','rfbbequiv.data object',varargin{:});
        end

    end

    methods
        [x,amam,ampm]=calcampm(h,fc)
        Udata=collectresponse(h,Udata,plottype,yparam,yformat,xname,...
        xformat,plotz0,tag)
        fig=compositeplot(h,defaulttag)
        info=datainfo(h)
        fig=getfigure(h)
        list=listformat(varargin)
        list=listparam(varargin)
        fig=singleplot(h,plottype,parameters,freq,pin,conditions,plotfun)
        transf=transfunc(h)
        h=update(h,ckttype,varargin)
        xname=xaxisname(h,parameter)

        function checkproperty(~)
        end
    end

end



