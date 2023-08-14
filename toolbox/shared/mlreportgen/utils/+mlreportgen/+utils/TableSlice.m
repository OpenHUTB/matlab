classdef TableSlice<handle













    properties(SetAccess=private)




        Table{mlreportgen.utils.validators.mustBeTable(Table)}=[];




        StartCol{mlreportgen.utils.validators.mustBePositiveNumber(StartCol)}=[];




        EndCol{mlreportgen.utils.validators.mustBePositiveNumber(EndCol)}=[];

    end

    methods(Access={?mlreportgen.utils.TableSlicer})
        function this=TableSlice(varargin)
            if nargin~=6
                error(message("mlreportgen:utils:error:invalidTableSliceConstructor"));
            end


            p=inputParser;




            p.KeepUnmatched=true;

            addParameter(p,"Table",[]);
            addParameter(p,"StartCol",this.StartCol);
            addParameter(p,"EndCol",this.EndCol);

            parse(p,varargin{:});

            this.Table=p.Results.Table;
            this.StartCol=p.Results.StartCol;
            this.EndCol=p.Results.EndCol;
        end
    end
end