



classdef FilePosInfo<handle
    properties



PosInfo



LineToPosInfo
    end

    methods
        function obj=FilePosInfo()
            obj.PosInfo=struct('Line',[],...
            'SourceFile',{},...
            'SourceName',{},...
            'SourceLine',[]);
            obj.LineToPosInfo=[];
        end

        function[srcFile,srcLine,found]=getPosition(obj,lineNumber)
            found=false;
            srcFile='';
            srcLine=0;

            if lineNumber>0&&lineNumber<=numel(obj.LineToPosInfo)

                posIndex=obj.LineToPosInfo(lineNumber);
                if posIndex>0
                    srcFile=obj.PosInfo(posIndex).SourceName;
                    srcLine=obj.PosInfo(posIndex).SourceLine+(lineNumber-obj.PosInfo(posIndex).Line-1);

                    found=true;
                end
            end
        end

        function res=parseFile(obj,fileName)

            fid=fopen(fileName,'r','n','UTF-8');
            if fid>=0

                closeFile=onCleanup(@()fclose(fid));


                currentFile='';
                lineNum=0;

                line=fgetl(fid);
                while ischar(line)
                    lineNum=lineNum+1;

                    preprocInfo=regexp(line,'^#(line)?\s+(\d+)\s*(.*)','tokens');
                    if~isempty(preprocInfo)
                        preprocLine=str2double(preprocInfo{1}{2});
                        preprocFile=preprocInfo{1}{3};

                        if isempty(preprocFile)
                            preprocFile=currentFile;
                        else









                            preprocFileBytes=unicode2native(preprocFile);
                            preprocFile=native2unicode(polyspace.internal.getUnescapedBytes(char(preprocFileBytes)));
                            currentFile=preprocFile;
                        end


                        if numel(preprocFile)>2&&...
                            preprocFile(1)=='"'&&...
                            preprocFile(end)=='"'
                            preprocFile=preprocFile(2:end-1);
                        end

                        [~,name,ext]=fileparts(preprocFile);
                        preprocFileName=[name,ext];

                        if~isempty(preprocFile)
                            obj.PosInfo(end+1)=struct('Line',lineNum,...
                            'SourceFile',preprocFile,...
                            'SourceName',preprocFileName,...
                            'SourceLine',preprocLine);

                        end
                    end
                    line=fgetl(fid);
                end

                obj.buildLineToPosInfo(lineNum);

                res=true;
            else
                res=false;
            end
        end
    end

    methods(Access=private)
        function buildLineToPosInfo(obj,lineNum)
            obj.LineToPosInfo=zeros(lineNum,1);

            count=numel(obj.PosInfo);
            endIndex=lineNum;
            for ii=count:-1:1
                line=obj.PosInfo(ii).Line;

                obj.LineToPosInfo(line:endIndex)=ii;
                endIndex=line-1;
            end
        end
    end

end


