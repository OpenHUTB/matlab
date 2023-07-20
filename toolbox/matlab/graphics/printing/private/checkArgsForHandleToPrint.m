function[handles,simWindowName]=checkArgsForHandleToPrint(allowAxes,varargin)













    handles={};
    simWindowName=[];
    ignoreOption=false;
    for idx=1:length(varargin)
        if ignoreOption
            ignoreOption=false;
            continue;
        end
        cur_arg=varargin{idx};

        if isempty(cur_arg)

        elseif~ischar(cur_arg)


            results=LocalCheckHandles(cur_arg,allowAxes);
            if~isempty(results)
                handles=[handles,results];%#ok<AGROW>
            end

        else
            if strcmp(cur_arg,'-printjob')

                ignoreOption=true;
            elseif(cur_arg(1)=='-')
                switch(cur_arg(2))
                case 'f'
                    if~strcmp(cur_arg,'-fillpage')

                        handles=[handles,{LocalString2Handle(cur_arg)}];%#ok<AGROW>
                    end

                case 's'

                    if(exist('open_system','builtin')~=5)
                        error(message('MATLAB:prnSimulink:openSystem'));
                    end
                    window=LocalSimName2Handle(cur_arg);
                    handles=[handles,{window}];%#ok<AGROW>
                    simWindowName=get_param(window,'name');
                end
            end
        end

    end
end



function h=LocalCheckHandles(cur_arg,allowAxes)






    if~iscell(cur_arg)
        cur_arg={cur_arg};
    end

    numFigHandles=0;
    for i=1:length(cur_arg)
        v=cur_arg{i};
        dims=size(v);
        if length(dims)>2||dims(1)~=1
            error(message('MATLAB:print:HandleType'))
        end

        if~all(ishandle(v))
            error(message('MATLAB:print:HandleArgs'))
        else
            for vIdx=1:length(v)
                h=v(vIdx);
                if ishghandle(h)
                    if~(isfigure(h)||(allowAxes&&...
                        (isgraphics(h,'axes')||isgraphics(h,'polaraxes'))))
                        error(message('MATLAB:print:HGFigure'))
                    end
                    if numFigHandles>0
                        error(message('MATLAB:print:ValidateOnlyPrintOnePage'));
                    end

                    numFigHandles=numFigHandles+1;
                elseif~isslhandle(h)
                    error(message('MATLAB:print:InvalidHandleForPrint'))
                end
            end
        end
    end
    h=cur_arg;

end




function h=LocalSimName2Handle(cur_arg)




    modelName=cur_arg(3:end);
    if isempty(modelName)

        h=get_param(gcs,'handle');
    else


        try

            sys=find_system(modelName,'SearchDepth',0);
        catch %#ok<CTCH>

            sys=find_system('name',modelName);
            if isempty(sys)
                error(message('MATLAB:prnSimulink:opnMdlName',modelName))
            elseif length(sys)~=1
                error(message('MATLAB:prnSimulink:sysName',modelName))
            end
        end

        if isempty(sys)
            error(message('MATLAB:prnSimulink:sysNameUnopened',modelName))
        end


        if~isslhandle(get_param(sys{1},'handle'))
            error(message('MATLAB:prnSimulink:expBlkName',sys{1}));
        end
        h=get_param(sys{1},'handle');
    end
    if isempty(h)
        error(message('MATLAB:prnSimulink:argOpt'));
    end

end




function h=LocalString2Handle(t)





    if length(t)==2

        h=findobj(get(0,'children'),'flat','type','figure');
        if isempty(h)
            error(message('MATLAB:print:NoFigure'))
        else
            h=h(1);
        end
    else

        [h,~,e]=sscanf(t,'-f%g');
        if~isempty(e)
            error(message('MATLAB:print:ReadingFigureHandle',t))
        elseif isempty(h)||~ishandle(h)||~isfigure(h)
            error(message('MATLAB:print:NotFigureHandle'))
        end
    end


end

