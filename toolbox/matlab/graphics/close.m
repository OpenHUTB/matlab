function st=close(varargin)


























    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    status=1;
    nameOrNumberRequested=0;


    if(nargin>=1)&&isempty(varargin{1})
        if nargout==1
            st=status;
        end
        return;
    end


    closeForceAllHidden={0,0,0};
    strArgs={'Force','All','Hidden'};
    for k=1:length(strArgs)
        if any(strcmpi(strArgs{k},varargin))
            closeForceAllHidden{k}=1;
            varargin(strcmpi(strArgs{k},varargin))=[];
        end
    end


    if any(strcmpi('gcf',varargin))
        varargin{strcmpi('gcf',varargin)}=gcf;
    end

    if any(strcmpi('gcbf',varargin))
        varargin{strcmpi('gcbf',varargin)}=gcbf;
    end

    handleList=getEmptyHandleList();

    for k=1:length(varargin)
        cur_arg=varargin{k};

        if ischar(cur_arg)
            nameOrNumberRequested=1;

            hFig=findobj(get(0,'Children'),'flat','Name',cur_arg);



            if~isempty(hFig)
                handleList=[handleList,hFig];%#ok<AGROW>
                continue;
            else
                num=str2double(cur_arg);
            end


            hFig=handleFromNumber(num);
            if~isempty(hFig)
                handleList=[handleList,hFig];%#ok<AGROW>
                continue;
            end


            if~isnan(num)
                handleList=[handleList,num];%#ok<AGROW>
            end
        else

            if isnumeric(cur_arg)
                hFig=handleFromNumber(cur_arg);
                if~isempty(hFig)
                    handleList=[handleList,hFig];%#ok<AGROW>
                    continue;
                else
                    try
                        hObj=double(cur_arg);
                        handleList=[handleList,hObj];%#ok<AGROW>
                        continue;
                    catch ex


                        if strcmp(ex.identifier,'MATLAB:graphics:CannotConvertDoubleToHandle')
                            error(message('MATLAB:close:InvalidFigureHandle'));
                        else
                            rethrow(ex);
                        end
                    end
                end
            end



            if~checkfigs(cur_arg)
                error(message('MATLAB:close:InvalidFigureHandle'));
            else
                handleList=[handleList,cur_arg];%#ok<AGROW>
            end
        end
    end



    if isempty(handleList)


        if nameOrNumberRequested
            error(message('MATLAB:close:WindowNotFound'));
        end

        handleList=safegetchildren(closeForceAllHidden{:});
    end

    if~checkfigs(handleList)
        error(message('MATLAB:close:InvalidFigureHandle'));
    end

    if closeForceAllHidden{1}
        delete(handleList)
    else
        status=request_close(handleList);
    end

    if nargout==1
        st=status;
    end

    function hFig=handleFromNumber(num)

        hFig=getEmptyHandleList();
        if~any(isempty(num))&&~any(isnan(num))
            for k=1:length(num)
                hFig=[hFig,findobj(get(groot,'Children'),'flat','Number',num(k))];%#ok<AGROW>
            end
        end



        function status=request_close_helper(h,pre_or_post)









            persistent closeVisitedHandles;
            persistent restorationStruct;




            if isempty(restorationStruct)
                restorationStruct.HGRootRestore={};
            end

            switch pre_or_post
            case 'pre'

                if ismember(h,closeVisitedHandles)

                    warning(message('MATLAB:Figure:RecursionOnClose'));
                    delete(h)
                    status=false;
                    return;
                end

                if~checkfigs(h)
                    error(message('MATLAB:close:UnexpectedInvalidHandle'))
                end









                oldUDDShowHiddenHandles=get(0,'ShowHiddenHandles');
                set(0,'ShowHiddenHandles','on');


                restorationStruct.HGRootRestore{end+1}=@()set(0,'ShowHiddenHandles',oldUDDShowHiddenHandles);

                closeVisitedHandles=[closeVisitedHandles,h];
                status=true;
            case 'post'


                restorationToEval=restorationStruct.HGRootRestore{end};

                restorationToEval();


                restorationStruct.HGRootRestore(end)=[];
                closeVisitedHandles(closeVisitedHandles==h)=[];
                status=true;
            otherwise
                error(message('MATLAB:close:UnexpectedValue'))
            end


            function status=request_close(h)









                result=1;
                status=1;
                for lp=1:length(h)
                    figh=h(lp);
                    if~ishghandle(figh)
                        continue;
                    end

                    if(request_close_helper(figh,'pre'))

                        try
                            hgclose(figh);
                        catch ex
                            result=0;

                            exToThrow=MException('MATLAB:UndefinedFunction',getString(message('MATLAB:uistring:close:ErrorWhileEvaluatingFigureCloseRequestFcn')));
                            ex=ex.addCause(exToThrow);
                        end
                        request_close_helper(figh,'post');

                        if~result
                            throw(ex);
                        end

                        if ishghandle(figh)
                            status=0;
                        end
                    end
                end


                function status=checkfigs(h)

                    status=true;
                    for i=1:length(h)
                        if~any(ishghandle(h(i),'figure'))
                            status=false;
                            return
                        end
                    end


                    function h=safegetchildren(closeForce,closeAll,closeHidden)


                        if closeHidden||closeForce
                            h=allchild(0);
                            if~closeAll&&~isempty(h)
                                h=h(1);
                            end
                        elseif closeAll
                            h=get(0,'Children');


                            h2=allchild(0);
                            if length(h)~=length(h2)
                                hidden=setdiff(h2,h);
                                edfigs=getLiveEditorFigures(hidden);
                                h=[h;edfigs];
                            end
                        else
                            h=get(0,'CurrentFigure');
                        end
                        if isempty(h)
                            return;
                        end

                        specialTags={
                        'SFCHART',...
                        'DEFAULT_SFCHART',...
                        'SFEXPLR',...
                        'SF_DEBUGGER',...
                        'SF_SAFEHOUSE',...
                        'SF_SNR',...
'SIMULINK_SIMSCOPE_FIGURE'
                        };


                        filterFigs=getEmptyHandleList();

                        for j=1:length(specialTags)
                            filterFigs=[filterFigs;findobj(h,'flat','tag',specialTags{j})];%#ok
                        end
                        h=setdiff(h,filterFigs);









                        filterFigs=getEmptyHandleList();
                        for i=1:length(h)
                            if~isappdata(h(i),'IgnoreCloseAll')
                                continue;
                            end
                            ignoreFlag=getappdata(h(i),'IgnoreCloseAll');
                            if isempty(ignoreFlag)||~isscalar(ignoreFlag)||~isnumeric(ignoreFlag)
                                warning(message('MATLAB:close:InvalidValueIgnoreCloseAll'))
                                continue;
                            end
                            switch ignoreFlag
                            case 2
                                filterFigs=[filterFigs;h(i)];%#ok
                            case 1
                                if~closeForce
                                    filterFigs=[filterFigs;h(i)];%#ok
                                end
                            otherwise
                                warning(message('MATLAB:close:InvalidValueIgnoreCloseAll'))

                            end
                        end
                        h=setdiff(h,filterFigs);

                        function handleList=getEmptyHandleList()

                            handleList=matlab.graphics.GraphicsPlaceholder.empty();

                            function h=getLiveEditorFigures(h)

                                editorfig=false(size(h));
                                for j=1:length(h)
                                    if isprop(h(j),'EDITOR_APPDATA')
                                        s=get(h(j),'EDITOR_APPDATA');

                                        oldhandlevis='off';
                                        if isfield(s,'HANDLE_VISIBILITY')
                                            oldhandlevis=s.HANDLE_VISIBILITY;
                                        end
                                        editorfig(j)=ischar(oldhandlevis)&&strcmp(oldhandlevis,'on');
                                    end
                                end
                                h=h(editorfig);
