classdef FrameTextInfo<handle

    properties
        System;
        Time=datestr(now,15);
        Date=datestr(now,1);
        Page=1;
        NumberOfPages=1;
    end

    properties(Constant,Hidden)
        PAGE='%<page>';
        NPAGES='%<npages>';
        DATE='%<date>';
        TIME='%<time>';
        SYSTEM='%<system>';
        FULLSYSTEM='%<fullsystem>';
        FILENAME='%<filename>';
        FULLFILENAME='%<fullfilename>';
        BLOCKDIAGRAM='%<blockdiagram>';
    end

    methods
        function pTextInfo=parseTextInfo(this,textInfo)
            if isempty(this.System)
                error('tbd - empty system');
            end

            pTextInfo=textInfo;
            sysIndex=0;
            for i=1:length(pTextInfo)
                if strcmp(pTextInfo(i).String,this.BLOCKDIAGRAM)
                    sysIndex=i;
                    continue;
                end

                isTex=strcmpi(pTextInfo(i).InterpretMode,'INTERPRET_TEX');

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.PAGE,num2str(this.Page),isTex);

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.NPAGES,num2str(this.NumberOfPages),isTex);

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.DATE,this.Date,isTex);

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.TIME,this.Time,isTex);

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.SYSTEM,SLPrint.Utils.GetSystemName(this.System),isTex);

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.FULLSYSTEM,SLPrint.Utils.GetFullSystemName(this.System),isTex);

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.FILENAME,SLPrint.Utils.GetFileName(this.System),isTex);

                pTextInfo(i).String=this.parse(...
                pTextInfo(i).String,...
                this.FULLFILENAME,SLPrint.Utils.GetFullFileName(this.System),isTex);

            end

            if(sysIndex>0)

                pTextInfo(sysIndex)=[];
            end
        end

        function incrementPage(this)
            if(this.Page>=this.NumberOfPages)
                error('tbd - Can not increment pass total number of pages');
            end
            this.Page=this.Page+1;
        end

        function set.System(this,sys)
            this.System=SLPrint.Resolver.resolveToUDD(sys,true);
        end
    end

    methods(Static,Access=private)
        function out=parse(in,keyword,val,isTeX)
            [rows,~]=size(in);
            out=in(1,:);
            for i=2:rows
                out=sprintf('%s\n%s',out,in(i,:));
            end;
            if(isTeX)

                escaped=regexprep(val,'([\_\{\}\^\\])','\\$1');
                out=strrep(out,keyword,escaped);
            else
                out=strrep(out,keyword,val);
            end
        end

    end

end