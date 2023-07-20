



function t=max_index(arr,dim)
%#codegen
    coder.allowpcode('plain');
    [~,t]=max(arr,[],dim+1);
end


