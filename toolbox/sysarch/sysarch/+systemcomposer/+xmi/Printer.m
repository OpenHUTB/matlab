classdef Printer<handle

    properties
PrintFileName
Verbose
IndentLevel
PrintFile

        TryOnly=false;
    end

    methods
        function this=Printer(pFile,verbose,tryOnly)
            this.PrintFile=pFile;
            this.IndentLevel=0;
            this.Verbose=verbose;
            this.TryOnly=tryOnly;

            if tryOnly

                this.Verbose=true;
            else
                this.PrintFile=fopen(pFile,'w');
            end

        end

        function delete(this)
            if~this.TryOnly
                fclose(this.PrintFile);
            end

        end

        function inStr=getIndent(this)
            if this.IndentLevel==0
                inStr="";
            else
                inStr='    ';
                inStr=inStr(ones(1,this.IndentLevel),:);
                inStr=string(inStr(:)');
            end
        end

        function startSection(this,secName)
            this.IndentLevel=0;

            if~this.TryOnly
                fprintf(this.PrintFile,"[START: %s] ============================\n",...
                secName);
            end
            if this.Verbose
                fprintf("[START: %s] ============================\n",...
                secName);
            end
        end

        function endSection(this,secName)
            if~this.TryOnly
                fprintf(this.PrintFile,"[END: %s] ==============================\n",...
                secName);
            end

            if this.Verbose
                fprintf("[END: %s] ==============================\n",...
                secName);
            end
        end

        function openScope(this,scStr)
            if~this.TryOnly
                fprintf(this.PrintFile,"%s%s{\n",this.getIndent(),scStr);
            end

            if this.Verbose
                fprintf("%s%s{\n",this.getIndent(),scStr);
            end
            this.IndentLevel=this.IndentLevel+1;
        end

        function closeScope(this,scStr)
            this.IndentLevel=this.IndentLevel-1;
            if~this.TryOnly
                fprintf(this.PrintFile,"%s} %s\n",this.getIndent(),scStr);
            end

            if this.Verbose
                fprintf("%s} %s\n",this.getIndent(),scStr);
            end
        end

        function print(this,pStr)
            if~this.TryOnly
                fprintf(this.PrintFile,"%s%s\n",this.getIndent(),pStr);
            end

            if this.Verbose
                fprintf("%s%s\n",this.getIndent(),pStr);
            end
        end
    end
end
