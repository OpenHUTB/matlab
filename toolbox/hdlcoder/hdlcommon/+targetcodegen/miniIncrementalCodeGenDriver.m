


classdef miniIncrementalCodeGenDriver<handle


    properties(SetAccess=protected,GetAccess=protected)
        artifacts={};
        signatureFile='signature.txt';
        signature='';
        debugLevel=0;
    end

    methods
        function this=miniIncrementalCodeGenDriver(artifacts,varargin)
            if(nargin>1)
                this.signatureFile=varargin{1};
            end
            this.artifacts=artifacts;
        end
    end

    methods(Abstract,Static)
        optFileName=retrieveOptFileName(cmd)
        signature=filterSignature(signatureIn);
    end

    methods(Access=private)
        function skip=checkIncrementCodegenArtifacts(this)
            skip=true;
            for i=1:length(this.artifacts)
                fileName=this.artifacts{i};
                if(exist(fileName,'file')~=2)
                    skip=false;
                    return;
                end
            end
        end
    end

    methods(Access=public)
        function retrieveSignature(this,cmd)

            optFileName=this.retrieveOptFileName(cmd);
            if(~isempty(optFileName));
                sig=sprintf('%s\n%s',cmd,fileread(optFileName));
            else
                sig=cmd;
            end
            this.signature=this.filterSignature(sig);
        end

        function writeIncrementCodegenSignature(this)
            fid=fopen(this.signatureFile,'w');
            if fid~=-1
                fprintf(fid,'%s',this.signature);
                fclose(fid);
            end
        end

        function printIncrementCodegenSignature(this)
            if(this.debugLevel==1)
                fprintf(1,'%%%%%%  TargetCodeGen Script Start  %%%%%%\n');
                fprintf(1,'%s\n',this.signature);
                fprintf(1,'%%%%%%  TargetCodeGen Script END    %%%%%%\n');
            end
        end

        function skip=checkIncrementCodegenStatus(this)
            skip=true;
            if(~this.checkIncrementCodegenArtifacts())
                skip=false;
                return;
            end
            if(~this.checkIncrementCodegenSignature())
                skip=false;
                return;
            end
        end

        function skip=checkIncrementCodegenSignature(this)
            if(exist(this.signatureFile,'file')~=2)
                skip=false;
                return;
            end

            fstr=fileread(this.signatureFile);
            tmpSignature=this.signature;
            tmpSignature=regexprep(tmpSignature,'\n','');
            tmpSignature=regexprep(tmpSignature,'\r','');
            fstr=regexprep(fstr,'\n','');
            fstr=regexprep(fstr,'\r','');

            skip=isequal(tmpSignature,fstr);
        end
    end
end



