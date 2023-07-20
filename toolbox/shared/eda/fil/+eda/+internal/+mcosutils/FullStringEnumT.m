classdef FullStringEnumT
    properties(Abstract=true,Constant=true)
        strValues;
        intValues;
    end
    properties(Access=private)
        currIndex=int32(1);
        currIntVal;
    end
    methods
        function this=FullStringEnumT(varargin)
            this.currIntVal=this.intValues(1);
            if(length(varargin)==1)
                arg=varargin{1};
                if(isa(arg,'eda.internal.mcosutils.FullStringEnumT'))
                    arg=arg.asInt();
                end
                if(isnumeric(arg))
                    proposedIntVal=...
                    eda.internal.mcosutils.ObjUtilsT.CheckNumeric(...
                    arg,'int32',[intmin('int32'),intmax('int32')],'currIntVal');
                    foundIntIndex=find(proposedIntVal==this.intValues,1);
                    if(~isempty(foundIntIndex))
                        this.currIndex=foundIntIndex;
                        this.currIntVal=this.intValues(foundIntIndex);
                    else
                        error(message('EDALink:FILParamObjErrWarn:NoIntInEnum',num2str(arg)));
                    end
                elseif(ischar(arg))
                    foundStrIndex=find(strcmp(arg,this.strValues));
                    if(~isempty(foundStrIndex))
                        this.currIndex=foundStrIndex;
                        this.currIntVal=this.intValues(foundStrIndex);
                    else
                        error(message('EDALink:FILParamObjErrWarn:NoStrInEnum',arg));
                    end
                else
                    error(message('EDALink:FILParamObjErrWarn:IllegalFullStringEnumCtorArg'));
                end
            elseif(length(varargin)>1)
                error(message('EDALink:FILParamObjErrWarn:BadFullStringEnumCtor'));

            end
        end
        function intVal=asInt(this)
            intVal=this.intValues(this.currIndex);
        end
        function strVal=asString(this)
            strVal=this.strValues{this.currIndex};
        end
        function disp(this)
            fprintf(1,'%s\n',this.asString());
        end
    end
end
