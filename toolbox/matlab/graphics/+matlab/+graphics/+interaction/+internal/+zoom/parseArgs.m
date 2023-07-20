function[target,directive,results]=parseArgs(num_outputs,varargin)















    nin=numel(varargin);
    target=[];




    if~isempty(varargin)&&isscalar(varargin{1})&&...
        (~isnumeric(varargin{1})||...
        (isnumeric(varargin{1})&&((num_outputs>0)||(nin>1))))&&...
        (ishghandle(varargin{1},'figure')||ishghandle(varargin{1},'axes'))
        target=varargin{1};
        varargin=varargin(2:end);
        nin=nin-1;
    end

    directive=true;
    if nin==0
        results.option='toggle';
        if num_outputs>0
            results.option='noaction';
        end
    elseif nin<2
        s=varargin{1};
        checkOptions(s,num_outputs,target)
        results.option=s;
    else
        directive=false;

        p=setupParser;
        addParameter(p,'ContextMenu',-1,@validateUIContextMenu);
        addParameter(p,'UIContextMenu',-1,@validateUIContextMenu);
        addParameter(p,'Constraint','',@validateConstraint);
        addParameter(p,'Direction','',@validateDirection);

        p.parse(varargin{:});
        results=p.Results;

        if results.ContextMenu~=-1
            results.UIContextMenu=results.ContextMenu;
        end

        if~isempty(fieldnames(p.Unmatched))
            f=fieldnames(p.Unmatched);
            error(message('MATLAB:zoom:InvalidProperty',f{1}));
        end
    end

    function checkOptions(s,nout,target)
        ret=checkNumeric(s,nout,target)||...
        checkDoced(s,nout)||...
        checkNoDocInternalUseNoOutput(s,nout)||...
        checkNoDocInternalUseOutput(s)||...
        checkNoDocNoUseNoOutput(s,nout);
        if~ret
            error(message('MATLAB:zoom:UnrecognizedInput'));
        end

        function ret=checkNumeric(s,nout,target)
            ret=false;
            if isnumeric(s)
                if isempty(target)&&isempty(get(groot,'CurrentFigure'))
                    error(message('MATLAB:zoom:NoFigureExists'));
                end
                errorIfOutputExpected(s,nout);
                ret=true;
            end

            function ret=checkDoced(s,nout)
                ret=strcmpi(s,'On')||...
                strcmpi(s,'XOn')||...
                strcmpi(s,'YOn')||...
                strcmpi(s,'Off')||...
                strcmpi(s,'Reset')||...
                strcmpi(s,'Out');
                if ret
                    errorIfOutputExpected(s,nout);
                end

                function ret=checkNoDocNoUseNoOutput(s,nout)
                    ret=strcmpi(s,'toggle')||...
                    strcmpi(s,'fill')||...
                    strcmpi(s,'down');
                    if ret
                        errorIfOutputExpected(s,nout);
                    end

                    function ret=checkNoDocInternalUseNoOutput(s,nout)
                        ret=strcmp(s,'inmode')||...
                        strcmp(s,'inmodex')||...
                        strcmp(s,'inmodey')||...
                        strcmp(s,'outmode');
                        if ret
                            errorIfOutputExpected(s,nout);
                        end

                        function ret=checkNoDocInternalUseOutput(s)
                            ret=strcmp(s,'Constraint')||...
                            strcmpi(s,'IsOn')||...
                            strcmp(s,'Direction')||...
                            strcmp(s,'getmode');

                            function ret=validateConstraint(s)
                                ret=strcmpi(s,'none')||...
                                strcmpi(s,'horizontal')||...
                                strcmpi(s,'vertical');
                                if~ret
                                    error(message('MATLAB:zoom:InvalidConstraint'));
                                end

                                function ret=validateUIContextMenu(s)
                                    ret=isempty(s)||(isprop(s,'Type')&&strcmpi(get(s,'Type'),'uicontextmenu'));
                                    if~ret
                                        error(message('MATLAB:zoom:InvalidContextMenu'));
                                    end

                                    function ret=validateDirection(s)
                                        ret=strcmpi(s,'in')||strcmpi(s,'out');
                                        if~ret
                                            error(message('MATLAB:zoom:InvalidDirection'));
                                        end

                                        function errorIfOutputExpected(~,nout)
                                            if nout>0
                                                error(message('MATLAB:zoom:InvalidArgsForOutput'));
                                            end

                                            function p=setupParser
                                                p=inputParser;
                                                p.KeepUnmatched=true;
                                                p.PartialMatching=false;
                                                p.StructExpand=false;
                                                p.FunctionName='zoom';
