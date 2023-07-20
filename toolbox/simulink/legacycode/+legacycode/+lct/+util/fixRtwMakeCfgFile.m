function[status,msg,needFix]=fixRtwMakeCfgFile(fpath,checkOnly)





    narginchk(1,2);
    validateattributes(fpath,...
    {'char','string'},{'scalartext'},'legacycode.lct.util.fixRtwMakeCfgFile','',1);
    fpath=convertStringsToChars(fpath);

    if nargin<2
        checkOnly=false;
    else
        validateattributes(checkOnly,{'logical','numeric'},{'scalar','binary'});
        checkOnly=logical(checkOnly);
    end

    status=0;
    msg=[];
    needFix=false;



    [fid,errMsg]=fopen(fpath,'rt');
    if~isnumeric(fid)||fid<0
        [fpath,fname,fext]=fileparts(fpath);
        msg=message('Simulink:tools:LCTErrorCannotOpenFile',...
        fullfile(fpath,fname),fext(2:end),['(',errMsg,')']);
        status=2;
        return
    end
    txt=fread(fid,'*char')';
    fclose(fid);


    mt=mtree(txt,'-com');
    errs=mtfind(mt,'Kind','ERR');
    if~isnull(errs)
        msg=message('Simulink:tools:LCTCannotParseFileContents',fpath);
        status=2;
        return
    end


    buggyFcnName='verify_simulink_version';
    fcnCallNode=mtfind(mt,'Kind','CALL','Left.Fun',buggyFcnName);
    fcnDefNode=mtfind(mt,'Kind','FUNCTION','Fname.String',buggyFcnName);
    if isnull(fcnCallNode)||isnull(fcnDefNode)
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end


    fcnCallIdx=indices(fcnCallNode);
    fcnDefNodeIdx=indices(fcnDefNode);
    if numel(fcnCallIdx)~=1||numel(fcnDefNodeIdx)~=1
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end


    if~isnull(Right(fcnCallNode))||~isnull(Ins(fcnDefNode))||~isnull(Outs(fcnDefNode))
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end


    n=Body(root(mt));
    isFound=false;
    while~isnull(n)
        if n==Parent(fcnCallNode)
            isFound=true;
            break
        end
        n=Next(n);
    end
    if~isFound
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end


    str=mtfind(Tree(fcnDefNode),'Kind','CHARVECTOR');
    if isnull(str)
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end
    str=strings(str);
    if~all(ismember({'''Simulink:tools:LCTErrorBadSimulinkVersion''','''simulink'''},str))
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end

    str=mtfind(Tree(fcnDefNode),'String',{'DAStudio','error','ver'});
    if isnull(str)
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end
    if~isequal(sort(strings(str)),sort({'DAStudio','error','ver'}))
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end

    varNodes=mtfind(Tree(fcnDefNode),'Isvar',true);
    vars=unique(strings(varNodes));
    if~all(ismember({'factor','ii','slVer','thisVer'},vars))
        msg=message('Simulink:tools:LCTFileNotGeneratedByLCT',fpath);
        status=1;
        return
    end


    needFix=true;
    if checkOnly
        return
    end


    txt=regexp(txt,newline,'split');
    badIdx=lineno(Body(fcnDefNode)):lineno(last(Body(fcnDefNode)));
    txt(badIdx)=[];
    newTxt=[...
    'slVerStruct = ver(''simulink'');',newline,...
    'slVer = str2double(strsplit(slVerStruct.Version,''.''));',newline,...
    'if slVer(1)<6 || (slVer(1)==6 && slVer(2)<4)',newline,...
    '    DAStudio.error(''Simulink:tools:LCTErrorBadSimulinkVersion'', slVerStruct.Version);',newline,...
    'end',newline,newline...
    ];
    txt=[txt(1:badIdx(1)-1),...
    {newTxt},...
    txt(badIdx(1)-1:end)];
    txt=strjoin(txt,newline);


    mt=mtree(txt);
    if~isnull(mtfind(mt,'Kind','ERR'))
        msg=message('Simulink:tools:LCTBadFixedFileContents',fpath);
        status=2;
        return
    end


    [fid,errMsg]=fopen(fpath,'wt');
    if~isnumeric(fid)||fid<0
        [fpath,fname,fext]=fileparts(fpath);
        msg=message('Simulink:tools:LCTErrorCannotOpenFile',...
        fullfile(fpath,fname),fext(2:end),['(',errMsg,')']);
        status=2;
        return
    end
    fwrite(fid,txt,'*char');
    fclose(fid);
