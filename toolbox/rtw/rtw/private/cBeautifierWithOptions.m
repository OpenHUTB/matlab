
function options=cBeautifierWithOptions(filesList,modelName,varargin)



    if(nargin==2)
        fromTLC=false;
    else
        fromTLC=varargin{1};
    end

    options={};

    if(~iscell(filesList))
        if(fromTLC)




            [~,fileName,ext]=fileparts(filesList);
            fileNameStr=[fileName,ext];
            if(strcmp(fileNameStr,[modelName,ext])==1)
                return;
            end
        end

        filesList=cellstr(filesList);
    end


    if(~isempty(modelName))

        cs=getActiveConfigSet(modelName);
        isSLC=coder.internal.isSingleLineComments(cs);


        if(strcmp(get_param(cs,'IsERTTarget'),'on'))


            options(end+1)={['-indentsize=',get_param(cs,'IndentSize')]};
            options(end+1)={['-codebreakcolumn=',num2str(get_param(cs,'MaxLineWidth'))]};

            if(strcmp(get_param(cs,'IndentStyle'),'Allman'))
                options(end+1)={'-allman'};
            end


            if isSLC
                options(end+1)={'-cpluspluscomments'};
            end


            if(strcmp(get_param(cs,'NewlineStyle'),'LF'))
                if(ispc)
                    options(end+1)={'-openinbinary'};
                end
            elseif(strcmp(get_param(cs,'NewlineStyle'),'CR+LF'))

                if(isunix)
                    options(end+1)={'-openinbinary'};
                    options(end+1)={'-iscrlf'};
                end
            end
        end

        options(end+1)={'-rightJustifyTailComments'};

        if(strcmp(get_param(cs,'GenerateComments'),'off'))
            options(end+1)={'-nocomments'};
        end
    end


    if~isempty(modelName)
        traceInfo=get_param(modelName,'CoderTraceInfo');
        if~isempty(traceInfo)&&slprivate('isInCodeTraceEnabled',modelName)

            if fromTLC
                tmpTraceInfo=coder.trace.TraceInfoBuilder('');
                tmpTraceInfo.extractTraceInfo(filesList);
            else

                traceInfo.extractTraceInfo(filesList);
            end
        elseif strcmp(get_param(modelName,'SimulinkBlockComments'),'on')||...
            strcmp(get_param(modelName,'InsertBlockDesc'),'on')||...
            strcmp(get_param(modelName,'ReqsInCode'),'on')||...
            strcmp(get_param(modelName,'InsertPolySpaceComments'),'on')
            if isempty(traceInfo)
                traceInfo=coder.trace.TraceInfoBuilder('');
            end
            traceInfo.extractTraceInfo(filesList);
        end
    end

    if slsvTestingHook('TestTokenPosition')>0
        for i=1:length(filesList)
            if exist(filesList{i},'file')==2
                content=fileread(filesList{i});
                assert(~contains(content,'{S!d'),[' Error: found block comment ID in file: ',filesList{i}]);
            end
        end
    end




    cgModel=[];
    if~isempty(modelName)
        cgModel=get_param(modelName,'CGModel');
        if~isempty(cgModel)
            updateMsg=message('RTW:uiupdate:Beautifier');
            cgModel.updateUI(updateMsg.getString,true);
        end
    end
    c_beautifier(options{:},filesList{:});
    if~isempty(cgModel)
        cgModel.updateUI(updateMsg.getString,false);
    end



