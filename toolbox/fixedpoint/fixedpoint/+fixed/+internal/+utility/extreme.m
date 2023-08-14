function[E,I]=extreme(A,compare)


























    narginchk(2,2);
    validateattributes(compare,{'function_handle'},{'scalar'},2);
    assert(nargin(compare)==2,...
    message("fixed:utility:expectedFcnWithNInputs",2));

    if isempty(A)
        I=[];
        E=[];
    else

        I=1;
        for i=2:numel(A)
            if compare(A(i),A(I))
                I=i;
            end
        end
        E=A(I);
    end
end
