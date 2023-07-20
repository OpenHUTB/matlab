classdef(Hidden=true)LCBuildOptions




    properties
Includes
Defines
Undefines
Sources
DirToIgnore
FcnToIgnore
FcnCallToIgnore
FileToIgnore
InternalFileToIgnore
ForceCxx
ForceLcc64
ExtraOptions
    end

    methods



        function this=LCBuildOptions()
            this=this.init();
        end




        function this=set.Includes(this,val)
            this.Includes=iCheckAndGetCellStr(val,'Includes');
        end




        function this=set.Defines(this,val)
            this.Defines=iCheckAndGetCellStr(val,'Defines');
        end




        function this=set.Undefines(this,val)
            this.Undefines=iCheckAndGetCellStr(val,'Undefines');
        end




        function this=set.Sources(this,val)
            this.Sources=iCheckAndGetCellStr(val,'Sources');
        end




        function this=set.DirToIgnore(this,val)
            this.DirToIgnore=iCheckAndGetCellStr(val,'DirToIgnore');
        end




        function this=set.FcnToIgnore(this,val)
            this.FcnToIgnore=iCheckAndGetCellStr(val,'FcnToIgnore');
        end




        function this=set.FcnCallToIgnore(this,val)
            this.FcnCallToIgnore=iCheckAndGetCellStr(val,'FcnCallToIgnore');
        end




        function this=set.FileToIgnore(this,val)
            this.FileToIgnore=iCheckAndGetCellStr(val,'FileToIgnore');
        end




        function this=set.InternalFileToIgnore(this,val)
            this.InternalFileToIgnore=iCheckAndGetCellStr(val,'InternalFileToIgnore');
        end




        function this=set.ExtraOptions(this,val)
            this.ExtraOptions=iCheckAndGetCellStr(val,'ExtraOptions');
        end




        function this=set.ForceCxx(this,val)
            if isnumeric(val)
                validateattributes(val,{'numeric'},{'scalar','>=',0,'<=',1},'','ForceCxx');
            else
                validateattributes(val,{'logical'},{'scalar'},'','ForceCxx');
            end

            this.ForceCxx=logical(val);
        end




        function this=set.ForceLcc64(this,val)
            if isnumeric(val)
                validateattributes(val,{'numeric'},{'scalar','>=',0,'<=',1},'','ForceLcc64');
            else
                validateattributes(val,{'logical'},{'scalar'},'','ForceLcc64');
            end

            this.ForceLcc64=logical(val);
        end




        function val=get.ForceLcc64(this)
            if strcmpi(computer,'pcwin64')&&~this.ForceCxx
                val=this.ForceLcc64;
            else
                val=false;
            end
        end


        function dbg=isDebug(this)
            dbg=false;
        end
    end

    methods(Access='protected')



        function this=init(this)
            this.Includes={};
            this.Defines={};
            this.Undefines={};
            this.Sources={};
            this.DirToIgnore={};
            this.FcnToIgnore={};
            this.FcnCallToIgnore={};
            this.FileToIgnore={};
            this.InternalFileToIgnore={};
            this.ForceCxx=false;
            this.ForceLcc64=false;
            this.ExtraOptions={};
        end
    end
end


function val=iCheckAndGetCellStr(val,propName)

    try
        if isempty(val)
            val={};
        elseif iscellstr(val)
            val=val(:);
        else
            validateattributes(val,{'cell'},{'vector'},'',propName);
            for ii=1:numel(val)
                validateattributes(val{ii},{'char'},{'row'},'LCBuildOptions',sprintf('%s{%d}',propName,ii));
            end
        end
    catch Me
        throwAsCaller(Me);
    end

end

