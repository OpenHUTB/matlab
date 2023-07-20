



function t=min_index(arr,dim)
%#codegen
    coder.allowpcode('plain');
    [~,t]=min(arr,[],dim+1);
end


