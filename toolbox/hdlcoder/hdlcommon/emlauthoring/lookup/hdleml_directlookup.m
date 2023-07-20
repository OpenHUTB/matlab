%#codegen
function y=hdleml_directlookup(table_data,vector_out,allowOutOfRange,varargin)










    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(table_data);
    eml_prefer_const(vector_out);
    eml_prefer_const(allowOutOfRange);

    ndims=nargin-3;

    if ndims==1
        if vector_out
            if isfloat(table_data)&&numel(table_data)==2
                if(varargin{1}==0)
                    y=table_data(1,:);
                else
                    y=table_data(2,:);
                end
            else
                y=table_data(int32(varargin{1})+1,:);
            end
        else
            if isfloat(table_data)&&numel(table_data)==2
                if(varargin{1}==0)
                    y=table_data(1);
                else
                    y=table_data(2);
                end
            else
                if allowOutOfRange
                    index=getResolvedIndex(varargin{1},numel(table_data));
                    y=table_data(index+1);
                else
                    y=table_data(int32(varargin{1})+1);
                end
            end
        end
    else
        if allowOutOfRange
            y=getDirectLUTOutofRange(table_data,varargin{1:end});
        else
            y=getDirectLUTOut(table_data,varargin{1:end});
        end
    end
end

function Out=getDirectLUTOut(table_data,varargin)
    sz=size(table_data);
    gainVal=sz(1);
    index=int32(varargin{1});
    for i=2:numel(sz)
        index=index+(int32(varargin{i})*gainVal);
        gainVal=gainVal*sz(i);
    end
    Out=table_data(index+1);
end

function Out=getDirectLUTOutofRange(table_data,varargin)
    sz=size(table_data);
    gainVal=sz(1);
    index=getResolvedIndex(varargin{1},sz(1));
    for i=2:numel(sz)
        index=index+(getResolvedIndex(varargin{i},sz(i))*gainVal);
        gainVal=gainVal*sz(i);
    end
    Out=table_data(index+1);
end

function index=getResolvedIndex(inpIndex,maxIndex)
    if(int32(inpIndex)+1)>int32(maxIndex)
        index=int32(maxIndex-1);
    else
        index=int32(inpIndex);
    end
end
