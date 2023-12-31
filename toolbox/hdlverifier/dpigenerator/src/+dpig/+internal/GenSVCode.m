


classdef GenSVCode<handle


    properties
        mText;
        mFileName;
        mFid=-1;
        mIndentLevel=0;
        mExistNames={};
        simulatorModeEnv='LAUNCH_SIMULATOR_GUI_MODE';
    end


    methods
        function this=GenSVCode(aFileName)
            this.mText='';



            if nargin==0
                this.mFid=-1;
                return;
            end

            this.mFileName=aFileName;
            this.mFid=fopen(aFileName,'w');
            if this.mFid<0
                error('HDLLink:dpigenerator:CannotOpenFile','Cannot open file %s',aFileName);
            end
        end

        function uniquename=getUniqueName(obj,Name)

            uniquename=matlab.lang.makeUniqueStrings(Name,obj.mExistNames);
            if iscell(Name)
                obj.mExistNames=[obj.mExistNames,uniquename];
            else
                obj.mExistNames{end+1}=uniquename;
            end
        end






        function addGeneratedBy(obj,prefix)
            persistent vm;
            persistent vh;
            r=datestr(now,31);
            obj.appendCode([prefix,'File: ',obj.mFileName]);
            obj.appendCode([prefix,'Created: ',r]);
            if isempty(vm)
                t=ver('matlab');
                vm=t.Version;
            end
            if isempty(vh)
                t=ver('hdlverifier');
                if isempty(t)




                    vh='';
                else
                    vh=t.Version;
                end
            end
            obj.appendCode([prefix,sprintf('Generated by MATLAB %s and HDL Verifier %s',vm,vh)]);
            obj.addNewLine;
        end

        function addGuiOrBatchModeConditionInTcl_Questasim(obj)
            tclBlock=sprintf(['if { [info exists ::env(%s)] && [string length $::env(%s)] != 0} { \n',...
            '\t set final_cmd {puts "Execute run -all to start testbench simulation"} \n',...
            '} else { \n',...
            '\t set final_cmd {run -all} \n',...
            '}'],obj.simulatorModeEnv,obj.simulatorModeEnv);
            obj.appendMultiLineCode(tclBlock);
        end

        function addGuiOrBatchModeConditionInSh_Cadence(obj)
            shellBlock=sprintf(['if [ ! -z ${%s:-} ]; \n',...
            'then \n',...
            '\t echo ''puts "Execute run to start testbench simulation"'' > next_step \n',...
            '\t final_cmd=''-input next_step'' \n',...
            '\t mode=''-gui'' \n',...
            'else \n',...
            '\t final_cmd='''' \n',...
            '\t mode='''' \n',...
            'fi \n'],obj.simulatorModeEnv);
            obj.appendMultiLineCode(shellBlock);
        end

        function addGuiOrBatchModeConditionInSh_VCS(obj)
            shellBlock=sprintf(['if [ ! -z ${%s:-} ]; \n',...
            'then \n',...
            '\t echo ''puts "Execute run to start testbench simulation"'' > next_step \n',...
            '\t final_cmd=''-i next_step'' \n',...
            '\t mode=''-gui'' \n',...
            'else \n',...
            '\t final_cmd='''' \n',...
            '\t mode='''' \n',...
            'fi \n'],obj.simulatorModeEnv);
            obj.appendMultiLineCode(shellBlock);
        end

        function addGuiOrBatchModeConditionInSh_Vivado(obj)
            shellBlock=sprintf(['if [ ! -z ${%s:-} ]; \n',...
            'then \n',...
            '\t mode=''-gui'' \n',...
            'else \n',...
            '\t mode=''-R'' \n',...
            'fi \n'],obj.simulatorModeEnv);
            obj.appendMultiLineCode(shellBlock);
        end

        function addGuiOrBatchModeConditionInBatch_Vivado(obj)
            batchBlock=sprintf(['setlocal \n',...
            'if defined %s ( \n',...
            '\t set mode=-gui \n',...
            ') else ( \n',...
            '\t set mode=-R \n',...
            ') \n'],obj.simulatorModeEnv);
            obj.appendMultiLineCode(batchBlock);
        end

        function delete(this)
            if this.mFid>0
                if~isempty(this.mText)
                    fwrite(this.mFid,this.mText,'char');
                end
                fclose(this.mFid);
            end
        end
        function appendCode(this,text)
            if~isempty(text)

                if this.mIndentLevel>0
                    text=[repmat('    ',1,this.mIndentLevel),text];
                end


                text=regexprep(text,char(10),[char(10),repmat('    ',1,this.mIndentLevel)]);

                this.mText=[this.mText,text,char(10)];
            end
        end



        function appendMultiLineCode(this,text)

            if this.mIndentLevel>0
                lines=strsplit(text,char(10));
                for m=1:numel(lines)
                    lines{m}=[repmat('    ',1,this.mIndentLevel),lines{m},char(10)];
                end
                text=[lines{:}];
                text(end)='';
            end

            this.mText=[this.mText,text,char(10)];
        end

        function prependCode(this,text)
            this.mText=[text,char(10),this.mText];
        end

        function addPortDecl(this,direction,type,portName)
            if isempty(type)
                this.appendCode(sprintf('%s %s,',direction,portName));
            else
                this.appendCode(sprintf('%s %s %s,',direction,type,portName));
            end
        end

        function name=addVarDecl(this,type,varName)
            name=this.getUniqueName(varName);
            this.appendCode([type,' ',name,';']);
        end

        function name=addParamDecl(this,varName,value)
            name=this.getUniqueName(varName);
            this.appendCode(['parameter ',name,'= ',value,';']);
        end

        function addComment(this,comment)
            if~isempty(comment)
                text=['// ',comment];
                appendCode(this,text);
            end
        end

        function addNewLine(this)
            this.mText=[this.mText,char(10)];
        end

        function addBlockingAssign(this,var,value)
            this.appendCode([var,' = ',value,';']);
        end


        function addFuncDecl(this,varargin)
            newCode=l_getFuncCode(varargin{:});
            newCode=['function ',newCode];
            appendCode(this,newCode);
        end

        function addExecFunction(this,varargin)
            newCode=l_getFuncCode(varargin{:});
            newCode=[newCode,';'];
            appendCode(this,newCode);
        end

        function addIfStatement(this,condition)
            newCode=['if ',condition];
            appendCode(this,newCode);
            this.mIndentLevel=this.mIndentLevel+1;
        end

        function addElseIfStatement(this,condition)
            this.mIndentLevel=this.mIndentLevel-1;
            newCode=['elseif ',condition];
            appendCode(this,newCode);
            this.mIndentLevel=this.mIndentLevel+1;
        end

        function addElseStatement(this)
            this.mIndentLevel=this.mIndentLevel-1;
            newCode='else ';
            appendCode(this,newCode);
            this.mIndentLevel=this.mIndentLevel+1;
        end

        function addEndStatement(this)
            this.mIndentLevel=this.mIndentLevel-1;
            appendCode(this,'end');
        end








        function addIndent(this,level)
            if nargin==1
                level=1;
            end
            this.mIndentLevel=this.mIndentLevel+level;
        end
        function reduceIndent(this,level)
            if nargin==1
                level=1;
            end
            this.mIndentLevel=this.mIndentLevel-level;
        end

        function addPersistentVarDecl(this,varName)
            newCode=['persistent ',varName,';'];
            appendCode(this,newCode);
        end
        function addIsEmptyTest(this,varName)
            newCode=['isempty(',varName,')'];
            addIfStatement(this,newCode);
        end

    end


end







