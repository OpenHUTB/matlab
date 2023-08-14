function y=isvectornd(x)


    y=~isempty(x)&&sum(size(x)>1)<=1;

end
