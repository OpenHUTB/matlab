function[libNames,libMdls,libFlat,toplevel,libTypes,libChoices,libChildren,libNewParents,libFcns]=getLibInfo(slBlockFile)





    libNames={};
    libMdls={};
    libTypes={};
    libFlat=[];
    libChoices=[];
    libChildren={};
    libNewParents={};
    toplevel=[];
    libFcns={};

    file=loc_preProcess(slBlockFile);
    clear('blkStruct','Browser')
    try
        try
            eval(file)
        catch ME

















            [startIndex,endIndex]=regexp(file,'(?<!%[^\n]*)\<end\>(?=(;|\s|%[^\n]*(\n|$))*$)');



            if~(isempty(startIndex)||isempty(endIndex))
                file(startIndex(end):endIndex(end))=[];
            else


                rethrow(ME);
            end
            ME1=MException(ME.identifier,ME.message);
            try
                eval(file);
            catch ME









                if strcmp(ME1.identifier,'MATLAB:m_illegal_reserved_keyword_usage')&&~isempty(strfind(ME1.message,'end'))
                    rethrow(ME);
                else
                    rethrow(ME1);
                end
            end
        end
        currentInfo=blkStruct(1);

        if isfield(currentInfo,'Browser')



            for idx=1:length(currentInfo.Browser)
                if length(char(currentInfo.Browser(idx).Name))~=0 %#ok
                    if isfield(currentInfo.Browser(idx),'Type')&&~isempty(currentInfo.Browser(idx).Type)
                        type=currentInfo.Browser(idx).Type;
                    else
                        type='Product';
                    end
                    type=char(type);

                    if isfield(currentInfo.Browser(idx),'Library')&&~isempty(currentInfo.Browser(idx).Library)
                        libMdlName=currentInfo.Browser(idx).Library;
                    else
                        libMdlName=currentInfo.Browser(idx).Name;
                    end
                    libMdlName=char(libMdlName);

                    if isfield(currentInfo.Browser(idx),'IsFlat')&&~isempty(currentInfo.Browser(idx).IsFlat)
                        isFlat=currentInfo.Browser(idx).IsFlat;
                        if isstring(isFlat)
                            isFlat=char(isFlat);
                        end
                        libFlat(end+1)=isFlat;%#ok
                    else
                        libFlat(end+1)=-1;%#ok
                    end

                    if isfield(currentInfo.Browser(idx),'Choice')&&~isempty(currentInfo.Browser(idx).Choice)
                        libChoices(end+1)=char(currentInfo.Browser(idx).Choice);%#ok
                    else
                        libChoices(end+1)=-1;%#ok
                    end

                    if isfield(currentInfo.Browser(idx),'Children')&&~isempty(currentInfo.Browser(idx).Children)
                        libChildren{end+1}=char(currentInfo.Browser(idx).Children);%#ok
                    else
                        libChildren{end+1}={};%#ok
                    end

                    if isfield(currentInfo.Browser(idx),'IsTopLevel')&&~isempty(currentInfo.Browser(idx).IsTopLevel)
                        isTopLevel=currentInfo.Browser(idx).IsTopLevel;
                        if isstring(isTopLevel)
                            isTopLevel=char(isTopLevel);
                        end
                        toplevel(end+1)=isTopLevel;%#ok
                    else
                        toplevel(end+1)=1;%#ok
                    end

                    if isfield(currentInfo.Browser(idx),'NewParent')&&~isempty(currentInfo.Browser(idx).NewParent)
                        libNewParents{end+1}=char(currentInfo.Browser(idx).NewParent);%#ok
                    else
                        libNewParents{end+1}='';%#ok
                    end

                    libNames{end+1}=char(currentInfo.Browser(idx).Name);%#ok
                    libMdls{end+1}=libMdlName;%#ok
                    libTypes{end+1}=type;%#ok
                    libFcns{end+1}='';%#ok

                    if strcmpi(type,'Palette')
                        if isfield(currentInfo.Browser(idx),'getPaletteFcn')&&~isempty(currentInfo.Browser(idx).getPaletteFcn)
                            libFcns{end}=currentInfo.Browser(idx).getPaletteFcn;
                        else


                        end
                    end
                end
            end
        else
            libMdlName=char(currentInfo.OpenFcn);
            if(~loc_libExists(libMdlName))
                MSLDiagnostic('Simulink:dialog:libraryNotFound',libMdlName,slBlockFile).reportAsWarning;
            else
                libNames={strrep(char(currentInfo.Name),sprintf('\n'),' ')};
                libMdls={libMdlName};
                libChildren={{}};
                libTypes={'Product'};
                libFlat(1)=-1;
                libChoices(1)=-1;
                toplevel(1)=1;
                libNewParents={''};
                libFcns={''};

                if isfield(currentInfo,'IsFlat')
                    isFlat=currentInfo.IsFlat;
                    if isstring(isFlat)
                        isFlat=char(isFlat);
                    end
                    libFlat(1)=isFlat;
                end

                if isfield(currentInfo,'Choice')
                    libChoices(1)=char(currentInfo.Choice);
                end

                if isfield(currentInfo,'Type')
                    libTypes{1}=char(currentInfo.Type);
                end

                if isfield(currentInfo,'Children')
                    libChildren{1}=currentInfo.Children;
                end

                if isfield(currentInfo,'IsTopLevel')
                    isTopLevel=currentInfo.IsTopLevel;
                    if isstring(isTopLevel)
                        isTopLevel=char(isTopLevel);
                    end
                    toplevel(1)=isTopLevel;
                end

                if isfield(currentInfo,'NewParent')
                    libNewParents{1}=char(currentInfo.NewParent);
                end
            end
            if strcmpi(libTypes,'Palette')
                if isfield(currentInfo,'getPaletteFcn')
                    libFcns{1}=char(currentInfo.getPaletteFcn);
                else


                end
            end
        end

    catch ME
        wStates=[warning;warning('query','backtrace')];
        warning off backtrace;
        MSLDiagnostic('Simulink:dialog:parseError',slBlockFile,ME.message).reportAsWarning;
        warning(wStates);
    end
end

function ret=loc_libExists(libMdlName)



    ret=(strcmpi(libMdlName,'simulink')||exist(libMdlName)==4);%#ok

end

function file=loc_preProcess(slBlockFile)

    if strcmp(slBlockFile(end-1:end),'.m')
        file=fileread(slBlockFile);
    else
        file=matlab.internal.getCode(slBlockFile);
    end
    idx=regexp(file,'^\s*function\s+blkStruct\s*=\s*slblocks','end','lineanchors');

    if(idx)
        file(1:idx(1))=[];
    end
end












