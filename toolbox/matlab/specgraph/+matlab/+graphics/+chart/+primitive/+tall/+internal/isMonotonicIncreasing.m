function tf=isMonotonicIncreasing(x)



    tf=all(~ismissing(x))&&issorted(x);
end