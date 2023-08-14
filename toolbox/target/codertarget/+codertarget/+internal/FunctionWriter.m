classdef FunctionWriter<hgsetget






    properties(Access='public')
        FileName='';
        MainFcnName='';
    end
    properties(Access='public',Hidden)
        MyFcnMap=containers.Map('KeyType','char','ValueType','any');
    end
    methods(Access='public')
        function h=FunctionWriter
        end
        function addFcn(h,name,inArgs,outArgs)
            newFcn.Name=name;
            newFcn.InArgs=inArgs;
            newFcn.OutArgs=outArgs;
            newFcn.Body{1}=['function ',h.getOutArgStr(outArgs),name,h.getInArgStr(inArgs)];
            newFcn.Body{2}='end';
            h.MyFcnMap(name)=newFcn;
        end
        function deleteFcn(h,name)
            remove(h.MyFcnMap,name);
        end
        function addLineToFcn(h,name,line)
            fcn=h.MyFcnMap(name);
            fcn.Body=[fcn.Body(1:end-1),line,fcn.Body(end)];
            h.MyFcnMap(name)=fcn;
        end
        function addLineToFcnAt(h,name,pos,line)
            fcn=h.MyFcnMap(name);
            fcn.Body=[fcn.Body(1:pos-1);line;fcn.Body(pos:end)];
            h.MyFcnMap(name)=fcn;
        end
        function deleteLineFromFcnAt(h,name,pos)
            fcn=h.MyFcnMap(name);
            fcn.Body=[fcn.Body(1:pos-1);fcn.Body(pos+1:end)];
            h.MyFcnMap(name)=fcn;
        end
        function deserialize(h)
            fid=fopen(h.FileName,'r');
            if~isequal(fid,-1)
                allLines=textscan(fid,'%[^\n]');
                allLines=allLines{1};
                for i=1:numel(allLines)
                    thisLine=allLines{i};
                    [fcnName,inArgs,outArgs]=h.findFunctions(thisLine);
                    if~isempty(fcnName)
                        allLines2=allLines(i:end);
                        body=h.findFunctionBody(allLines2);
                        h.addFcn(fcnName,inArgs,outArgs);
                        fcn=h.MyFcnMap(fcnName);
                        fcn.Body=body;
                        h.MyFcnMap(fcnName)=fcn;
                        if isequal(i,1)
                            h.MainFcnName=fcnName;
                        end
                    end
                end
                fclose(fid);
            end
        end
        function serialize(h)
            fid=fopen(h.FileName,'w');
            if~isequal(fid,-1)
                fcnNames=h.MyFcnMap.keys;
                h.writeFcnBody(fid,h.MyFcnMap(h.MainFcnName).Body);
                fcnNames=setdiff(fcnNames,h.MainFcnName);
                for i=1:numel(fcnNames)
                    sep=sprintf(' \n%s %s','%',char(45*ones(1,73)));
                    h.writeLine(fid,sep);
                    h.writeFcnBody(fid,h.MyFcnMap(fcnNames{i}).Body);
                end
                fclose(fid);
            end
        end
    end
    methods(Access='private')
        function[fcnName,inArgs,outArgs]=findFunctions(~,line)




            fcnName='';
            inArgs=[];
            outArgs=[];
            keyStartPos=strfind(line,'function');
            if isempty(keyStartPos),return;end;
            line1=line(keyStartPos:end);
            pos1=strfind(line1,'=');
            if~isempty(pos1)
                pos1a=strfind(line1,' ');
                outArgs=strtrim(line1(pos1a:pos1-1));
                outArgs=strrep(outArgs,'[','');
                outArgs=strrep(outArgs,']','');
                outArgs=strrep(outArgs,',',' ');
                outArgs=textscan(outArgs,'%s');
                outArgs=outArgs{1};
            else
                pos1=strfind(line1,' ');
                outArgs=[];
            end
            keyEndPos=pos1-1;
            line2=line(keyEndPos+2:end);
            markers={' ','('};
            nameEndPos=length(line2);
            for i=1:numel(markers)
                pos2=strfind(line2,markers{i});
                if~isempty(pos2)
                    nameEndPos=pos2-1;
                    break;
                end
            end
            fcnName=line2(1:nameEndPos);
            line3=strtrim(line2(nameEndPos+1:end));
            if isempty(line3),return;end
            inArgs=strrep(line3,'(','');
            inArgs=strrep(inArgs,')','');
            inArgs=strrep(inArgs,',',' ');
            inArgs=textscan(inArgs,'%s');
            inArgs=inArgs{1};
        end
        function body=findFunctionBody(~,allLines)
            lineEndPos=numel(allLines);

            for i=2:numel(allLines)
                keyEndPos=strfind(allLines{i},'function');
                if~isempty(keyEndPos)
                    lineEndPos=i-1;
                    break;
                end;
            end

            lastLine=lineEndPos;
            for i=1:lineEndPos
                keyStartPos=strfind(allLines{i},'end');
                if~isempty(keyStartPos)
                    lastLine=i;
                end;
            end
            body=allLines(1:lastLine);
        end
        function argLine=getInArgStr(~,inArgs)
            argLine='';
            for i=1:numel(inArgs)
                argLine=strcat(argLine,inArgs{i});
                if~isequal(i,numel(inArgs))
                    argLine=strcat(argLine,',');
                end
            end
            if~isempty(argLine)
                argLine=strcat('(',argLine,')');
            end
        end
        function argLine=getOutArgStr(~,inArgs)
            argLine='';
            for i=1:numel(inArgs)
                argLine=strcat(argLine,inArgs{i});
                if~isequal(i,numel(inArgs))
                    argLine=strcat(argLine,',');
                end
            end
            if numel(inArgs)>1
                argLine=strcat('[',argLine,']');
            end
            if~isempty(argLine)
                argLine=strcat(argLine,' = ');
            end
        end
        function writeFcnBody(h,fid,fcnBody)
            for i=1:numel(fcnBody)
                h.writeLine(fid,fcnBody{i});
            end
        end
        function writeLine(~,fid,str)
            fprintf(fid,'%s\n',str);
        end
    end
end
