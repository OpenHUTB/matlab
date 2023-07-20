


classdef CheckRepository<handle

    properties(Access=public)
checks
    end

    methods(Access=public)
        function this=CheckRepository()
            this.checks=[];
        end

        function b=hasErrors(this,chks)%#ok<INUSL>
            b=false;
            for ii=1:length(chks)
                if(strcmpi(chks(ii).level,'Error'))
                    b=true;
                    break;
                end
            end
        end

        function updateChecks(this,fileName,lineNum,message,msgId,level)

            if isempty(this.checks)
                idx=1;
            else
                idx=length(this.checks)+1;
            end

            this.checks(idx).fileName=fileName;
            this.checks(idx).lineNum=lineNum;
            this.checks(idx).colNum=0;
            this.checks(idx).level=level;
            this.checks(idx).MessageID=msgId;
            this.checks(idx).message=message;
        end

        function chks=finalizeChecks(this)%#ok<MANU>


            scrChecks=[];

            singleton=emlhdlcoder.EmlChecker.CheckRepository.instance;
            cgChecks=singleton.cgirChecks;

            chks=[scrChecks(:);cgChecks(:)];

        end


        function dispChecks(this)
            chks=this.checks;
            for ii=1:length(chks)
                chk=chks(ii);
                disp(sprintf('%s:%d %s: %s',chk.fileName,chk.lineNum,chk.level,chk.message));%#ok<DSPS>
            end
        end

    end




    properties(Access=public)
        cgirChecks={};
    end
    properties(GetAccess=public,Constant)
        instance=emlhdlcoder.EmlChecker.CheckRepository;
    end
    methods(Access=public,Static)


        function clearCgirChecks()
            singleton=emlhdlcoder.EmlChecker.CheckRepository.instance;
            singleton.cgirChecks=[];
        end

        function addCgirCheck(check,messageID,level,fileName,lineNum,colNum)
            singleton=emlhdlcoder.EmlChecker.CheckRepository.instance;
            idx=length(singleton.cgirChecks)+1;
            singleton.cgirChecks(idx).fileName=fileName;
            singleton.cgirChecks(idx).lineNum=lineNum;
            singleton.cgirChecks(idx).colNum=colNum;
            singleton.cgirChecks(idx).level=level;
            singleton.cgirChecks(idx).MessageID=messageID;
            singleton.cgirChecks(idx).message=check;
        end

        function cks=getCgirChecks()
            singleton=emlhdlcoder.EmlChecker.CheckRepository.instance;
            cks=singleton.cgirChecks;
        end

        function he=cgirChecksHasErrors()
            singleton=emlhdlcoder.EmlChecker.CheckRepository.instance;
            cks=singleton.cgirChecks;
            he=false;
            for ii=1:length(cks)
                if(strcmpi(cks(ii).level,'Error'))
                    he=true;
                    break;
                end
            end
        end

        function runStaticChecks(tb_name,design_name)%#ok<INUSL>            
            designf=which(design_name);
            emlhdlcoder.EmlChecker.CheckRepository.checkControlFlowKeywords(design_name,designf);
        end

        function checkControlFlowKeywords(design_name,designf)
            design_script=fileread(designf);
            checks_kw_stmts=hdlcodingstd.STARCrules.find_and_flag_while_break_cont_ret_parfor_stmts(design_script,design_name,'MLHDLC');
            arrayfun(@(x)emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(x.message,x.MessageID,x.level,x.fileName,x.lineNum,x.colNum),checks_kw_stmts);
        end
    end

end
