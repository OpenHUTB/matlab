function dataOut=permuteHyperParameters(data,formatChangeStr)

%#codegen






    coder.inline('always');
    coder.allowpcode('plain');

    if nargin<2
        formatChangeStr='ColmajorToRowmajorPlanar';
    end

    coder.internal.prefer_const(formatChangeStr);

    switch coder.const(formatChangeStr)
    case 'ColmajorToRowmajorPlanar'


        dataOut=permute(data,[2,1,3:ndims(data)]);
    case{'ColmajorToRowmajorInterleaved','RowmajorInterleavedToColmajor'}







        dataOut=permute(data,[ndims(data):-1:3,2,1]);
    case 'RowmajorInterleavedToRowmajorPlanar'


        dataOut=permute(data,[ndims(data):-1:3,1,2]);
    otherwise
        dataOut=data;
    end



end
