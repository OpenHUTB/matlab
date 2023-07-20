function r=constraintInsideBounds(x,lb,ub)













    r=abs(mean([lb,ub])-x)-diff([lb,ub])/2;
end