function lutObj=createLUTObject(varargin)










    narginchk(0,1);

    lutObj=Simulink.LookupTable;
    lutObj.BreakpointsSpecification='Explicit values';

    if nargin>0
        if ischar(varargin{1})&&strcmp(varargin{1},'sample')
            lutObj.Breakpoints=arrayfun(@createBreakpointObject,1:3);
            lutObj.Breakpoints(1).FieldName='Corr_Speed';
            lutObj.Breakpoints(1).Unit='epr';
            lutObj.Breakpoints(1).Value=uint16(linspace(0,15770,10));
            lutObj.Breakpoints(2).Value=single(linspace(1,2,10));
            lutObj.Breakpoints(2).FieldName='Prs_ratio';
            lutObj.Breakpoints(2).Unit='Nm';
            lutObj.Breakpoints(3).FieldName='L_rack_bpts';
            lutObj.Breakpoints(3).Value=double(linspace(0,1,6));

            lutObj.Table.FieldName='Mass_Flow_Rate';
            lutObj.Table.Unit='kg/s';
            lutObj.Table.Value=fi(rand(10,10)*60,0,8,1,2);
        else
            tableSize=varargin{1};
            validateattributes(tableSize,{'numeric'},{'nonempty','row','integer','>=',2});
            numDims=numel(tableSize);


            lutObj.Breakpoints=arrayfun(@createBreakpointObject,1:numDims);


            for idxDim=1:numDims
                lutObj.Breakpoints(idxDim).Value=1:tableSize(idxDim);
            end
            tableValue=1:prod(tableSize);
            if numDims==1
                lutObj.Table.Value=tableValue;
            else
                lutObj.Table.Value=reshape(tableValue,tableSize);
            end
        end
    end
end


function bpObj=createBreakpointObject(~)
    bpObj=Simulink.lookuptable.Breakpoint;
end
