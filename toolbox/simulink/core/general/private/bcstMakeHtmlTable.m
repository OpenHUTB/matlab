function out=bcstMakeHtmlTable(libModel,table,do_unknown,libData)




    copyright='Copyright 2005-2019 The MathWorks, Inc.';

    out='';
    if isempty(table)
        return;
    end

    if nargin<4
        libData=[];
    end
    isAllLibs=strcmp(libModel,'*All*');




    doIo=true;
    doSgn=true;



    if slfeature('SLHalfPrecisionSupport')>0

        capNames={...
        'double','single','boolean','integer','fixedpt','half','enumerated','string','bus','image',...
        'codegen','multidimension','variablesize','foreach','symbolicdimension'};
    else
        capNames={...
        'double','single','boolean','integer','fixedpt','enumerated','string','bus','image',...
        'codegen','multidimension','variablesize','foreach','symbolicdimension'};
    end
    capHeads=strcat('HtHead',capNames);
    capColumns=cell2struct({capNames{:};capHeads{:}},{'cap','header'},1);


    if isAllLibs
        topName='';
        isLibrary=true;
    else
        topModel=bdroot(libModel);
        topName=get_param(topModel,'Name');

        isLibrary=bdIsLibrary(topModel);
    end

    blockMarks.yes=getHtml('HtBlockIsSupported');
    if nargin>=3&&do_unknown
        blockMarks.unknown=getHtml('HtSupportUnknown');
        blockMarks.do_unknown=true;
    else
        blockMarks.unknown='&nbsp;';
        blockMarks.do_unknown=false;
    end
    blockMarks.open=getHtml('HtOpenParen');
    blockMarks.close=getHtml('HtCloseParen');
    blockMarks.separator=getHtml('HtSeparator');
    blockMarks.no='';
    blockMarks.doFootId=false;

    if doIo||doSgn
        blockMarks.do_suffix=true;
        if doIo
            blockMarks.in=getHtml('HtBlockSupportsIn');
            blockMarks.out=getHtml('HtBlockSupportsOut');
            blockMarks.io=getHtml('HtBlockSupportsIO');
        end
        if doSgn
            blockMarks.sgn=getHtml('HtBlockSupportsSgn');
            blockMarks.uns=getHtml('HtBlockSupportsUns');
            blockMarks.sgun=getHtml('HtBlockSupportsSgUn');
        end
    else
        blockMarks.do_suffix=false;
    end

    numCaps=length(capColumns);

    noteInfo.footNum=0;
    noteInfo.feet=[];
    noteInfo.hasIO=false;
    noteInfo.hasSU=false;

    currentLib='***';
    sublibSize=0;
    sublibNum=0;
    sublibBlocks={};
    html={};


    for tabIdx=1:length(table)
        oneCap=table(tabIdx);
        sublibrary=getPath(oneCap);

        if~strcmp(sublibrary,currentLib)
            sublibNum=sublibNum+1;
            if sublibNum>1


                sublib=html_sublib(topName,currentLib,sublibSize,libData);
                html={html{:},sublib{:},sublibBlocks{:}};
            end
            currentLib=sublibrary;

            tabhead=html_table_head(capColumns);
            html={html{:},tabhead{:}};

            sublibSize=0;
            sublibBlocks={};
        end


        [thisBlock,numRows,noteInfo]=html_block(...
        isLibrary,...
        oneCap,...
        capColumns,...
        sublibSize==0,...
        noteInfo,...
        blockMarks);


        sublibBlocks={sublibBlocks{:},thisBlock{:}};
        sublibSize=sublibSize+numRows;
    end


    sublib=html_sublib(topName,currentLib,sublibSize,libData);




    topPage=html_top(libModel,copyright,noteInfo,blockMarks,numCaps,libData);


    bottom=html_bottom(noteInfo,blockMarks);


    html={...
    topPage{:}...
    ,html{:}...
    ,sublib{:}...
    ,sublibBlocks{:}...
    ,bottom{:}...
    };


    for htmlIdx=1:length(html)
        out=[out,sprintf('%s',html{htmlIdx})];%#ok<AGROW>
    end

    out=strrep(out,'\n',sprintf('\n'));



    function[s,noteInfo]=html_cap(cap,foot,noteInfo,blockMarks)


        if~strcmp(cap,'No')||~isempty(foot)
            s=[blockMarks.(lower(cap))];
            footNum=0;
            footWork=foot;
            while~isempty(footWork)
                footNum=footNum+1;
                if footNum==1
                    s=[s,'&nbsp;<span class="footref">',blockMarks.open];%#ok<AGROW>
                else
                    s=[s,blockMarks.separator,'&nbsp;'];%#ok<AGROW>
                end
                [split]=regexp(footWork,'^([a-zA-Z0-9_]+)(, *|)(.*)$','tokens');
                oneFoot=split{1}{1};
                footWork=split{1}{3};
                noteInfo=processFootnote(noteInfo,oneFoot);
                oneFoot=num2str(noteInfo.feet.(oneFoot));
                s=[s,'<a href="#F',oneFoot,'">',oneFoot,'</a>'];%#ok<AGROW>
            end
            if footNum>0
                s=[s,blockMarks.close,'</span>'];
            end
        else
            s='&nbsp;';
        end

        function s=html_top(modelName,copyright,noteInfo,blockMarks,numCaps,libData)

            if isfield(noteInfo.feet,'FnNot4ProdCode')

                prodcode=[' ',getHtml('HtProdCode',noteInfo.feet.('FnNot4ProdCode'),noteInfo.feet.('FnNot4ProdCode'))];
            else
                prodcode='';
            end

            useName=modelName;

            if strcmp(modelName,'*All*')
                hTitle=getHtml('HtTitleForAll');
                hDesc1A=getHtml('HtTableDesc1All');
            elseif~strcmpi(modelName,'simulink')
                if~isempty(libData)&&libData.hasLong&&isfield(libData.longs,modelName)
                    useName=libData.longs.(modelName);
                end

                hTitle=getHtml('HtTitleForModel',useName);
                hDesc1A=getHtml('HtTableDesc1Generic');
            else
                hTitle=getHtml('HtTitle');
                hDesc1A=getHtml('HtTableDesc1SL');
            end

            hCharset=getHtml('HtCharset');
            hFontFam=getHtml('HtFontFamily');
            hFontSize=strtrim(getHtml('HtFontSize'));
            hFontSizeCss='';
            if~isempty(hFontSize)
                hFontSizeCss=['font-size:   ',hFontSize,';\n'];
            end

            if strcmp(modelName,'*All*')
                hTableTitle=getHtml('HtAllLib');
            else
                topModel=bdroot(modelName);
                if strcmp(topModel,'simulink')
                    hTableTitle=getHtml('HtSimLib');
                else
                    isLib=bdIsLibrary(topModel);
                    if isLib
                        if strcmp(useName,modelName)
                            hTableTitle=[topModel,' ',getHtml('HtLibrary')];
                        else
                            hTableTitle=useName;
                        end
                    else
                        hTableTitle=[topModel,' ',getHtml('HtModel')];
                    end
                end
            end


            hLegend=[getHtml('HtTableLegendHead'),'\n<ul>\n'...
            ,'<li>',getHtml('HtTableLegendStd'),'</li>\n'];

            if noteInfo.hasIO
                hLegend=[hLegend,'<li>',getHtml('HtTableLegendHasIO'),'</li>\n'];
            end

            if noteInfo.hasSU
                hLegend=[hLegend,'<li>',getHtml('HtTableLegendHasSU'),'</li>\n'];
            end
            hLegend=[hLegend,'</ul>\n'];


            if blockMarks.do_unknown
                hUnknownDesc=['<p>',getHtml('HtTableDescUnknown',blockMarks.unknown),'</p>\n'];
            else
                hUnknownDesc='';
            end




            if ispc
                bulletSize='150';
            else
                bulletSize='100';
            end


            css={...
'<style type="text/css">\n'...
            ,'body {font-family: ',hFontFam,';\n'...
            ,'      color:        #000000;\n'...
            ,hFontSizeCss...
            ,'      background-color: #FFFFFF\n'...
            ,'     }\n'...
            ,'title,h2,h3 {color: #990000}\n'...
            ,'th {text-align: center}\n'...
            ,'td.tabletitle {border-bottom:  1px solid gray;\n'...
            ,'               border-color:   #999999;\n'...
            ,'               vertical-align: top;\n'...
            ,'               color:          #990000;\n'...
            ,'               font-weight:    bold;\n'...
            ,'               text-align:     left}\n'...
            ,'td.tablesublib {border-color:   #999999;\n'...
            ,'                font-weight:    bold;\n'...
            ,'                vertical-align: top}\n'...
            ,'td.support   {text-align:     center;\n'...
            ,'              vertical-align: middle}\n'...
            ,'ol.footlist  {list-style:     decimal outside none;}\n'...
            ,'div.footid   {font-family:    Arial, Helvetica, sans-serif}\n'...
            ,'span.footref {font-size:      90%;\n'...
            ,'              position:       relative;\n'...
            ,'              bottom:         2}\n'...
            ,'span.bullet {font-size:       ',bulletSize,'%}\n'...
            ,'</style>\n'...
            };
            s={...
            ['<!-- ',copyright,' -->\n']...
            ,'<html>\n'...
            ,'<head>\n'...
            ,css{:}...
            ,'<meta http-equiv="Content-Type" content="text/html;" charset="',hCharset,'" />\n'...
            ,'<title>',hTitle,'</title>\n'...
            ,'</head>\n'...
            ,'<body>\n'...
            ,'<h2>',hTitle,'</h2>\n'...
            ,'<p>',hDesc1A,' ',getHtml('HtTableDesc1B'),'\n'...
            ,prodcode,'</p>\n'...
            ,'<p>',getHtml('HtTableDesc2'),'</p>\n'...
            ,'<p>',hLegend,'</p>\n'...
            ,hUnknownDesc...
            ,'<table width="740" border="8">\n'...
            ,'  <colgroup span="1" width="100">\n'...
            ,'  <colgroup span="1" width="0*">\n'...
            ,'  <colgroup span="',num2str(numCaps),'" width="0*">\n'...
            ,'  <tr> \n'...
            ,'    <td class="tabletitle" colspan="',num2str(numCaps+2),'">\n'...
            ,'     ',hTableTitle,'\n'...
            ,'    </td>\n'...
            ,'  </tr>\n'...
            };

            function s=html_table_head(capColumns)

                s={...
' <tr> \n'...
                ,'    <th>',getHtml('HtSublibrary'),'</th>\n'...
                ,'    <th>',getHtml('HtBlock'),'</th>\n'...
                };
                for capIdx=1:length(capColumns)
                    s={s{:}...
                    ,'    <th>',getHtml(capColumns(capIdx).header),'</th>\n'...
                    };
                end

                s={s{:},'</tr>\n'};

                function s=html_sublib(topName,sublibName,sublibCount,libData)


                    if sublibCount>0


                        didLong=false;
                        if~isempty(libData)&&libData.hasLong
                            topLibName=regexp(sublibName,'^[^/]+','match');
                            topLibName=topLibName{1};
                            if isfield(libData.longs,topLibName)
                                longLibName=libData.longs.(topLibName);
                                sublibName=regexprep(sublibName,['^',topLibName],longLibName);
                                didLong=true;
                            elseif strcmp(topLibName,'simulink')

                                sublibName=regexprep(sublibName,['^',topLibName],'Simulink');
                                didLong=true;
                            end
                        end

                        if isempty(topName)||didLong

                            basename=sublibName;
                        elseif length(sublibName)>length(topName)


                            basename=regexprep(sublibName,['^',topName,'/'],'');
                        else
                            basename=sublibName;
                        end


                        basename=regexprep(basename,'//','/');

                        s={...
'    <tr>\n'...
                        ,['        <td class="tablesublib" rowspan="',num2str(sublibCount),'">\n']...
                        ,['                 ',basename,' \n']...
                        ,'         </td>\n'...
                        };
                    else
                        s='';
                    end

                    function[s,numRows,noteInfo]=html_block(isLibrary,cap,columns,...
                        firstRow,noteInfo,blockMarks)


                        doAll=false;
                        doCurrent=false;
                        startIdx=1;
                        stopIdx=1;
                        indexSet=startIdx:stopIdx;

                        if isLibrary
                            allSets=cap.CapabilitySets;
                            if isempty(allSets)

                                allSets=CapSet;
                            end


                            if length(allSets)>1
                                [doAll,doCurrent,indexSet,displayModeName]=dealWithMultiple(cap.BlockPath,cap.CapabilitySets);

                                stopIdx=length(indexSet);
                            end
                        else


                            doCurrent=true;
                        end

                        s={};


                        for jj=1:length(indexSet)
                            setIdx=indexSet(jj);
                            if doAll
                                oneSet=allSets(setIdx);
                            elseif doCurrent
                                oneSet=cap.getSet(cap.CurrentMode);
                            else
                                oneSet=cap.getSet();
                            end


                            if(isempty(oneSet.ModeName)||isequal(displayModeName,false))
                                displayName=getName(cap);
                            else
                                displayName=[getName(cap),' '...
                                ,blockMarks.open,oneSet.ModeName,blockMarks.close];
                            end



                            if regexp(displayName,'^(In|Out)1$')
                                if regexp(cap.BlockPath,'^simulink/.*/(In|Out)1$')
                                    displayName=regexprep(displayName,'^(In|Out)1$','$11 ($1port)');
                                end
                            end

                            if firstRow

                                firstRow=false;
                            else
                                s={s{:},'<tr>\n'};
                            end


                            s={s{:}...
                            ,'    <td>\n'...
                            ,'      <a href="matlab:'...
                            ,'bcstHighLight(''',regexprep(cap.BlockPath,'\s',' '),''');">\n'...
                            ,'           ',displayName,'</a></td>\n'...
                            };


                            for capIdx=1:length(columns)
                                capName=columns(capIdx).cap;
                                oneFootnote=oneSet.footnotes(capName);


                                if strcmp(capName,'codegen')&&...
                                    strcmpi(oneSet.supports(capName),'Yes')&&...
                                    strcmpi(oneSet.supports('production'),'No')&&...
                                    isempty(strfind(oneFootnote,'FnNot4ProdCode'))
                                    if isempty(oneFootnote)
                                        oneFootnote='FnNot4ProdCode';
                                    else
                                        oneFootnote=[oneFootnote,',FnNot4ProdCode'];%#ok<AGROW>
                                    end
                                end
                                if blockMarks.do_suffix
                                    [supportString,oneFootnote,hasIO,hasSU]=...
                                    HandleSuffix(oneSet,capName,oneFootnote);
                                    if hasIO
                                        noteInfo.hasIO=true;
                                    end
                                    if hasSU
                                        noteInfo.hasSU=true;
                                    end
                                else
                                    supportString=oneSet.supports(capName);
                                end
                                [capString,noteInfo]=...
                                html_cap(supportString,oneFootnote,...
                                noteInfo,blockMarks);
                                s={s{:},['    <td class="support">',capString,'</td>\n']};
                            end

                            s={s{:},'</tr>\n'};

                        end

                        numRows=stopIdx-startIdx+1;

                        function s=html_bottom(noteInfo,blockMarks)

                            if isfield(noteInfo.feet,'FnNot4ProdCode')

                                crits={...
                                '<h3><a name="criteria"></a>',getHtml('HtCriteriaTitle'),'</h3>\n'...
                                ,'<p>',getHtml('HtCritTop'),'</p>'...
                                ,'<ul>\n'...
                                ,'  <li>',getHtml('HtCritList1'),'</li>\n'...
                                ,'  <li>',getHtml('HtCritList2'),'</li>\n'...
                                ,'  <li>',getHtml('HtCritList3'),'</li>\n'...
                                ,'</ul>\n'...
                                };
                            else
                                crits={''};
                            end

                            s={...
'</table>\n'...
                            ,crits{:}...
                            };

                            if(noteInfo.footNum>0)
                                s={s{:}...
                                ,'<h3><a name="footnotes"></a>',getHtml('HtFootnotes'),'</h3>\n'...
                                ,'<ol class="footlist">\n'};
                                notes=fields(noteInfo.feet);
                                for footIdx=1:noteInfo.footNum
                                    if blockMarks.doFootId
                                        s{end+1}=sprintf(['  <li><a name="F%d"></a>%s %s'...
                                        ,'<div class="footid">%s</div>%s</li>\n'],...
                                        footIdx,...
                                        get_footnote(notes{footIdx}),...
                                        blockMarks.open,...
                                        notes{footIdx},...
                                        blockMarks.close);%#ok<AGROW>
                                    else
                                        s{end+1}=sprintf('  <li><a name="F%d"></a>%s</li>\n',...
                                        footIdx,...
                                        get_footnote(notes{footIdx}));%#ok<AGROW>
                                    end
                                end
                                s{end+1}='</ol>\n';
                            end

                            s={s{:}...
                            ,'</body>\n'...
                            ,'</html>\n'...
                            };

                            function footnote=get_footnote(footId)





                                if strfind(footId,'_')

                                    messageStr=strrep(footId,'_',':bcst:');
                                else

                                    messageStr=['Simulink:bcst:',footId];
                                end
                                [footnote,realId]=DAStudio.message(messageStr);

                                if~strcmp(realId,messageStr)||~isempty(strfind(footnote,messageStr))
                                    DAStudio.error('Simulink:bcst:ErrUnknownFootnoteId',footId);
                                end

                                function ht=getHtml(htmlId,varargin)



                                    if strfind(htmlId,':')
                                        fullId=htmlId;
                                    else
                                        fullId=['Simulink:bcst:',htmlId];
                                    end
                                    [ht,realId]=DAStudio.message(fullId,varargin{:});
                                    if~strcmp(fullId,realId)
                                        DAStudio.error('Simulink:bcst:ErrUnknownHtmlId',htmlId);
                                    end


                                    function path=getPath(inCap)
                                        path=get_param(inCap.BlockPath,'Parent');
                                        path=regexprep(path,'\s',' ');

                                        function name=getName(inCap)
                                            name=get_param(inCap.BlockPath,'Name');
                                            name=regexprep(name,'\s',' ');

                                            function noteInfo=processFootnote(noteInfo,footNote)



                                                if~isfield(noteInfo.feet,footNote)

                                                    noteInfo.footNum=noteInfo.footNum+1;

                                                    noteInfo.feet.(footNote)=noteInfo.footNum;
                                                end

                                                function[doAll,doCurrent,indexSet,displayModeName]=dealWithMultiple(blockPath,sets)


                                                    if strcmpi(get_param(blockPath,'Mask'),'on')
                                                        blockType=get_param(blockPath,'MaskType');
                                                    else
                                                        blockType=get_param(blockPath,'BlockType');
                                                    end

                                                    dealTable={...
...
                                                    'Math',true,false,[2:7,10:length(sets)],true;...
                                                    'Sqrt',false,true,[],false;...
                                                    'Sum',false,true,[],false;...
                                                    'Product',true,false,[],true;...
                                                    'PID 1dof',false,true,[],true;...
                                                    'PID 2dof',false,true,[],true;...
                                                    };

                                                    idx=find(strcmp(dealTable(:,1),blockType));

                                                    indexSet=1;

                                                    if isempty(idx)

                                                        doAll=false;
                                                        doCurrent=false;
                                                        displayModeName=false;
                                                    else
                                                        doAll=dealTable{idx,2};
                                                        doCurrent=dealTable{idx,3};
                                                        if doAll
                                                            if(isempty(dealTable{idx,4}))
                                                                indexSet=2:length(sets);
                                                            else
                                                                indexSet=dealTable{idx,4};
                                                            end
                                                        end
                                                        displayModeName=isequal(dealTable{idx,5},true);
                                                    end

                                                    return

                                                    function[supportString,footNote,hasIO,hasSU]=HandleSuffix(cap,capName,footNote)
                                                        mainSup=cap.supports(capName);
                                                        inSup=cap.supports([capName,'In']);
                                                        outSup=cap.supports([capName,'Out']);
                                                        sgnSup=cap.supports([capName,'Sgn']);
                                                        unsSup=cap.supports([capName,'Uns']);
                                                        inFoot=cap.footnotes([capName,'In']);
                                                        outFoot=cap.footnotes([capName,'Out']);
                                                        sgnFoot=cap.footnotes([capName,'Sgn']);
                                                        unsFoot=cap.footnotes([capName,'Uns']);


                                                        support=0;
                                                        if strcmp(inSup,'Yes'),support=support+1;end
                                                        if strcmp(outSup,'Yes'),support=support+2;end
                                                        if strcmp(sgnSup,'Yes'),support=support+4;end
                                                        if strcmp(unsSup,'Yes'),support=support+8;end
                                                        if support==0&&...
                                                            strcmp(mainSup,'Yes'),support=support+128;end

                                                        hasIO=bitand(support,3);
                                                        hasSU=bitand(support,12);

                                                        switch support
                                                        case 0
                                                            supportString='No';
                                                        case 1
                                                            supportString='In';
                                                        case 2
                                                            supportString='Out';
                                                        case 3
                                                            supportString='IO';
                                                        case 4
                                                            supportString='Sgn';
                                                        case 8
                                                            supportString='Uns';
                                                        case 12
                                                            supportString='SgUn';
                                                        otherwise
                                                            supportString='Yes';
                                                        end


                                                        if~isempty(inFoot)
                                                            if isempty(footNote)
                                                                footNote=inFoot;
                                                            else
                                                                footNote=[footNote,',',inFoot];
                                                            end
                                                        end

                                                        if~isempty(outFoot)
                                                            if isempty(footNote)
                                                                footNote=outFoot;
                                                            else
                                                                footNote=[footNote,',',outFoot];
                                                            end
                                                        end

                                                        if~isempty(sgnFoot)
                                                            if isempty(footNote)
                                                                footNote=sgnFoot;
                                                            else
                                                                footNote=[footNote,',',sgnFoot];
                                                            end
                                                        end

                                                        if~isempty(unsFoot)
                                                            if isempty(footNote)
                                                                footNote=unsFoot;
                                                            else
                                                                footNote=[footNote,',',unsFoot];
                                                            end
                                                        end


