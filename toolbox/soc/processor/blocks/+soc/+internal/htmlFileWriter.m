classdef(Sealed=false)htmlFileWriter<matlab.mixin.SetGet





    properties(Access='public')
        FID={};
        FileName='';
        Title='';
        FileLines={};
        FileProlog={'<!DOCTYPE HTML>',...
        '<html lang="en">',...
        '<HEAD>',...
        '<meta charset="utf-8">',...
        '<link rel="stylesheet" href="style.css">',...
        '<script src="script.js"></script>',...
        '</HEAD>',...
        '<BODY BGCOLOR="FFFFFF">',...
'<HR>'...
        };

        FileEpilog={...
        '<HR>',...
        '</BODY>',...
'</HTML>'...
        };
    end
    methods(Access='public')
        function h=htmlFileWriter(fileName)
            [h.FID,message]=fopen(fileName,'w');
            assert(h.FID~=-1,message);
            h.FileName=fileName;
        end
        function writeLine(h,line)
            h.FileLines{end+1}=sprintf('<BR>%s\n',line);
        end
        function writeLineStrong(h,line)
            h.FileLines{end+1}=sprintf('<BR><strong>%s</strong>\n',line);
        end
        function writeNoBRLine(h,line)
            h.FileLines{end+1}=sprintf('%s\n',line);
        end
        function writeNoBRLineStrong(h,line)
            h.FileLines{end+1}=sprintf('<strong>%s</strong>\n',line);
        end
        function startParagraph(h)
            h.FileLines{end+1}=sprintf('<P>\n');
        end
        function writeTitle(h,line)
            h.FileLines{end+1}=sprintf('<TITLE>%s</TITLE>\n',line);
        end
        function writeHeader(h,line)
            h.FileLines{end+1}=sprintf('<H1>%s</H1>\n',line);
        end
        function writeMediumHeader(h,line)
            h.FileLines{end+1}=sprintf('<H2>%s</H2>\n',line);
        end
        function writeTable(h,rowHeads,colHeads,data)
            lbl={'Fail','Pass'};

            h.writeNoBRLine('<table border=1>');
            str='';
            for icol=1:numel(colHeads)
                str=sprintf('%s<td>%s</td>',str,colHeads{icol});
            end
            h.writeNoBRLine(['<tr><td></td>',str,'</tr>']);
            for irow=1:numel(rowHeads)
                str='';
                for icol=1:numel(colHeads)
                    thisData=data{irow,icol};
                    fstr='%16.6f';
                    if~isnumeric(thisData),fstr='%s';end
                    if isequal(colHeads{icol},'Outcome')
                        thisData=lbl{thisData+1};
                        fstr='%s';
                    end
                    str=sprintf(['%s<td>',fstr,'</td>'],str,thisData);
                end
                h.writeNoBRLine(['<tr><td>',rowHeads{irow},'</td>',str,'</tr>']);
            end
            h.writeNoBRLine('</table>');
        end
        function writeOutFile(h)
            h.writeOutSection(h.FileProlog);
            h.writeOutSection(h.FileLines);
            h.writeOutSection(h.FileEpilog);
            fclose(h.FID);
        end
        function writeImage(h,imageFile)
            h.writeNoBRLine(['<BR><IMG SRC="',imageFile,'" ALT="some text" WIDTH=320 HEIGHT=200>']);
        end
        function writeImagesHorizontal(h,imageFiles)
            h.writeNoBRLine('<div id="banner" style="overflow: hidden; display: flex; justify-content:flex-start;">');
            for i=1:numel(imageFiles)
                h.writeNoBRLine('<div class="" style="max-width: 100%; max-height: 100%;">');
                h.writeNoBRLine(['<img src ="',imageFiles{i},'" width="384" height="384">']);
                h.writeNoBRLine('</div>');
            end
            h.writeNoBRLine('</div>');
        end
    end
    methods(Access='private')
        function writeOutSection(h,section)
            for i=1:numel(section)
                fprintf(h.FID,'%s\n',section{i});
            end
        end
    end
end
