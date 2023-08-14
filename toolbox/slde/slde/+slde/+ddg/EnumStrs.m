classdef EnumStrs<handle



















    properties
        mStrs;
        mOneBased;
    end


    properties(Constant)
        ZeroBased=false;
        OneBased=true;
    end


    methods


        function this=EnumStrs(varargin)




            this.mOneBased=true;

            strs=cell(length(varargin),1);
            for idx=1:length(varargin)
                str=varargin{idx};
                assert(ischar(str)||islogical(str));
                if ischar(str)
                    strs{idx}=DAStudio.message(str);
                else
                    this.mOneBased=str;
                    strs(idx:end)=[];
                    break;
                end
            end

            assert(...
            (length(strs)==length(varargin))||...
            (length(strs)==length(varargin)-1));

            this.mStrs=strs;
        end


        function strs=getStrs(this)


            strs=this.mStrs;
        end


        function str=enumToStr(this,value)


            if~this.mOneBased
                value=value+1;
            end
            str=this.mStrs{value};
        end


        function value=strToEnum(this,str)


            value=find(strcmp(this.mStrs,str));
            if~this.mOneBased
                value=value-1;
            end
        end
    end
end




